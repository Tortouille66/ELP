module Levels exposing (Level, GameMode(..), getLevelDescription, getTotalLevels, getLevel)

{-| Module pour gérer les niveaux du jeu

Ce module définit tous les niveaux avec les objectifs et les tailles attendues.
-}


{-| Mode de jeu

- `FreeMode`: pas de niveaux, liberté totale
- `LevelMode Int`: mode niveaux avec le numéro du niveau actuel
-}
type GameMode
    = FreeMode
    | LevelMode Int


{-| Structure d'un niveau

Champs:
- `numero`: numéro du niveau (1, 2, 3, etc.)
- `nom`: nom du niveau (ex: "Le Cercle")
- `description`: description de la tâche (ex: "Dessine un cercle de rayon 50")
- `formes`: liste des formes acceptées [(nomForme, rayon/taille)]
- `taille`: taille attendue pour la forme (rayon ou dimension)
-}
type alias Level =
    { numero : Int
    , nom : String
    , description : String
    , formes : List String  -- ["Cercle", "Carré", etc.]
    , taille : Int
    }


{-| Retourne la liste de tous les niveaux -}
tousLesNiveaux : List Level
tousLesNiveaux =
    [ -- Niveau 1: Cercle simple
      { numero = 1
      , nom = "Le Cercle"
      , description = "Dessine un cercle de rayon 50"
      , formes = ["Cercle"]
      , taille = 50
      }
    
    , -- Niveau 2: Carré
      { numero = 2
      , nom = "Le Carré"
      , description = "Dessine un carré de côté 80"
      , formes = ["Carré"]
      , taille = 80
      }
    
    , -- Niveau 3: Triangle
      { numero = 3
      , nom = "Le Triangle"
      , description = "Dessine un triangle de côté 60"
      , formes = ["Triangle"]
      , taille = 60
      }
    
    , -- Niveau 4: Étoile à 5 branches
      { numero = 4
      , nom = "L'Étoile"
      , description = "Dessine une étoile à 5 branches de taille 70"
      , formes = ["Étoile"]
      , taille = 70
      }]
    
   


{-| Retourne le nombre total de niveaux -}
getTotalLevels : Int
getTotalLevels =
    List.length tousLesNiveaux


{-| Retourne le niveau spécifié par son numéro -}
getLevel : Int -> Maybe Level
getLevel numero =
    tousLesNiveaux
        |> List.filter (\level -> level.numero == numero)
        |> List.head


{-| Retourne la description d'un niveau

Exemple:
```
getLevelDescription 1
-- "Niveau 1: Le Cercle\nDessine un cercle (rayon = 50)"
```
-}
getLevelDescription : Int -> String
getLevelDescription numero =
    case getLevel numero of
        Just level ->
            "Niveau " ++ String.fromInt level.numero ++ ": " ++ level.nom ++ "\n" ++ level.description
        Nothing ->
            "Niveau invalide"


{-| Vérifie si une forme est valide pour le niveau actuel -}
isValidShapeForLevel : Int -> String -> Bool
isValidShapeForLevel levelNum shapeName =
    case getLevel levelNum of
        Just level ->
            List.member shapeName level.formes
        Nothing ->
            False


{-| Retourne la taille attendue pour un niveau -}
getLevelSize : Int -> Int
getLevelSize levelNum =
    case getLevel levelNum of
        Just level ->
            level.taille
        Nothing ->
            0
