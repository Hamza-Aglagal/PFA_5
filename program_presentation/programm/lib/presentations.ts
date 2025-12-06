/**
 * Presentation Data
 * Contains all presentation definitions
 */

import { Presentation, Slide } from './types';

// PFA Project Presentation - Simulation de Stabilité
const pfaPresentation: Presentation = {
  id: 'pfa-simulation-stabilite',
  title: 'Simulation de Stabilité des Structures Civiles par IA',
  description: 'Projet PFA - 2025 | Technologies: Flutter – Angular – Spring Boot – Python',
  author: 'Équipe PFA 2025',
  design: 'design1',
  createdAt: new Date(),
  updatedAt: new Date(),
  slides: [
    // Slide 1: Titre du projet
    {
      id: 'slide-1',
      type: 'cover',
      content: {
        title: 'Simulation de Stabilité des Structures Civiles par Apprentissage Profond',
        subtitle: "Projet (PFA) – Ecole Marocaine des Sciences de l'Ingénieur (EMSI)",
        contact: 'Réalisé par : Hamza AGLAGAL - Bilal ELKHANTOURI - Yassin OUHADI',
        date: 'Année : 2025',
      },
      background: 'bg-gradient-to-br from-blue-50 via-indigo-100 to-purple-100',
      animation: 'fade',
      order: 1,
    },

    // Slide 2: Introduction
    {
      id: 'slide-2',
      type: 'paragraph',
      content: {
        title: 'Introduction',
        paragraphs: [
          'La sécurité des structures civiles (ponts, bâtiments) est cruciale. Leur évaluation nécessite des simulations précises pour prévenir les défaillances structurelles.',
          'Les outils actuels (ANSYS, Abaqus) sont performants mais très coûteux (15-60K$/an) et lents (2-48h de calcul), limitant leur utilisation aux grandes entreprises.',
          'Notre solution utilise l\'Intelligence Artificielle pour rendre la simulation accessible à tous : résultats en moins de 15 secondes, disponible sur mobile et web, avec une précision comparable aux méthodes classiques.',
        ],
      },
      background: 'bg-gradient-to-br from-slate-50 via-blue-50 to-cyan-100',
      animation: 'fade',
      order: 2,
    },

    // Slide 3: Problématique
    {
      id: 'slide-3',
      type: 'mixed',
      content: {
        title: 'Problématique',
        intro: 'Les bureaux d\'études en génie civil rencontrent des obstacles majeurs dans l\'utilisation des outils de simulation.',
        items: [
          'Temps de calcul FEM : 2-48h par structure (incompatible avec les délais projets).',
          'Coût prohibitif : 15-60K$/an de licences logicielles (ANSYS, Abaqus).',
          'Expertise requise : Formation de 3-6 mois nécessaire.',
          'Absence de mobilité : Outils limités aux postes fixes (pas d\'analyse terrain).',
        ],
        conclusion: 'Comment créer une solution IA mobile/web garantissant précision ≥ 95% et temps de réponse < 15s, accessible sans expertise FEM approfondie ?',
      },
      background: 'bg-gradient-to-br from-orange-50 via-amber-50 to-yellow-100',
      animation: 'slide',
      order: 3,
    },

    // Slide 4: Objectifs du projet
    {
      id: 'slide-4',
      type: 'content',
      content: {
        title: 'Objectifs du projet',
        bulletPoints: [
          '🎯 Plateforme multi-canal : Application mobile (Flutter) + Web (Angular) intuitive.',
          '🤖 Modèle IA : Deep Learning (PyTorch) entraîné sur 10 000+ structures validées FEM.',
          '⚡ Performance : Temps de réponse < 15s | Précision ≥ 95% vs simulations FEM.',
          '📱 Accessibilité : Analyse sur site via smartphone (entrée photos/croquis).',
          '📊 Automatisation : Génération rapports PDF conformes Eurocode avec recommandations.',
          '✅ Qualité : Couverture tests ≥ 80% | SonarQube Note A | CI/CD Jenkins.',
        ],
      },
      background: 'bg-gradient-to-br from-purple-50 via-fuchsia-50 to-pink-100',
      animation: 'zoom',
      order: 4,
    },

    // Slide 5: Étude de l'existant
    {
      id: 'slide-5',
      type: 'table',
      content: {
        title: 'Étude de l\'existant',
        tableData: {
          headers: [], // No table headers - we'll show cards instead
          rows: [
            ['ANSYS Mechanical', '', ''],
            ['Abaqus/CAE', '', ''],
            ['SAP2000 CSI', '', ''],
            ['DeepFEM (MIT)', '', ''],
          ],
          rowImages: [
            '/images/ansys-simulation-software.png',
            '/images/abaqus.png',
            '/images/logo-csiamerica.svg',
            null,
          ],
          rowDetails: [
            {
              description: 'Leader mondial de la simulation numérique multiphysique pour l\'ingénierie. Solution complète pour analyses structurelles, thermiques, acoustiques et électromagnétiques. Utilisé par 90% des entreprises Fortune 500 pour la validation de produits et l\'optimisation de conception.',
              avantages: ['Précision validée industriellement', 'Support technique premium 24/7', 'Bibliothèque matériaux exhaustive (10 000+ matériaux)', 'Formation certifiée disponible'],
              limites: ['Licence très coûteuse (>15K$/an/utilisateur)', 'Formation longue requise (3-6 mois minimum)', 'Pas d\'accès mobile ou cloud natif', 'Interface complexe nécessitant expertise', 'Temps de calcul élevé sans optimisation IA'],
              technologies: ['APDL', 'Mechanical APDL', 'Fluent CFD', 'Maxwell EM'],
              cout: '15 000 - 50 000 $ par an / licence',
              reference: 'ansys.com • Certifié ISO 26262 • Standard automobile',
            },
            {
              description: 'Solution premium de Dassault Systèmes pour simulations non-linéaires complexes incluant crash tests, déformations plastiques et analyses thermiques couplées. Standard de référence dans l\'industrie aérospatiale (Boeing, Airbus) et automobile (Tesla, BMW).',
              avantages: ['Excellence reconnue en calculs non-linéaires', 'Validation complète NAFEMS', 'Intégration native avec CATIA/SolidWorks', 'Solveurs implicites et explicites'],
              limites: ['Desktop uniquement (Windows/Linux)', 'RAM minimum 32GB fortement recommandée', 'Pas d\'API REST moderne pour intégration', 'Absence totale d\'intelligence artificielle', 'Export limité vers applications tierces'],
              technologies: ['Abaqus/Standard', 'Abaqus/Explicit', 'Abaqus/CAE', 'Python API'],
              cout: '20 000 - 60 000 $ par an / licence',
              reference: '3ds.com/abaqus • Certifié NAFEMS • Standard aérospatial',
            },
            {
              description: 'Logiciel de référence pour le calcul sismique et l\'analyse statique/dynamique des structures de génie civil (bâtiments, ponts, tours, infrastructures). Leader historique du marché depuis 1984 avec plus de 100 000 utilisateurs dans le monde.',
              avantages: ['Spécialisé génie civil et structures', 'Normes sismiques mondiales intégrées', 'Largement adopté par bureaux d\'études', 'Prix accessible pour PME'],
              limites: ['Interface utilisateur datée (années 2000)', 'Visualisation 3D basique sans WebGL', 'Pas d\'intégration cloud native', 'Workflow manuel non optimisé', 'Collaboration temps-réel impossible'],
              technologies: ['SAP2000', 'ETABS', 'SAFE', 'CSiBridge'],
              cout: '2 500 - 8 000 $ par an / licence',
              reference: 'csiamerica.com • Conforme Eurocode 8 • ASCE 7 certified',
            },
            {
              description: 'Projet de recherche pionnier du MIT combinant Physics-Informed Neural Networks (PINN) avec la méthode des éléments finis classique. Approche innovante utilisant l\'apprentissage profond pour accélérer les simulations FEM jusqu\'à 100x avec résultats académiques très prometteurs.',
              avantages: ['Approche IA révolutionnaire et unique', 'Accélération potentielle 100x des calculs', 'Code source partiellement open source', 'Publications scientifiques de référence'],
              limites: ['Prototype académique non industrialisé', 'Documentation technique sparse et limitée', 'Aucune équipe de support commercial', 'Absence complète d\'interface graphique', 'Validation limitée sur cas industriels réels'],
              technologies: ['PyTorch', 'TensorFlow', 'Python', 'PINN', 'AutoDiff'],
              cout: 'Gratuit (Projet de Recherche)',
              reference: 'Raissi & Karniadakis (2019) • Journal of Computational Physics',
            },
          ],
        },
      },
      background: 'bg-gradient-to-br from-emerald-50 via-teal-50 to-cyan-100',
      animation: 'fade',
      order: 5,
    },

    // Slide 6: Valeur ajoutée
    {
      id: 'slide-6',
      type: 'content',
      content: {
        title: 'Valeur ajoutée du projet',
        bulletPoints: [
          '🤖 IA : Prédiction rapide et intelligente.',
          '📱 Accessibilité : Mobile & Web.',
          '🎨 Visualisation : Résultats 3D interactifs.',
          '⚡ Rapidité : Résultats en quelques secondes.',
          '🔒 Sécurité : Architecture robuste et chiffrée.',
        ],
      },
      background: 'bg-gradient-to-br from-rose-50 via-pink-50 to-fuchsia-100',
      animation: 'slide',
      order: 6,
    },

    // Slide 7: Sources de données (Dataset)
    {
      id: 'slide-7',
      type: 'mixed',
      content: {
        title: 'Sources de données (Dataset)',
        intro: 'Le modèle d\'apprentissage profond nécessite un ensemble de données simulées pour apprendre à prédire la stabilité structurelle.',
        items: [
          'Données FEM générées via ANSYS / Abaqus.',
          'Datasets publics (Kaggle – Structural Mechanics).',
          'Données open-source (DeepFEM, GitHub).',
        ],
        conclusion: 'Les données sont normalisées et stockées pour l\'entraînement du modèle IA (train/test split, MLflow).',
      },
      background: 'bg-gradient-to-br from-indigo-50 via-violet-50 to-purple-100',
      animation: 'fade',
      order: 7,
    },

    // Slide 8: Architecture du système
    {
      id: 'slide-8',
      type: 'schema',
      content: {
        title: 'Architecture du système',
        schema: {
          type: 'architecture',
          description: 'Architecture 3-Tiers : Frontend / Backend / IA / Base de Données',
          nodes: [
            { id: 'mobile', label: 'Mobile App\n(Flutter)', position: 'top-left' },
            { id: 'web', label: 'Web App\n(Angular)', position: 'top-right' },
            { id: 'api', label: 'API REST\n(Spring Boot)', position: 'middle' },
            { id: 'ia', label: 'IA Engine\n(Python / PyTorch)', position: 'bottom-middle' },
            { id: 'db', label: 'PostgreSQL\nDatabase', position: 'bottom' },
          ],
        },
      },
      background: 'bg-gradient-to-br from-cyan-50 via-sky-50 to-blue-100',
      animation: 'zoom',
      order: 8,
    },

    // Slide 9: Structure du projet
    {
      id: 'slide-9',
      type: 'schema',
      content: {
        title: 'Structure du projet',
        schema: {
          type: 'detailed-tree',
          description: 'Architecture modulaire avec structures détaillées pour chaque service',
          services: [
            {
              name: 'mobile',
              icon: '📱',
              tech: 'Flutter/Dart',
              color: 'from-blue-500 to-blue-600',
              structure: [
                'lib/',
                '├── models/',
                '├── screens/',
                '├── widgets/',
                '├── services/',
                '└── main.dart',
              ],
            },
            {
              name: 'web',
              icon: '🌐',
              tech: 'Angular',
              color: 'from-red-500 to-red-600',
              structure: [
                'src/',
                '├── app/',
                '│   ├── components/',
                '│   ├── services/',
                '│   └── models/',
                '└── assets/',
              ],
            },
            {
              name: 'backend',
              icon: '⚙️',
              tech: 'Spring Boot',
              color: 'from-green-500 to-green-600',
              structure: [
                'src/main/java/',
                '├── controllers/',
                '├── services/',
                '├── models/',
                '├── repositories/',
                '└── config/',
              ],
            },
            {
              name: 'ai_engine',
              icon: '🤖',
              tech: 'Python/PyTorch',
              color: 'from-orange-500 to-orange-600',
              structure: [
                'ai_engine/',
                '├── models/',
                '├── training/',
                '├── prediction/',
                '├── utils/',
                '└── api/',
              ],
            },
            {
              name: 'database',
              icon: '💾',
              tech: 'PostgreSQL',
              color: 'from-indigo-500 to-indigo-600',
              structure: [
                'database/',
                '├── migrations/',
                '├── seeds/',
                '├── schemas/',
                '└── queries/',
              ],
            },
          ],
        },
      },
      background: 'bg-gradient-to-br from-green-50 via-emerald-50 to-teal-100',
      animation: 'fade',
      order: 9,
    },

    // Slide 10: Technologies utilisées
    {
      id: 'slide-10',
      type: 'tech-carousel',
      content: {
        title: 'Technologies utilisées',
        technologies: [
          {
            domain: 'Mobile',
            name: 'Flutter / Dart',
            icon: '📱',
            color: 'from-blue-500 to-blue-700',
            description: 'Framework cross-platform pour applications mobiles',
          },
          {
            domain: 'Web',
            name: 'Angular',
            icon: '🌐',
            color: 'from-red-500 to-red-700',
            description: 'Framework JavaScript pour applications web',
          },
          {
            domain: 'Backend',
            name: 'Spring Boot',
            icon: '⚙️',
            color: 'from-green-500 to-green-700',
            description: 'Framework Java pour API REST',
          },
          {
            domain: 'IA',
            name: 'Python / PyTorch',
            icon: '🤖',
            color: 'from-orange-500 to-orange-700',
            description: 'Deep Learning et prédictions',
          },
          {
            domain: 'Base de données',
            name: 'PostgreSQL',
            icon: '💾',
            color: 'from-indigo-500 to-indigo-700',
            description: 'Base de données relationnelle',
          },
          {
            domain: 'CI/CD',
            name: 'GitHub Actions / Docker',
            icon: '🚀',
            color: 'from-purple-500 to-purple-700',
            description: 'Intégration et déploiement continus',
          },
          {
            domain: 'Monitoring',
            name: 'Grafana + Prometheus',
            icon: '📊',
            color: 'from-teal-500 to-teal-700',
            description: 'Surveillance et métriques en temps réel',
          },
        ],
      },
      background: 'bg-gradient-to-br from-amber-50 via-orange-50 to-red-100',
      animation: 'slide',
      order: 10,
    },

    // Slide 11: Méthodologie
    {
      id: 'slide-11',
      type: 'timeline',
      content: {
        title: 'Méthodologie',
        intro: 'Le développement suit une approche Agile (SCRUM) pour garantir flexibilité et progression continue.',
        timeline: [
          'Initialisation',
          'Backend & IA',
          'Flutter/Web',
          'Tests',
          'Déploiement',
        ],
        conclusion: 'Livraison incrémentale toutes les deux semaines.',
      },
      background: 'bg-gradient-to-br from-blue-50 via-indigo-50 to-violet-100',
      animation: 'fade',
      order: 11,
    },

    // Slide 12: Qualité Logicielle
    {
      id: 'slide-12',
      type: 'quality',
      content: {
        title: 'Qualité Logicielle',
        checklist: [
          'Analyse statique du code (SonarQube)',
          'Tests automatisés (Selenium, JUnit, Jest)',
          'Intégration Continue (Jenkins CI/CD)',
          'Couverture de tests ≥ 80%',
          'Respect des standards de codage',
          'Revue de code systématique',
        ],
        kpis: {
          headers: ['Outil / Métrique', 'Objectif Qualité'],
          rows: [
            ['SonarQube - Code Quality', 'Note A (0 bugs critiques)'],
            ['Selenium - Tests E2E', '100% scénarios critiques'],
            ['JUnit - Tests Unitaires', 'Couverture ≥ 80%'],
            ['Jest - Tests Frontend', 'Couverture ≥ 75%'],
            ['Jenkins - Build Success', '≥ 95% de builds réussis'],
            ['Code Review', '100% des PR validées'],
          ],
        },
      },
      background: 'bg-gradient-to-br from-teal-50 via-cyan-50 to-sky-100',
      animation: 'zoom',
      order: 12,
    },

    // Slide 13: Résultats attendus
    {
      id: 'slide-13',
      type: 'content',
      content: {
        title: 'Résultats attendus',
        bulletPoints: [
          '✅ IA fonctionnelle et rapide',
          '✅ Application stable et responsive',
          '✅ Visualisation 3D interactive',
          '✅ Rapport PDF automatique',
          '',
          '🎯 Performance < 3 secondes',
          '🎯 Précision ≥ 95%',
          '🎯 Disponibilité 99.9%',
        ],
      },
      background: 'bg-gradient-to-br from-violet-50 via-purple-50 to-fuchsia-100',
      animation: 'slide',
      order: 13,
    },

    // Slide 14: Conclusion
    {
      id: 'slide-14',
      type: 'mixed',
      content: {
        title: 'Conclusion',
        intro: 'Le projet démontre la faisabilité d\'une solution IA pour la simulation structurelle, rapide, intuitive et multi-plateforme.',
        items: [
          'Combinaison IA + Génie civil + Accessibilité mobile.',
          'Outil utile pour ingénieurs et étudiants.',
          'Base solide pour des versions futures (V2.0).',
        ],
      },
      background: 'bg-gradient-to-br from-pink-50 via-rose-50 to-red-100',
      animation: 'fade',
      order: 14,
    },

    // Slide 15: Perspectives
    {
      id: 'slide-15',
      type: 'content',
      content: {
        title: 'Perspectives',
        bulletPoints: [
          'Ajout de structures complexes (ponts, dalles).',
          'Analyse dynamique (vibrations, séismes).',
          'Collaboration multi-utilisateurs.',
          'IA générative pour conception automatisée.',
        ],
      },
      background: 'bg-gradient-to-br from-sky-50 via-blue-50 to-indigo-100',
      animation: 'zoom',
      order: 15,
    },

    // Slide 16: Remerciements
    {
      id: 'slide-16',
      type: 'thanks',
      content: {
        title: 'Merci pour votre attention !',
        subtitle: 'Questions & Discussion',
        message: 'Simulation de Stabilité des Structures Civiles par IA',
      },
      background: 'bg-gradient-to-br from-purple-100 via-pink-100 to-rose-200',
      animation: 'fade',
      order: 16,
    },
  ],
};

// Export all presentations
export const getAllPresentations = (): Presentation[] => {
  return [pfaPresentation];
};

export const getPresentationById = (id: string): Presentation | undefined => {
  return getAllPresentations().find((p) => p.id === id);
};
