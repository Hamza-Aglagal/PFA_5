# Diagramme de Cas d'Utilisation - SimStruct

## Vue d'ensemble du Système

**SimStruct** est une plateforme de simulation structurelle qui permet aux ingénieurs de créer, analyser et partager des simulations de structures avec intégration IA pour les calculs avancés.

---

## Acteurs du Système

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                   ACTEURS                                            │
└─────────────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────┐
    │    «Actor»      │
    │   Visiteur      │
    │   (Anonyme)     │
    └────────┬────────┘
             │
             │ s'inscrit / se connecte
             ▼
    ┌─────────────────┐          ┌─────────────────┐
    │    «Actor»      │          │    «Actor»      │
    │  Utilisateur    │◄─────────│  Administrateur │
    │  (Authentifié)  │ hérite   │    (Admin)      │
    └────────┬────────┘          └─────────────────┘
             │
             │ upgrade
             ▼
    ┌─────────────────┐
    │    «Actor»      │
    │  Professionnel  │
    │     (PRO)       │
    └─────────────────┘

                                 ┌─────────────────┐
                                 │  «External»     │
                                 │   Système IA    │
                                 │   (Model_AI)    │
                                 └─────────────────┘
```

---

## Diagramme de Cas d'Utilisation Principal

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                                 │
│                                        SYSTÈME SIMSTRUCT                                                        │
│                                                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │                                     AUTHENTIFICATION                                                     │   │
│  │                                                                                                          │   │
│  │       ┌───────────────────────┐    ┌───────────────────────┐    ┌───────────────────────┐               │   │
│  │       │   UC1: S'inscrire     │    │   UC2: Se connecter   │    │ UC3: Rafraîchir Token │               │   │
│  │       │                       │    │                       │    │                       │               │   │
│  │       └───────────────────────┘    └───────────────────────┘    └───────────────────────┘               │   │
│  │                                             │                                                            │   │
│  │                                             │ «include»                                                  │   │
│  │                                             ▼                                                            │   │
│  │                                    ┌───────────────────────┐                                             │   │
│  │                                    │ UC4: Valider JWT      │                                             │   │
│  │                                    │                       │                                             │   │
│  │                                    └───────────────────────┘                                             │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │                                      SIMULATIONS                                                         │   │
│  │                                                                                                          │   │
│  │   ┌───────────────────────┐    ┌───────────────────────┐    ┌───────────────────────┐                   │   │
│  │   │ UC5: Créer Simulation │    │ UC6: Consulter        │    │ UC7: Modifier         │                   │   │
│  │   │                       │    │     Simulation        │    │     Simulation        │                   │   │
│  │   └───────────┬───────────┘    └───────────────────────┘    └───────────────────────┘                   │   │
│  │               │                                                                                          │   │
│  │               │ «include»      ┌───────────────────────┐    ┌───────────────────────┐                   │   │
│  │               ▼                │ UC8: Supprimer        │    │ UC9: Marquer Favoris  │                   │   │
│  │   ┌───────────────────────┐    │     Simulation        │    │                       │                   │   │
│  │   │ UC10: Calculer avec   │    └───────────────────────┘    └───────────────────────┘                   │   │
│  │   │       IA              │                                                                              │   │
│  │   └───────────────────────┘    ┌───────────────────────┐    ┌───────────────────────┐                   │   │
│  │                                │ UC11: Publier         │    │ UC12: Liker           │                   │   │
│  │                                │      Simulation       │    │      Simulation       │                   │   │
│  │                                └───────────────────────┘    └───────────────────────┘                   │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │                                       COMMUNAUTÉ                                                         │   │
│  │                                                                                                          │   │
│  │   ┌───────────────────────┐    ┌───────────────────────┐    ┌───────────────────────┐                   │   │
│  │   │ UC13: Rechercher      │    │ UC14: Envoyer         │    │ UC15: Accepter/       │                   │   │
│  │   │      Utilisateurs     │    │  Demande d'Amitié     │    │  Refuser Invitation   │                   │   │
│  │   └───────────────────────┘    └───────────────────────┘    └───────────────────────┘                   │   │
│  │                                                                                                          │   │
│  │   ┌───────────────────────┐    ┌───────────────────────┐    ┌───────────────────────┐                   │   │
│  │   │ UC16: Partager        │    │ UC17: Voir            │    │ UC18: Retirer         │                   │   │
│  │   │      Simulation       │    │  Partages Reçus       │    │      Partage          │                   │   │
│  │   └───────────────────────┘    └───────────────────────┘    └───────────────────────┘                   │   │
│  │                                                                                                          │   │
│  │   ┌───────────────────────┐    ┌───────────────────────┐    ┌───────────────────────┐                   │   │
│  │   │ UC19: Explorer        │    │ UC20: Consulter       │    │ UC21: Gérer           │                   │   │
│  │   │  Simulations Publiques│    │      Liste Amis       │    │      Amis             │                   │   │
│  │   └───────────────────────┘    └───────────────────────┘    └───────────────────────┘                   │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │                                     MESSAGERIE (CHAT)                                                    │   │
│  │                                                                                                          │   │
│  │   ┌───────────────────────┐    ┌───────────────────────┐    ┌───────────────────────┐                   │   │
│  │   │ UC22: Envoyer Message │    │ UC23: Consulter       │    │ UC24: Marquer Lu      │                   │   │
│  │   │                       │    │     Conversations     │    │                       │                   │   │
│  │   └───────────────────────┘    └───────────────────────┘    └───────────────────────┘                   │   │
│  │                                                                                                          │   │
│  │   ┌───────────────────────┐                                                                              │   │
│  │   │ UC25: Voir Historique │                                                                              │   │
│  │   │       Messages        │                                                                              │   │
│  │   └───────────────────────┘                                                                              │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │                                     NOTIFICATIONS                                                        │   │
│  │                                                                                                          │   │
│  │   ┌───────────────────────┐    ┌───────────────────────┐    ┌───────────────────────┐                   │   │
│  │   │ UC26: Recevoir        │    │ UC27: Marquer         │    │ UC28: Supprimer       │                   │   │
│  │   │     Notification      │    │      comme Lu         │    │     Notification      │                   │   │
│  │   └───────────────────────┘    └───────────────────────┘    └───────────────────────┘                   │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │                                    PROFIL UTILISATEUR                                                    │   │
│  │                                                                                                          │   │
│  │   ┌───────────────────────┐    ┌───────────────────────┐    ┌───────────────────────┐                   │   │
│  │   │ UC29: Consulter       │    │ UC30: Modifier        │    │ UC31: Changer         │                   │   │
│  │   │       Profil          │    │       Profil          │    │     Mot de Passe      │                   │   │
│  │   └───────────────────────┘    └───────────────────────┘    └───────────────────────┘                   │   │
│  │                                                                                                          │   │
│  │   ┌───────────────────────┐                                                                              │   │
│  │   │ UC32: Uploader Avatar │                                                                              │   │
│  │   │                       │                                                                              │   │
│  │   └───────────────────────┘                                                                              │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Relations entre Acteurs et Cas d'Utilisation

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                     │
│                              RELATIONS ACTEURS - CAS D'UTILISATION                                  │
│                                                                                                     │
│                                                                                                     │
│     ┌─────────────┐                                          ┌─────────────────────────────────┐   │
│     │  Visiteur   │─────────────────────────────────────────▶│ UC1: S'inscrire                 │   │
│     │  (Anonyme)  │─────────────────────────────────────────▶│ UC2: Se connecter               │   │
│     └─────────────┘                                          └─────────────────────────────────┘   │
│                                                                                                     │
│     ┌─────────────┐        ┌─────────────────────────────────────────────────────────────────┐     │
│     │             │───────▶│ AUTHENTIFICATION: UC3, UC4                                      │     │
│     │             │        └─────────────────────────────────────────────────────────────────┘     │
│     │             │        ┌─────────────────────────────────────────────────────────────────┐     │
│     │             │───────▶│ SIMULATIONS: UC5, UC6, UC7, UC8, UC9, UC10, UC11, UC12          │     │
│     │ Utilisateur │        └─────────────────────────────────────────────────────────────────┘     │
│     │(Authentifié)│        ┌─────────────────────────────────────────────────────────────────┐     │
│     │             │───────▶│ COMMUNAUTÉ: UC13-UC21                                           │     │
│     │             │        └─────────────────────────────────────────────────────────────────┘     │
│     │             │        ┌─────────────────────────────────────────────────────────────────┐     │
│     │             │───────▶│ MESSAGERIE: UC22-UC25                                           │     │
│     │             │        └─────────────────────────────────────────────────────────────────┘     │
│     │             │        ┌─────────────────────────────────────────────────────────────────┐     │
│     │             │───────▶│ NOTIFICATIONS: UC26-UC28                                        │     │
│     │             │        └─────────────────────────────────────────────────────────────────┘     │
│     │             │        ┌─────────────────────────────────────────────────────────────────┐     │
│     │             │───────▶│ PROFIL: UC29-UC32                                               │     │
│     └─────────────┘        └─────────────────────────────────────────────────────────────────┘     │
│                                                                                                     │
│     ┌─────────────┐        ┌─────────────────────────────────────────────────────────────────┐     │
│     │ Système IA  │◀───────│ UC10: Calculer avec IA                                          │     │
│     │ (Model_AI)  │        │ ↳ Prédiction de déflexion, contraintes, facteur sécurité       │     │
│     └─────────────┘        └─────────────────────────────────────────────────────────────────┘     │
│                                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Détail des Cas d'Utilisation

### Module Authentification

| ID | Cas d'Utilisation | Description | Acteur Principal | Pré-condition | Post-condition |
|----|-------------------|-------------|------------------|---------------|----------------|
| UC1 | S'inscrire | Créer un nouveau compte utilisateur | Visiteur | Email non utilisé | Compte créé, tokens générés |
| UC2 | Se connecter | Authentification avec email/mot de passe | Visiteur | Compte existant | Tokens JWT générés |
| UC3 | Rafraîchir Token | Obtenir un nouveau token d'accès | Utilisateur | Refresh token valide | Nouveau access token |
| UC4 | Valider JWT | Vérifier la validité du token | Système | Token fourni | Authentification validée |

### Module Simulations

| ID | Cas d'Utilisation | Description | Acteur Principal | Pré-condition | Post-condition |
|----|-------------------|-------------|------------------|---------------|----------------|
| UC5 | Créer Simulation | Définir paramètres et lancer calcul | Utilisateur | Authentifié | Simulation créée avec résultats IA |
| UC6 | Consulter Simulation | Voir détails et résultats | Utilisateur | Simulation accessible | Données affichées |
| UC7 | Modifier Simulation | Mettre à jour paramètres | Utilisateur | Propriétaire | Simulation mise à jour |
| UC8 | Supprimer Simulation | Effacer une simulation | Utilisateur | Propriétaire | Simulation supprimée |
| UC9 | Marquer Favoris | Ajouter/retirer des favoris | Utilisateur | Propriétaire | État favori modifié |
| UC10 | Calculer avec IA | Appeler le modèle ML pour prédictions | Système IA | Paramètres valides | Résultats structurels |
| UC11 | Publier Simulation | Rendre public/privé | Utilisateur | Propriétaire | Visibilité modifiée |
| UC12 | Liker Simulation | Ajouter un like à une simulation publique | Utilisateur | Simulation publique | Compteur incrémenté |

### Module Communauté

| ID | Cas d'Utilisation | Description | Acteur Principal | Pré-condition | Post-condition |
|----|-------------------|-------------|------------------|---------------|----------------|
| UC13 | Rechercher Utilisateurs | Trouver des utilisateurs par nom/email | Utilisateur | Authentifié | Liste d'utilisateurs |
| UC14 | Envoyer Demande d'Amitié | Demander à se connecter | Utilisateur | Pas déjà amis | Invitation créée |
| UC15 | Accepter/Refuser Invitation | Répondre à une demande | Utilisateur | Invitation reçue | Amitié créée/refusée |
| UC16 | Partager Simulation | Donner accès à un ami | Utilisateur | Amis, propriétaire | Partage créé |
| UC17 | Voir Partages Reçus | Consulter simulations partagées | Utilisateur | Partages existants | Liste affichée |
| UC18 | Retirer Partage | Annuler un partage | Utilisateur | Propriétaire du partage | Partage supprimé |
| UC19 | Explorer Simulations Publiques | Parcourir le catalogue public | Utilisateur | Authentifié | Simulations affichées |
| UC20 | Consulter Liste Amis | Voir tous les amis | Utilisateur | Authentifié | Liste d'amis |
| UC21 | Gérer Amis | Supprimer un ami | Utilisateur | Amitié existante | Amitié supprimée |

### Module Messagerie

| ID | Cas d'Utilisation | Description | Acteur Principal | Pré-condition | Post-condition |
|----|-------------------|-------------|------------------|---------------|----------------|
| UC22 | Envoyer Message | Écrire à un ami | Utilisateur | Amis | Message envoyé |
| UC23 | Consulter Conversations | Voir liste des conversations | Utilisateur | Authentifié | Conversations listées |
| UC24 | Marquer Lu | Marquer messages comme lus | Utilisateur | Messages non lus | Messages marqués lus |
| UC25 | Voir Historique Messages | Consulter conversation avec ami | Utilisateur | Amis | Messages affichés |

### Module Notifications

| ID | Cas d'Utilisation | Description | Acteur Principal | Pré-condition | Post-condition |
|----|-------------------|-------------|------------------|---------------|----------------|
| UC26 | Recevoir Notification | Être notifié d'un événement | Utilisateur | Événement déclenché | Notification créée |
| UC27 | Marquer comme Lu | Marquer notification lue | Utilisateur | Notification existante | État mis à jour |
| UC28 | Supprimer Notification | Effacer une notification | Utilisateur | Notification existante | Notification supprimée |

### Module Profil

| ID | Cas d'Utilisation | Description | Acteur Principal | Pré-condition | Post-condition |
|----|-------------------|-------------|------------------|---------------|----------------|
| UC29 | Consulter Profil | Voir ses informations | Utilisateur | Authentifié | Données affichées |
| UC30 | Modifier Profil | Mettre à jour infos personnelles | Utilisateur | Authentifié | Profil mis à jour |
| UC31 | Changer Mot de Passe | Modifier son mot de passe | Utilisateur | Authentifié | Mot de passe changé |
| UC32 | Uploader Avatar | Ajouter/modifier photo | Utilisateur | Authentifié | Avatar mis à jour |

---

## Diagramme des Relations Include et Extend

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                     │
│                              RELATIONS «INCLUDE» ET «EXTEND»                                        │
│                                                                                                     │
│  ┌───────────────────────────────────────────────────────────────────────────────────────────────┐ │
│  │                                                                                               │ │
│  │   ┌─────────────────────┐       «include»        ┌─────────────────────┐                     │ │
│  │   │ UC5: Créer          │─────────────────────▶  │ UC10: Calculer      │                     │ │
│  │   │     Simulation      │                        │       avec IA       │                     │ │
│  │   └─────────────────────┘                        └─────────────────────┘                     │ │
│  │                                                                                               │ │
│  │   ┌─────────────────────┐       «include»        ┌─────────────────────┐                     │ │
│  │   │ UC6: Consulter      │─────────────────────▶  │ UC4: Valider JWT    │                     │ │
│  │   │     Simulation      │                        └─────────────────────┘                     │ │
│  │   └─────────────────────┘                                   ▲                                │ │
│  │                                                             │ «include»                      │ │
│  │   ┌─────────────────────┐                                   │                                │ │
│  │   │ UC22: Envoyer       │───────────────────────────────────┘                                │ │
│  │   │      Message        │                                                                    │ │
│  │   └─────────────────────┘                                                                    │ │
│  │                                                                                               │ │
│  │   ┌─────────────────────┐       «extend»         ┌─────────────────────┐                     │ │
│  │   │ UC16: Partager      │◀─────────────────────  │ UC22: Envoyer       │                     │ │
│  │   │      Simulation     │   [message optionnel]  │      Message        │                     │ │
│  │   └─────────────────────┘                        └─────────────────────┘                     │ │
│  │                                                                                               │ │
│  │   ┌─────────────────────┐       «extend»         ┌─────────────────────┐                     │ │
│  │   │ UC14: Envoyer       │◀─────────────────────  │ UC26: Recevoir      │                     │ │
│  │   │  Demande d'Amitié   │                        │     Notification    │                     │ │
│  │   └─────────────────────┘                        └─────────────────────┘                     │ │
│  │                                                             ▲                                │ │
│  │                                                             │ «extend»                       │ │
│  │   ┌─────────────────────┐                                   │                                │ │
│  │   │ UC15: Accepter      │───────────────────────────────────┘                                │ │
│  │   │     Invitation      │                                                                    │ │
│  │   └─────────────────────┘                                                                    │ │
│  │                                                                                               │ │
│  └───────────────────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Scénarios Principaux

### Scénario UC5: Créer Simulation avec IA

```
SCÉNARIO PRINCIPAL: Créer une nouvelle simulation structurelle

Acteur: Utilisateur authentifié
Pré-conditions: L'utilisateur est connecté

1. L'utilisateur accède à l'interface de création
2. L'utilisateur saisit les paramètres de la poutre:
   - Dimensions (longueur, largeur, hauteur)
   - Type de matériau (STEEL, CONCRETE, WOOD, ALUMINUM)
   - Module d'élasticité et densité
3. L'utilisateur définit la charge:
   - Type (POINT, DISTRIBUTED, TRIANGULAR)
   - Magnitude et position
4. L'utilisateur sélectionne le type de support:
   - SIMPLY_SUPPORTED, CANTILEVER, FIXED, CONTINUOUS
5. Le système valide les paramètres
6. Le système appelle le modèle IA (Model_AI)
7. L'IA calcule:
   - Déflexion maximale
   - Moment fléchissant max
   - Effort tranchant max
   - Contrainte maximale
   - Facteur de sécurité
8. Le système enregistre la simulation avec résultats
9. L'utilisateur visualise les résultats en 3D

EXTENSIONS:
- 5a. Paramètres invalides → Message d'erreur
- 6a. Modèle IA indisponible → Calcul différé
```

### Scénario UC16: Partager Simulation

```
SCÉNARIO PRINCIPAL: Partager une simulation avec un ami

Acteur: Utilisateur authentifié (propriétaire)
Pré-conditions: Simulation existante, relation d'amitié établie

1. L'utilisateur sélectionne une simulation
2. L'utilisateur clique sur "Partager"
3. Le système affiche la liste d'amis
4. L'utilisateur sélectionne un ou plusieurs amis
5. L'utilisateur définit les permissions (VIEW/EDIT)
6. L'utilisateur ajoute un message optionnel
7. Le système crée le partage
8. Le système notifie les destinataires
9. Les amis peuvent accéder à la simulation

EXTENSIONS:
- 3a. Aucun ami → Inviter des utilisateurs
- 7a. Simulation déjà partagée → Mettre à jour permissions
```

---

## Technologies et Intégrations

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                         │
│                              ARCHITECTURE TECHNIQUE                                     │
│                                                                                         │
│  ┌───────────────┐    ┌───────────────┐    ┌───────────────┐    ┌───────────────┐      │
│  │  Angular 19   │    │  Flutter      │    │ Spring Boot   │    │   PyTorch     │      │
│  │     Web       │    │   Mobile      │    │   Backend     │    │   Model IA    │      │
│  └───────┬───────┘    └───────┬───────┘    └───────┬───────┘    └───────┬───────┘      │
│          │                    │                    │                    │               │
│          │                    │                    │                    │               │
│          └────────────────────┼────────────────────┼────────────────────┘               │
│                               │                    │                                    │
│                               ▼                    ▼                                    │
│                    ┌─────────────────────────────────────────┐                         │
│                    │            REST API (HTTPS)             │                         │
│                    │         JWT Authentication              │                         │
│                    └─────────────────┬───────────────────────┘                         │
│                                      │                                                  │
│                                      ▼                                                  │
│                    ┌─────────────────────────────────────────┐                         │
│                    │           PostgreSQL Database           │                         │
│                    └─────────────────────────────────────────┘                         │
│                                                                                         │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Résumé des Statistiques

| Catégorie | Nombre |
|-----------|--------|
| **Acteurs** | 4 (Visiteur, Utilisateur, Pro, Admin, Système IA) |
| **Cas d'Utilisation** | 32 |
| **Modules** | 6 (Auth, Simulation, Communauté, Chat, Notifications, Profil) |
| **Relations Include** | 4 |
| **Relations Extend** | 4 |
