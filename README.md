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
src/content.js       # Script de contenu injecté sur chat.openai.com
src/style.css        # Styles du script de contenu
package.json         # Dépendances et scripts de build
```

## Développement

1. Installer les dépendances :
   ```bash
   npm install
   ```
2. Construire l'extension (JS bundlé + CSS via PostCSS) :
   ```bash
   npm run build
   ```
3. Lancer les tests (placeholder) :
   ```bash
   npm test
   ```
4. Charger le dossier `dist` comme extension non empaquetée dans votre navigateur.

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
