# 🐢 Turtle Drawing Game - Système de Niveaux

Bienvenue dans le système de niveaux pour votre application Turtle! Ce guide explique comment utiliser les nouveaux modes de jeu et comment ajouter vos propres niveaux.

## Modes de Jeu

### 1. Mode Libre 🎨
- Aucune restriction, dessine librement ce que tu veux
- Les formes sont détectées automatiquement (Cercle, Carré, Triangle, Étoile)
- Parfait pour expérimenter avec les commandes

### 2. Mode Niveaux 📈
- 5 niveaux progressifs de difficulté croissante
- Chaque niveau te demande de dessiner une forme spécifique
- La taille attendue est indiquée pour chaque forme
- Progresse à travers les niveaux en réussissant chacun

## Description des Niveaux

| Niveau | Nom | Tâche | Taille |
|--------|-----|-------|--------|
| 1 | Le Cercle | Dessine un cercle | rayon = 50 |
| 2 | Le Carré | Dessine un carré | côté = 80 |
| 3 | Le Triangle | Dessine un triangle | côté = 60 |
| 4 | L'Étoile | Dessine une étoile à 5 branches | rayon = 70 |
| 5 | Créativité Sans Limites | Étoile + Cercle ensemble | librement |

## Comment Dessiner Les Formes

### Cercle (rayon = 50)
```
[Repeat 360 [Forward 1, Left 1]]
```

### Carré (côté = 80)
```
[Forward 80, Left 90, Forward 80, Left 90, Forward 80, Left 90, Forward 80]
```

### Triangle (côté = 60)
```
[Forward 60, Left 120, Forward 60, Left 120, Forward 60]
```

### Étoile (rayon = 70)
```
[Repeat 5 [Forward 70, Left 144, Forward 70, Left 36]]
```

## Architecture du Code

### Fichiers Ajoutés

#### 1. **Levels.elm** 
- Définit les niveaux du jeu
- Contient la structure `Level` avec les détails de chaque niveau
- Fournit des fonctions pour accéder aux niveaux
- `getLevel : Int -> Maybe Level` - récupère un niveau
- `getLevelDescription : Int -> String` - description formatée
- `isValidShapeForLevel : Int -> String -> Bool` - vérifie la validité

#### 2. **Validation.elm**
- Analyse les dessins pour reconnaître les formes
- Type `ShapeType` : Cercle, Carré, Triangle, Étoile
- Fonction `validateShape : List Ligne -> ValidationResult`
- Analyse les angles et le nombre de lignes pour identifier la forme

#### 3. **Main.elm** (modifié)
- Nouveau type `GameMode` : FreeMode | LevelMode Int
- Nouveaux messages pour les niveaux
- Interface avec sélecteur de mode
- Buttons de navigation entre niveaux
- Affichage des infos de niveau

## Ajouter de Nouveaux Niveaux

Pour ajouter un niveau, éditez `Levels.elm` dans la fonction `tousLesNiveaux`:

```elm
, { numero = 7
  , nom = "Le Nom de Votre Niveau"
  , description = "Description de la tâche"
  , formes = ["Cercle", "Carré"]  -- Formes acceptées
  , taille = 50
  }
```

**Note:** Assurez-toi d'incrémenter le numéro et de maintenir l'ordre!

## Améliorer la Validation

La validation actuelle est basée sur:
- Le nombre de lignes tracées
- Les angles entre les lignes
- La comparaison avec des patterns connus

Pour améliorer la reconnaissance, tu peux modifier la fonction `analyzeDrawing` dans `Validation.elm` pour ajouter:
- Détection de distance parcourue
- Analyse de symétrie
- Détection de fermeture de forme

## Utiliser l'Application

1. **Choisir un mode**
   - Clique "Mode Libre 🎨" ou "Mode Niveaux 📈"

2. **Voir les instructions**
   - Clique sur "ℹ️ Aide" pour voir la description du niveau/mode

3. **Entrer tes commandes**
   - Saisis ton programme dans la zone de texte

4. **Dessiner**
   - Clique "Dessiner 🎨"
   - Résultat et validation s'affichent

5. **Progresser (en Mode Niveaux)**
   - Clique "Suivant ▶" pour le prochain niveau
   - Ou "◀ Précédent" pour revenir

## Commandes Turtle Disponibles

- `Forward n` : Avance de n pixels
- `Left deg` : Tourne à gauche de deg degrés  
- `Right deg` : Tourne à droite de deg degrés
- `Repeat n [...]` : Répète n fois

Exemple: `[Repeat 360 [Forward 1, Left 1]]` dessine un cercle

---

**Amusez-vous bien à concevoir et jouer avec les niveaux!** 🎮
