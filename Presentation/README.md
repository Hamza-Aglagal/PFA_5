# 📊 Présentation SIMSTRUCT - Guide Complet

## 📁 Structure du Projet

```
Presentation/
├── main.tex                      # Fichier principal (importe tous les slides)
├── README.md                     # Ce guide
│
├── theme/
│   └── simstruct-theme.tex       # Thème personnalisé (couleurs, styles, commandes)
│
├── slides/
│   ├── 01-couverture.tex         # Page de couverture
│   ├── 02-plan.tex               # Plan de la présentation
│   ├── 03-introduction.tex       # Introduction + slide de section
│   ├── 04-problematique.tex      # Problématique
│   ├── 05-objectifs.tex          # Objectifs du projet
│   ├── 06-solution.tex           # Solution proposée
│   ├── 07-architecture.tex       # Architecture système
│   ├── 08-conception-usecase.tex # Diagramme cas d'utilisation
│   ├── 09-conception-classes.tex # Diagramme de classes
│   ├── 10-conception-sequence.tex# Diagramme de séquence
│   ├── 11-technologies.tex       # Technologies utilisées
│   ├── 12-modele-ia.tex          # Modèle d'intelligence artificielle
│   ├── 13-realisation-web.tex    # Captures Web (4 slides)
│   ├── 14-realisation-mobile.tex # Captures Mobile
│   ├── 15-demonstration.tex      # Vidéo démo
│   ├── 16-tests.tex              # Tests et qualité
│   ├── 17-conclusion.tex         # Conclusion
│   └── 18-remerciements.tex      # Remerciements
│
└── images/
    └── README.md                 # Guide des images à ajouter
```

---

## 🎨 Design et Palette de Couleurs

### Couleurs Principales
| Couleur | Code RGB | Utilisation |
|---------|----------|-------------|
| **Primary** | `RGB(37, 99, 235)` | Éléments principaux, titres |
| **Secondary** | `RGB(16, 185, 129)` | Succès, validations |
| **Accent** | `RGB(245, 158, 11)` | Intelligence Artificielle |
| **Danger** | `RGB(239, 68, 68)` | Problèmes, alertes |
| **Dark** | `RGB(30, 41, 59)` | Texte principal |

### Caractéristiques du Design
- ✅ Format 16:9 (aspect ratio moderne)
- ✅ Slides de transition animés entre sections
- ✅ Icônes FontAwesome 5 intégrées
- ✅ Ombres subtiles pour les cartes
- ✅ Placeholders pour images clairement identifiés

---

## 🔧 Compilation

### Option 1 : Ligne de commande (Recommandé)

```bash
cd "c:\Users\Hamza\Documents\EMSI 5\PFA\Presentation"

# Compiler 2 fois pour les références
pdflatex main.tex
pdflatex main.tex
```

### Option 2 : VS Code + LaTeX Workshop

1. Installer l'extension **LaTeX Workshop**
2. Ouvrir `main.tex`
3. Appuyer sur `Ctrl+Alt+B`

### Option 3 : Overleaf (En ligne)

1. Créer un nouveau projet sur [Overleaf](https://www.overleaf.com)
2. Uploader tous les fichiers en respectant la structure
3. Compiler automatiquement

---

## 📝 Personnalisation

### Modifier le nom de l'encadrant

Dans `main.tex`, ligne 17 :
```latex
\newcommand{\encadrant}{Pr. Mohamed BENALI}  % Remplacer par le vrai nom
```

### Modifier vos informations de contact

Dans `slides/18-remerciements.tex`, modifier :
- Email
- GitHub
- LinkedIn

### Ajouter des images

Remplacez les commandes `\imagePlaceholder` par :
```latex
\includegraphics[width=12cm]{images/votre-image.png}
```

---

## 🖼️ Images à Préparer

### Captures d'écran Web
- [ ] `dashboard.png` - Tableau de bord
- [ ] `simulation.png` - Page de simulation
- [ ] `results.png` - Page des résultats
- [ ] `community.png` - Page communauté

### Captures d'écran Mobile
- [ ] `mobile-home.png` - Écran d'accueil
- [ ] `mobile-simulation.png` - Écran simulation
- [ ] `mobile-results.png` - Écran résultats
- [ ] `mobile-profile.png` - Écran profil

### Diagrammes UML
- [ ] `usecase-diagram.png` - Cas d'utilisation
- [ ] `class-diagram.png` - Diagramme de classes
- [ ] `sequence-diagram.png` - Diagramme de séquence

### Vidéo
- [ ] Préparer une vidéo de démonstration (2-3 min)

---

## 📋 Structure des Slides (24 slides total)

| # | Slide | Description |
|---|-------|-------------|
| 1 | Couverture | Page titre avec design professionnel |
| 2 | Plan | Navigation visuelle (10 sections) |
| 3 | Section 01 | Transition "Introduction" |
| 4 | Introduction | Contexte du génie civil numérique |
| 5 | Section 02 | Transition "Problématique" |
| 6 | Problématique | Défis actuels et questions clés |
| 7 | Section 03 | Transition "Objectifs" |
| 8 | Objectifs | Buts et fonctionnalités cibles |
| 9 | Section 04 | Transition "Solution" |
| 10 | Solution | Architecture générale du système |
| 11 | Section 05 | Transition "Architecture" |
| 12 | Architecture | Architecture en couches détaillée |
| 13 | Section 06 | Transition "Conception" |
| 14 | Cas d'utilisation | Placeholder diagramme UML |
| 15 | Classes | Placeholder diagramme UML |
| 16 | Séquence | Placeholder diagramme UML |
| 17 | Section 07 | Transition "Technologies" |
| 18 | Technologies | Stack technique (3 colonnes) |
| 19 | Modèle IA | Architecture réseau de neurones |
| 20 | Section 08 | Transition "Réalisation" |
| 21-24 | Web | 4 captures d'écran |
| 25 | Mobile | 4 écrans Flutter |
| 26 | Section 09 | Transition "Démonstration" |
| 27 | Démonstration | Placeholder vidéo |
| 28 | Tests | Stratégie de tests et qualité |
| 29 | Section 10 | Transition "Conclusion" |
| 30 | Conclusion | Réalisations et perspectives |
| 31 | Remerciements | Page finale avec contact |

---

## ⚠️ Résolution des Problèmes

### Erreur : Package fontawesome5 non trouvé
```bash
# MiKTeX : Installation automatique
# TeX Live :
tlmgr install fontawesome5
```

### Icônes non affichées
Compiler avec XeLaTeX :
```bash
xelatex main.tex
```

### Erreur de fichier non trouvé
Vérifier que tous les fichiers dans `slides/` et `theme/` existent.

---

## 🎓 Conseils de Présentation

1. **Timing** : ~2 minutes par slide = ~50-60 minutes total
2. **Démo** : Préparer une démo live ou vidéo de secours
3. **Questions** : Anticiper les questions sur l'IA et la sécurité
4. **Backup** : Avoir le PDF sur clé USB + cloud

---

**Bonne soutenance ! 🎉**
