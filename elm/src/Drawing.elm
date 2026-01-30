
module Drawing exposing (afficher, traiter, traiterInstruction, Tortue, Ligne, Point)

import Parsing exposing (Instruction(..))
import Svg exposing (..)
import Svg.Attributes exposing (..)


{-| Représente un point sur le plan cartésien

Champs:
- `x`: coordonnée horizontale
- `y`: coordonnée verticale
-}
type alias Point = 
    { x : Float, y : Float }


{-| Représente une ligne tracée entre deux points

Champs:
- `debut`: point de départ
- `fin`: point d'arrivée
-}
type alias Ligne = 
    { debut : Point, fin : Point }


{-| Représente l'état de la tortue

La tortue est l'entité qui trace le dessin.

Champs:
- `x`: position horizontale actuelle
- `y`: position verticale actuelle
- `angle`: direction d'orientation en degrés (0 = droite, 90 = haut)
- `lignes`: liste de toutes les lignes tracées jusqu'à présent
-}
type alias Tortue =
    { x : Float
    , y : Float
    , angle : Float
    , lignes : List Ligne
    }


{-| Affiche un dessin en SVG à partir d'une liste d'instructions

Arguments:
- `zoomAuto`: si True, calcule automatiquement la boîte de vue pour adapter le dessin
- `instructions`: liste des instructions à exécuter (Forward, Left, Right, Repeat)

Retourne:
Un élément SVG avec les lignes tracées et la boîte de vue appropriée

Exemple:
```
afficher True [Forward 100, Left 90, Forward 100]
```
-}
afficher : Bool -> List Instruction -> Svg msg
afficher zoomAuto instructions =
    let
        -- État initial : tortue au centre, pointant à droite, sans lignes tracées
        etatInitial = { x = 0, y = 0, angle = 0, lignes = [] }
        
        -- Exécute toutes les instructions pour obtenir l'état final
        etatFinal = traiter instructions etatInitial
        
        -- Calcule la boîte de vue (viewBox) selon le mode zoom
        chaineVue = 
            if zoomAuto then
                -- Zoom auto : adapte la vue à la taille du dessin
                calculerBoite etatFinal.lignes
            else
                -- Zoom fixe : utilise une vue par défaut centrée
                "-200 -200 400 400"
    in
    -- Crée l'élément SVG avec tous les paramètres
    svg
        [ viewBox chaineVue
        , width "400"
        , height "400"
        , preserveAspectRatio "xMidYMid meet"
        ]
        -- Trace toutes les lignes dans le SVG
        (List.map dessinerLigne etatFinal.lignes)


{-| Calcule la boîte de vue (viewBox) pour un zoom automatique

Cette fonction:
1. Extrait tous les points des lignes
2. Trouve les coordonnées min/max en x et y
3. Ajoute une marge de 20 pixels tout autour
4. Retourne une chaîne formatée pour l'attribut SVG viewBox

Arguments:
- `lignes`: liste de toutes les lignes tracées

Retourne:
Une chaîne au format "minX minY largeur hauteur"
-}
calculerBoite : List Ligne -> String
calculerBoite lignes =
    let
        -- Extrait tous les points de début et fin de chaque ligne
        tousLesPoints = 
            List.concatMap (\ligne -> [ligne.debut, ligne.fin]) lignes

        -- Sépare les coordonnées x et y
        xs = List.map .x tousLesPoints
        ys = List.map .y tousLesPoints

        -- Trouve les limites du dessin (ou 0 si liste vide)
        minX = Maybe.withDefault 0 (List.minimum xs)
        maxX = Maybe.withDefault 0 (List.maximum xs)
        minY = Maybe.withDefault 0 (List.minimum ys)
        maxY = Maybe.withDefault 0 (List.maximum ys)

        -- Ajoute une marge autour du dessin pour ne pas serrer contre les bords
        marge = 20
        -- Calcule la largeur et hauteur avec la marge
        -- max 1 pour éviter une division par zéro si le dessin est vide
        largeur = (maxX - minX) |> Basics.max 1 |> (+) (2 * marge)
        hauteur = (maxY - minY) |> Basics.max 1 |> (+) (2 * marge)
    in
    -- Formate la chaîne pour l'attribut viewBox SVG
    String.join " "
        [ String.fromFloat (minX - marge)
        , String.fromFloat (minY - marge)
        , String.fromFloat largeur
        , String.fromFloat hauteur
        ]


{-| Dessine une ligne sur le SVG

Convertit une ligne en élément SVG `<line>` avec:
- Coordonnées de début et fin
- Couleur noire
- Traits fins

Arguments:
- `ligne`: la ligne à dessiner (avec debut et fin)

Retourne:
Un élément SVG `<line>`
-}
dessinerLigne : Ligne -> Svg msg
dessinerLigne { debut, fin } =
    -- Crée un élément SVG <line> avec les coordonnées de la ligne
    line
        [ x1 (String.fromFloat debut.x)
        , y1 (String.fromFloat debut.y)
        , x2 (String.fromFloat fin.x)
        , y2 (String.fromFloat fin.y)
        -- Dessine en noir
        , stroke "black"
        ]
        []


{-| Traite une liste d'instructions et met à jour l'état de la tortue

Applique chaque instruction successivement en mettant à jour:
- La position (x, y) de la tortue
- L'angle (direction) de la tortue
- La liste des lignes tracées

Arguments:
- `instructions`: liste des instructions à exécuter
- `tortue`: l'état initial de la tortue

Retourne:
L'état final de la tortue après toutes les instructions
-}
traiter : List Instruction -> Tortue -> Tortue
traiter instructions tortue =
    -- Applique chaque instruction successivement avec foldl
    -- qui maintient l'état de la tortue à jour
    List.foldl traiterInstruction tortue instructions


{-| Traite une instruction unique et met à jour la tortue

Gère quatre types d'instructions:

1. **Forward n**: avance de n pixels dans la direction actuelle
   - Calcule les déplacements dx et dy avec cosinus/sinus
   - Trace une ligne du point précédent au nouveau point
   
2. **Left deg**: tourne à gauche de deg degrés
   - Ajoute deg à l'angle
   
3. **Right deg**: tourne à droite de deg degrés
   - Soustrait deg de l'angle
   
4. **Repeat n list**: exécute la liste d'instructions n fois
   - Répète et concatène la liste
   - Appelle traiter récursivement

Arguments:
- `instruction`: l'instruction à traiter
- `tortue`: l'état actuel de la tortue

Retourne:
La tortue mise à jour
-}
traiterInstruction : Instruction -> Tortue -> Tortue
traiterInstruction instruction tortue =
    case instruction of
        -- Instruction Forward : avancer dans la direction actuelle
        Forward n ->
            let
                -- Convertit l'angle en radians
                rad = degrees tortue.angle
                -- Calcule les déplacements avec cos et sin
                -- cos pour l'axe X (gauche/droite)
                dx = toFloat n * cos rad
                -- sin pour l'axe Y (haut/bas), inversé car SVG utilise Y vers le bas
                dy = toFloat n * sin rad
                -- Nouvelle position après déplacement
                nouvellePos = { x = tortue.x + dx, y = tortue.y - dy }
                -- Crée une ligne du point précédent au nouveau point
                nouvelleLigne = { debut = { x = tortue.x, y = tortue.y }, fin = nouvellePos }
            in
            -- Met à jour la position et ajoute la ligne à la liste
            { tortue | x = nouvellePos.x, y = nouvellePos.y, lignes = nouvelleLigne :: tortue.lignes }

        -- Instruction Left : tourne à gauche
        Left deg ->
            -- Ajoute l'angle (tourner à gauche = augmenter l'angle)
            { tortue | angle = tortue.angle + toFloat deg }

        -- Instruction Right : tourne à droite
        Right deg ->
            -- Soustrait l'angle (tourner à droite = diminuer l'angle)
            { tortue | angle = tortue.angle - toFloat deg }

        -- Instruction Repeat : répète une séquence n fois
        Repeat n list ->
            -- Répète la liste n fois, concatène tout, puis traite
            List.repeat n list
                |> List.concat
                |> (\cmds -> traiter cmds tortue)