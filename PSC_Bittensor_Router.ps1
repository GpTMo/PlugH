#!/usr/bin/env pwsh
param(
  [switch]$Init,
  [string]$Ask,
  [string]$Policy="auto",
  [string]$Profile="chat",
  [switch]$Stream
)

$Base = Join-Path $HOME 'assistant_bittensor_psc'
$CfgDir = Join-Path $Base 'config'
$LogDir = Join-Path $Base 'logs'
$SessDir = Join-Path $Base 'sessions'
$CfgFile = Join-Path $CfgDir 'config.json'
$LogFile = Join-Path $LogDir 'last_run.log'
$ErrFile = Join-Path $LogDir 'install_error.log'

New-Item -ItemType Directory -Force -Path $CfgDir,$LogDir,$SessDir | Out-Null
if (-not (Test-Path $CfgFile)) {
@'
{
  "bt_endpoint": "",
  "bt_api_key": "",
  "model": "",
  "profiles": {
    "chat":      { "temperature": 0.20, "top_p": 0.90, "max_tokens": 1024, "system": "Asistente conciso, experto." },
    "code":      { "temperature": 0.10, "top_p": 0.85, "max_tokens": 1400, "system": "Coding assistant preciso. Code in English." },
    "translate": { "temperature": 0.15, "top_p": 0.90, "max_tokens": 900,  "system": "Traducción ES/FR/EN fiel." },
    "deep":      { "temperature": 0.20, "top_p": 0.90, "max_tokens": 2048, "system": "Razonamiento profundo, pasos claros." }
  },
  "model_map": {
    "fast": "tier-fast-8b",
    "general": "tier-general-14b",
    "deep": "tier-deep-70b",
    "code": "tier-code-7b",
    "translate": "tier-trans-2b"
  }
}
'@ | Set-Content -Path $CfgFile
}

Start-Transcript -Path $LogFile -Force
try {
  if ($Init) { Write-Host 'Init complete'; Stop-Transcript; exit 0 }
  $btEndpoint = $env:BT_ENDPOINT
  if (-not $btEndpoint) { throw 'BT_ENDPOINT required' }
  if (-not $Ask) { $Ask = $env:ASK }
  if (-not $Ask) { throw 'ASK required' }
  $apiKey = $env:BT_API_KEY
  $modelOverride = $env:MODEL
  if ($env:PROFILE) { $Profile = $env:PROFILE }
  if ($env:POLICY) { $Policy = $env:POLICY }
  if ($env:STREAM) { $Stream = $env:STREAM -eq '1' }

  $btEndpoint = $btEndpoint.TrimEnd('/')
  if (-not $btEndpoint.ToLower().EndsWith('/v1')) { $btEndpoint += '/v1' }

  $headers = @{}
  if ($apiKey) { $headers['Authorization'] = "Bearer $apiKey" }
  $modelsResp = Invoke-WebRequest -Uri "$btEndpoint/models" -Headers $headers -UseBasicParsing
  if ($modelsResp.StatusCode -ne 200) { throw "Failed to fetch models: $($modelsResp.StatusCode)" }
  $models = (ConvertFrom-Json $modelsResp.Content).data.id

  $cfg = Get-Content $CfgFile | ConvertFrom-Json
  if ($modelOverride) {
    $chosen = $modelOverride
  } elseif ($Policy -ne 'auto') {
    $chosen = $cfg.model_map.$Policy
  } else {
    $txt = $Ask.ToLower()
    if ($txt -match '```|\b(function|class|error|regex|code|python|javascript|java|c\+\+|c#|go|rust|ruby|typescript)\b') {
      $chosen = $cfg.model_map.code
    } elseif ($txt -match 'translate|traduce|traducción|->\s*(en|es|fr)') {
      $chosen = $cfg.model_map.translate
    } else {
      $words = ($txt -split '\s+').Count
      if ($words -gt 280) {
        $chosen = $cfg.model_map.deep
      } elseif ($words -gt 80) {
        $chosen = $cfg.model_map.general
      } else {
        $chosen = $cfg.model_map.fast
      }
    }
  }
  if ($models -notcontains $chosen) {
    Write-Warning "model $chosen not available; using $($models[0])"
    $chosen = $models[0]
  }
  $profile = $cfg.profiles.$Profile
  $body = @{model=$chosen; messages=@(@{role='system';content=$profile.system},@{role='user';content=$Ask}); temperature=$profile.temperature; top_p=$profile.top_p; max_tokens=$profile.max_tokens; stream=$Stream} | ConvertTo-Json -Depth 4

  $sessionFile = Join-Path $SessDir ("bt_{0}.txt" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
  if ($Stream) {
    $resp = Invoke-WebRequest -Uri "$btEndpoint/chat/completions" -Headers $headers -ContentType 'application/json' -Body $body -Method Post -UseBasicParsing -Stream
    $reader = New-Object System.IO.StreamReader($resp.RawContentStream)
    while(($line = $reader.ReadLine()) -ne $null) {
      if ($line -eq 'data: [DONE]') { '[DONE]'; break }
      if ($line -like 'data: *') {
        $json = $line.Substring(6)
        $token = (ConvertFrom-Json $json).choices[0].delta.content
        Write-Host -NoNewline $token
        Add-Content -NoNewline -Path $sessionFile -Value $token
      }
    }
  } else {
    $resp = Invoke-WebRequest -Uri "$btEndpoint/chat/completions" -Headers $headers -ContentType 'application/json' -Body $body -Method Post -UseBasicParsing
    $text = (ConvertFrom-Json $resp.Content).choices[0].message.content
    Write-Host $text
    Set-Content -Path $sessionFile -Value $text
  }
  Stop-Transcript
} catch {
  $_ | Out-String | Set-Content $ErrFile
  Stop-Transcript
  exit 1
}
