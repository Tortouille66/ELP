module Validation exposing (ValidationResult, validateCommand, ShapeType(..))

import Parsing exposing (Instruction(..))


{-| Types de formes reconnues -}
type ShapeType
    = Cercle
    | Carré
    | Triangle
    | Étoile
    | FormeInconnue


{-| Résultat de la validation -}
type alias ValidationResult =
    { isValid : Bool
    , shapeType : ShapeType
    , message : String
    }


{-| Valide une commande en vérifiant si elle correspond exactement à un pattern connu

Arguments:
- `instructions`: liste des instructions du programme
- `expectedShapes`: liste des formes attendues pour le niveau
- `expectedSize`: taille attendue (0 si pas de taille unique)

Retourne:
Un ValidationResult indiquant si la commande est valide
-}
validateCommand : List Instruction -> List String -> Int -> ValidationResult
validateCommand instructions expectedShapes expectedSize =
    if List.isEmpty instructions then
        { isValid = False
        , shapeType = FormeInconnue
        , message = "Aucune instruction. Essaie de nouveau !"
        }
    else
        -- Teste tous les patterns possibles
        let
            testCercleListe = testCerclePatterns instructions expectedSize
            testCarreListe = testCarrePatterns instructions expectedSize
            testTriangleListe = testTrianglePatterns instructions expectedSize
            testEtoileListe = testEtoilePatterns instructions expectedSize
            
            -- Combine tous les résultats valides
            allValid = 
                (if testCercleListe.isValid then [testCercleListe] else [])
                ++ (if testCarreListe.isValid then [testCarreListe] else [])
                ++ (if testTriangleListe.isValid then [testTriangleListe] else [])
                ++ (if testEtoileListe.isValid then [testEtoileListe] else [])
        in
        case List.head allValid of
            Just result ->
                -- Vérifie si la forme est attendue
                let
                    shapeName = shapeTypeToString result.shapeType
                in
                if List.member shapeName expectedShapes then
                    result
                else
                    { isValid = False
                    , shapeType = result.shapeType
                    , message = "Cette forme n'est pas attendue pour ce niveau."
                    }
            Nothing ->
                { isValid = False
                , shapeType = FormeInconnue
                , message = "Commande non reconnue. Essaie: Cercle, Carré, Triangle ou Étoile !"
                }


{-| Teste les patterns pour un cercle
Patterns valides: [Repeat 360 [Forward n, Left 1]]
-}
testCerclePatterns : List Instruction -> Int -> ValidationResult
testCerclePatterns instructions expectedSize =
    case instructions of
        [Repeat 360 innerInstructions] ->
            case innerInstructions of
                [Forward dist, Left 1] ->
                    if 15<=dist <= 16 then
                        { isValid = True
                        , shapeType = Cercle
                        , message = "Cercle ✓"
                        }
                    else
                        { isValid = False
                        , shapeType = Cercle
                        , message = "Taille incorrecte"
                        }
                

                [Forward dist, Right 1] ->
                    if 15<=dist <= 16 then
                        { isValid = True
                        , shapeType = Cercle
                        , message = "Cercle ✓"
                        }
                    else
                        { isValid = False
                        , shapeType = Cercle
                        , message = "Taille incorrecte"
                        }
                _ -> { isValid = False, shapeType = FormeInconnue, message = "" }
        _ -> { isValid = False, shapeType = FormeInconnue, message = "" }


{-| Teste les patterns pour un carré
Patterns valides:
- [Repeat 4 [Forward n, Left 90]]
- [Repeat 4 [Forward n, Right 90]]
- [Forward n, Left 90, Forward n, Left 90, Forward n, Left 90, Forward n]
- [Forward n, Right 90, Forward n, Right 90, Forward n, Right 90, Forward n]
-}
testCarrePatterns : List Instruction -> Int -> ValidationResult
testCarrePatterns instructions expectedSize =
    case instructions of
        -- Pattern 1: Repeat 4 [Forward n, Left 90]
        [Repeat 4 innerInstructions] ->
            case innerInstructions of
                [Forward dist, Left 90] ->
                    if dist == 80 then
                        { isValid = True
                        , shapeType = Carré
                        , message = "Carré ✓"
                        }
                    else
                        { isValid = False
                        , shapeType = Carré
                        , message = "Taille incorrecte"
                        }
                
                [Forward dist, Right 90] ->
                    if dist == 80 then
                        { isValid = True
                        , shapeType = Carré
                        , message = "Carré ✓"
                        }
                    else
                        { isValid = False
                        , shapeType = Carré
                        , message = "Taille incorrecte"
                        }
                _ -> { isValid = False, shapeType = FormeInconnue, message = "" }
        -- Pattern 3: Forward n, Left 90, Forward n, Left 90, Forward n, Left 90, Forward n
        [Forward d1, Left 90, Forward d2, Left 90, Forward d3, Left 90, Forward d4] ->
            if d1 == d2 && d2 == d3 && d3 == d4 then
                if d1 == 90 then
                    { isValid = True
                    , shapeType = Carré
                    , message = "Carré ✓"
                    }
                else
                    { isValid = False
                    , shapeType = Carré
                    , message = "Taille incorrecte"
                    }
            else
                { isValid = False, shapeType = FormeInconnue, message = "" }
        -- Pattern 4: Forward n, Right 90, Forward n, Right 90, Forward n, Right 90, Forward n
        [Forward d1, Right 90, Forward d2, Right 90, Forward d3, Right 90, Forward d4] ->
            if d1 == d2 && d2 == d3 && d3 == d4 then
                if d1 == 80 then
                    { isValid = True
                    , shapeType = Carré
                    , message = "Carré ✓"
                    }
                else
                    { isValid = False
                    , shapeType = Carré
                    , message = "Taille incorrecte"
                    }
            else
                { isValid = False, shapeType = FormeInconnue, message = "" }
        _ -> { isValid = False, shapeType = FormeInconnue, message = "" }


{-| Teste les patterns pour un triangle
Patterns valides:
- [Repeat 3 [Forward n, Left 120]]
- [Repeat 3 [Forward n, Right 120]]
- [Forward n, Left 120, Forward n, Left 120, Forward n]
- [Forward n, Right 120, Forward n, Right 120, Forward n]
-}
testTrianglePatterns : List Instruction -> Int -> ValidationResult
testTrianglePatterns instructions expectedSize =
    case instructions of
        -- Pattern 1: Repeat 3 [Forward n, Left 120]
        [Repeat 3 innerInstructions] ->
            case innerInstructions of
                [Forward dist, Left 120] ->
                    if expectedSize == 0 || dist == expectedSize then
                        { isValid = True
                        , shapeType = Triangle
                        , message = "Triangle ✓"
                        }
                    else
                        { isValid = False
                        , shapeType = Triangle
                        , message = "Taille incorrecte (attendu: " ++ String.fromInt expectedSize ++ ")"
                        }
                -- Pattern 2: Repeat 3 [Forward n, Right 120]
                [Forward dist, Right 120] ->
                    if expectedSize == 0 || dist == expectedSize then
                        { isValid = True
                        , shapeType = Triangle
                        , message = "Triangle ✓"
                        }
                    else
                        { isValid = False
                        , shapeType = Triangle
                        , message = "Taille incorrecte (attendu: " ++ String.fromInt expectedSize ++ ")"
                        }
                _ -> { isValid = False, shapeType = FormeInconnue, message = "" }
        -- Pattern 3: Forward n, Left 120, Forward n, Left 120, Forward n
        [Forward d1, Left 120, Forward d2, Left 120, Forward d3] ->
            if d1 == d2 && d2 == d3 then
                if expectedSize == 0 || d1 == expectedSize then
                    { isValid = True
                    , shapeType = Triangle
                    , message = "Triangle ✓"
                    }
                else
                    { isValid = False
                    , shapeType = Triangle
                    , message = "Taille incorrecte (attendu: " ++ String.fromInt expectedSize ++ ")"
                    }
            else
                { isValid = False, shapeType = FormeInconnue, message = "" }
        -- Pattern 4: Forward n, Right 120, Forward n, Right 120, Forward n
        [Forward d1, Right 120, Forward d2, Right 120, Forward d3] ->
            if d1 == d2 && d2 == d3 then
                if expectedSize == 0 || d1 == expectedSize then
                    { isValid = True
                    , shapeType = Triangle
                    , message = "Triangle ✓"
                    }
                else
                    { isValid = False
                    , shapeType = Triangle
                    , message = "Taille incorrecte (attendu: " ++ String.fromInt expectedSize ++ ")"
                    }
            else
                { isValid = False, shapeType = FormeInconnue, message = "" }
        _ -> { isValid = False, shapeType = FormeInconnue, message = "" }


{-| Teste les patterns pour une étoile à 5 branches
Patterns valides:
- [Repeat 5 [Forward n, Left 144, Forward n, Left 36]]
- [Repeat 5 [Forward n, Right 144, Forward n, Right 36]]
-}
testEtoilePatterns : List Instruction -> Int -> ValidationResult
testEtoilePatterns instructions expectedSize =
    case instructions of
        -- Pattern 1: Repeat 5 [Forward n, Left 144, Forward n, Left 36]
        [Repeat 5 innerInstructions] ->
            case innerInstructions of
                [Forward d1, Left 144, Forward d2, Left 36] ->
                    if d1 == d2 then
                        if expectedSize == 0 || d1 == expectedSize then
                            { isValid = True
                            , shapeType = Étoile
                            , message = "Étoile ✓"
                            }
                        else
                            { isValid = False
                            , shapeType = Étoile
                            , message = "Taille incorrecte (attendu: " ++ String.fromInt expectedSize ++ ")"
                            }
                    else
                        { isValid = False, shapeType = FormeInconnue, message = "" }
                -- Pattern 2: Repeat 5 [Forward n, Right 144, Forward n, Right 36]
                [Forward d1, Right 144, Forward d2, Right 36] ->
                    if d1 == d2 then
                        if expectedSize == 0 || d1 == expectedSize then
                            { isValid = True
                            , shapeType = Étoile
                            , message = "Étoile ✓"
                            }
                        else
                            { isValid = False
                            , shapeType = Étoile
                            , message = "Taille incorrecte (attendu: " ++ String.fromInt expectedSize ++ ")"
                            }
                    else
                        { isValid = False, shapeType = FormeInconnue, message = "" }
                _ -> { isValid = False, shapeType = FormeInconnue, message = "" }
        _ -> { isValid = False, shapeType = FormeInconnue, message = "" }


{-| Convertit un ShapeType en String -}
shapeTypeToString : ShapeType -> String
shapeTypeToString shape =
    case shape of
        Cercle -> "Cercle"
        Carré -> "Carré"
        Triangle -> "Triangle"
        Étoile -> "Étoile"
        FormeInconnue -> "Forme inconnue"
