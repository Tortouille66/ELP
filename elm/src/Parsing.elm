module Parsing exposing (Instruction(..), lire)

import Parser exposing (..)


{-| Type énuméré des instructions supportées

Chaque instruction contient les paramètres nécessaires à son exécution.

Constructeurs:
- `Forward Int`: avance de n pixels
- `Left Int`: tourne à gauche de n degrés
- `Right Int`: tourne à droite de n degrés
- `Repeat Int (List Instruction)`: répète une liste d'instructions
-}
type Instruction
    = Forward Int
    | Left Int
    | Right Int
    | Repeat Int (List Instruction)


{-| Lit et analyse un programme complet

Cette fonction est le point d'entrée principal. Elle:
1. Essaie de parser la chaîne d'entrée
2. Retourne une liste d'instructions si succès
3. Retourne un message d'erreur si syntaxe invalide

Arguments:
- `entree`: chaîne de caractères contenant le programme

Retourne:
- `Ok (List Instruction)`: si le parsing réussit
- `Err String`: message d'erreur "Erreur de syntaxe" si parsing échoue

Exemple:
```
lire "[Forward 100, Left 90]"
-- Ok [Forward 100, Left 90]
```
-}
lire : String -> Result String (List Instruction)
lire entree =
    -- Lance le parser et convertit les erreurs en message lisible
    run analyserProgramme entree
        |> Result.mapError (\_ -> "Erreur de syntaxe")


{-| Parse un programme entier délimité par [ et ]

Format:
```
[instruction1, instruction2, instruction3, ...]
```

Processus:
1. Consomme le crochet ouvrant [
2. Parse toutes les instructions
3. Consomme le crochet fermant ]

Retourne:
Une liste d'instructions ordonnées
-}
analyserProgramme : Parser (List Instruction)
analyserProgramme =
    -- Étape 1 : Consomme le crochet ouvrant [
    symbol "["
        |> andThen (\_ -> analyserInstructions)
        |> andThen
            (\instructions ->
                -- Étape 2 : Consomme les espaces optionnels
                spaces
                    -- Étape 3 : Consomme le crochet fermant ]
                    |> andThen (\_ -> symbol "]")
                    -- Étape 4 : Retourne les instructions parsées
                    |> andThen (\_ -> succeed instructions)
            )


{-| Parse une liste d'instructions séparées par des virgules

Utilise une boucle pour collecter toutes les instructions
jusqu'à la fin de la liste.

Retourne:
Une liste d'instructions dans l'ordre correct
-}
analyserInstructions : Parser (List Instruction)
analyserInstructions =
    -- Utilise une boucle pour collecter les instructions
    -- La liste est accumulée en ordre inverse pour efficacité
    loop [] aiderAnalyserInstructions


{-| Aide à parser les instructions une par une avec une boucle

Fonction auxiliaire pour `analyserInstructions`.

Processus:
1. Essaie de parser une instruction
2. Si succès: continue la boucle avec l'instruction ajoutée
3. Si échec: termine la boucle et retourne les instructions

Gère aussi les virgules optionnelles entre les instructions.

Arguments:
- `instructionsInversees`: accumulation inversée des instructions (pour efficacité)

Retourne:
Un pas de boucle avec les instructions inversées (à renverser avant de retourner)
-}
aiderAnalyserInstructions : List Instruction -> Parser (Step (List Instruction) (List Instruction))
aiderAnalyserInstructions instructionsInversees =
    oneOf
        [ -- Cas 1 : on réussit à parser une instruction
          -- On continue la boucle en ajoutant l'instruction
          succeed (\i -> Loop (i :: instructionsInversees))
            |= analyserInstruction
            |. spaces
            |. virguleOptionnelle
        , -- Cas 2 : on ne peut pas parser d'instruction
          -- La liste est terminée, on finit la boucle et on inverse la liste
          succeed ()
            |> map (\_ -> Done (List.reverse instructionsInversees))
        ]


{-| Parse une virgule optionnelle entre les instructions

Accepte:
- Une virgule suivie d'espaces: `, `
- Rien (pour les dernières instructions)

Cela permet d'avoir des formats comme:
- `[Forward 100, Left 90]` (avec virgule)
- `[Forward 100 Left 90]` (sans virgule - non recommandé)
- `[Forward 100,Left 90]` (avec virgule et espaces variables)
-}
virguleOptionnelle : Parser ()
virguleOptionnelle =
    oneOf
        [ -- Accepte une virgule suivie d'espaces
          symbol "," |. spaces
        , -- Ou rien (permet les listes sans virgules)
          succeed ()
        ]


{-| Parse une instruction unique

Essaie de reconnaître l'une des quatre instructions:
1. Repeat
2. Forward (Avancer)
3. Left (Gauche)
4. Right (Droite)

Les espaces initiaux sont acceptés et consommés.

Retourne:
L'instruction parsée
-}
analyserInstruction : Parser Instruction
analyserInstruction =
    -- Consomme les espaces initiaux puis essaie les quatre types d'instructions
    spaces
        |> andThen
            (\_ ->
                oneOf
                    [ analyserRepeat      -- Essaie Repeat en premier (plus spécifique)
                    , analyserAvancer     -- Puis Forward
                    , analyserGauche      -- Puis Left
                    , analyserDroite      -- Et enfin Right
                    ]
            )


{-| Parse l'instruction Repeat

Format:
```
Repeat <nombre> <programme>
```

Exemple:
```
Repeat 4 [Forward 50, Left 90]
```

Cela répète les instructions entre crochets 4 fois.

Retourne:
Une instruction Repeat avec le nombre de répétitions et la liste d'instructions
-}
analyserRepeat : Parser Instruction
analyserRepeat =
    succeed Repeat
        -- Consomme le mot-clé "Repeat"
        |. symbol "Repeat"
        |. spaces
        -- Parse le nombre de répétitions
        |= int
        |. spaces
        -- Parse le programme à répéter (utilise lazy pour éviter la récursion infinie)
        |= lazy (\_ -> analyserProgramme)


{-| Parse l'instruction Forward (Avancer)

Format:
```
Forward <distance>
```

Exemple:
```
Forward 100
```

La tortue avance de 100 pixels dans sa direction actuelle.

Retourne:
Une instruction Forward avec la distance en pixels
-}
analyserAvancer : Parser Instruction
analyserAvancer =
    succeed Forward
        -- Consomme le mot-clé "Forward"
        |. symbol "Forward"
        |. spaces
        -- Parse la distance en pixels
        |= int


{-| Parse l'instruction Left (Tourner à gauche)

Format:
```
Left <angle>
```

Exemple:
```
Left 90
```

La tortue tourne à gauche de 90 degrés (angle augmente).

Retourne:
Une instruction Left avec l'angle en degrés
-}
analyserGauche : Parser Instruction
analyserGauche =
    succeed Left
        -- Consomme le mot-clé "Left"
        |. symbol "Left"
        |. spaces
        -- Parse l'angle en degrés
        |= int


{-| Parse l'instruction Right (Tourner à droite)

Format:
```
Right <angle>
```

Exemple:
```
Right 90
```

La tortue tourne à droite de 90 degrés (angle diminue).

Retourne:
Une instruction Right avec l'angle en degrés
-}
analyserDroite : Parser Instruction
analyserDroite =
    succeed Right
        -- Consomme le mot-clé "Right"
        |. symbol "Right"
        |. spaces
        -- Parse l'angle en degrés
        |= int


{-| Parse un mot-clé (sensible à la casse)

Consomme le mot-clé exact et les espaces qui le suivent.

Arguments:
- `str`: le mot-clé à reconnaître (ex: "Forward", "Left", "Repeat")

Cela garantit qu'on ne confond pas:
- "Forward" et "Forward2"
- "Left" et "LeftShift"

Retourne:
Rien (effectue juste la vérification et consommation)
-}
motCle : String -> Parser ()
motCle str =
    -- Parse un mot-clé exact (case-sensitive) suivi d'espaces
    symbol str |. spaces
