C'est mon premier projet publique soyez indulgent svp 

# Super H

Super H est un plugin d'intégration pour l'interface web de ChatGPT. Il s'inspire du projet open source [Superpower ChatGPT](https://github.com/saeedezzati/superpower-chatgpt) et prépare un terrain pour de nombreuses fonctionnalités avancées :

- 📚 **Gestionnaire d'invites** : organisation illimitée des prompts et chaînes d'invites.
- 📝 **Notes par conversation** : stockage local et synchronisation future.
- 🌉 **Galerie d'images** : historiser et rechercher les images générées par ChatGPT.
- 🔄 **Synchronisation** : partage des paramètres et de l'historique entre appareils.
- 🔊 **Voice GPT** : conversion texte/parole pour discuter avec ChatGPT.
- 🖱️ **Menu contextuel** : accès rapide aux invites favorites sur tout le web.
- 🛠️ **Utilitaires** : profils d'instructions, résumés automatiques, sélecteur de modèle, etc.

## Structure du dépôt

```
manifest.json        # Manifest MV3 pour l'extension
src/content.js       # Script de contenu injecté sur chat.openai.com et chatgpt.com
package.json         # Dépendances (markdown-it, postcss)
```

## Développement

1. Installer les dépendances (facultatif pour ce squelette) :
   ```bash
   npm install
   ```
2. Lancer les tests (placeholder) :
   ```bash
   npm test
   ```
3. Charger le dossier comme extension non empaquetée dans votre navigateur.
4. Ouvrir `chrome://extensions`, activer le mode développeur et utiliser "Inspect views" pour consulter la console du script de contenu. Un message "Super H content script loaded" confirme l'injection, en plus du bandeau jaune sur la page.

## Ressources intégrées
- [Superpower ChatGPT](https://github.com/saeedezzati/superpower-chatgpt)
- [markdown-it](https://github.com/markdown-it/markdown-it)
- [postcss](https://github.com/postcss/postcss)
- [chatgpt-retrieval-plugin](https://github.com/openai/chatgpt-retrieval-plugin)
- [kestra](https://github.com/kestra-io/kestra)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [vim-plug](https://github.com/junegunn/vim-plug)
- [awesome-neovim](https://github.com/rockerBOO/awesome-neovim)
- [jup-ag/plugin](https://github.com/jup-ag/plugin)

Ce dépôt n'est qu'une base minimale : il sera enrichi par la suite pour offrir toutes les fonctionnalités "Super H" dans l'interface web de ChatGPT.
