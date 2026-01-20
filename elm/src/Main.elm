module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Parsing exposing (Instruction)
import Drawing exposing (afficher)



{-| État de l'application

Champs:
- `saisi`: le texte entré par l'utilisateur (le programme)
- `dessin`: le résultat de l'analyse (liste d'instructions ou message d'erreur)
-}
type alias Model =
    { saisi : String
    , dessin : Result String (List Instruction)
    }


{-| Messages de l'application

- `ModifierSaisi`: l'utilisateur modifie le texte du programme
- `Dessiner`: l'utilisateur appuie sur le bouton "Dessiner"
-}
type Msg
    = ModifierSaisi String
    | Dessiner

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = affichage
        , subscriptions = \_ -> Sub.none
        }


{-| Initialise l'application avec un modèle vide

Retourne:
- Un modèle avec un champ vide et un message initial
- Aucune commande au démarrage
-}
init : () -> (Model, Cmd Msg)
init _ =
    ( { saisi = ""
      , dessin = Err "Entrez un programme"
      }
    , Cmd.none
    )


{-| Traite les messages et met à jour le modèle

Gère deux cas:

1. **ModifierSaisi**: met à jour le texte saisi
2. **Dessiner**: analyse et affiche le programme
-}
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        -- L'utilisateur modifie le texte du programme
        ModifierSaisi saisi ->
            ( { model | saisi = saisi }, Cmd.none )

        -- L'utilisateur clique sur "Dessiner"
        -- On analyse le texte et affiche le résultat immédiatement
        Dessiner ->
            let
                resultat = Parsing.lire model.saisi
            in
            ( { model | dessin = resultat }
            , Cmd.none
            )


{-| Affiche l'interface graphique de l'application

Composants:
- Titre "Dessin TcTurtle"
- Zone de texte pour entrer le programme
- Boutons "Dessiner" et "Zoom auto"
- Zone d'affichage du dessin ou des erreurs

Erreurs:
- Affichées en rouge avec un fond clair
- Contiennent le message d'erreur syntaxique
-}
affichage : Model -> Html Msg
affichage model =
    div
        [ style "font-family" "Comic Sans MS"
        , style "display" "flex"
        , style "flex-direction" "column"
        , style "align-items" "center"
        , style "justify-content" "center"
        , style "min-height" "100vh"
        , style "background" "linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%)"
        ]
        [ -- Titre principal
          h1
            [ style "color" "#333"
            , style "font-size" "2.5em"
            , style "margin-bottom" "30px"
            , style "text-shadow" "0 2px 4px rgba(0,0,0,0.1)"
            ]
            [ text "Turtle Sans MS" ]
        
        -- Section d'entrée : zone de texte + boutons
        -- Contient la textarea pour le programme et les boutons de contrôle
        , div
            [ style "background-color" "white"
            , style "padding" "30px"
            , style "border-radius" "16px"
            , style "box-shadow" "0 8px 32px rgba(0,0,0,0.15)"
            , style "max-width" "600px"
            , style "width" "90%"
            ]
            [ -- Zone de texte pour l'entrée du programme
              textarea
                [ placeholder "Ex: [Repeat 360 [Forward 1, Left 1]]"
                , value model.saisi
                , onInput ModifierSaisi
                , style "width" "100%"
                , style "height" "80px"
                , style "box-sizing" "border-box"
                , style "padding" "12px"
                , style "border" "2px solid #e0e0e0"
                , style "border-radius" "8px"
                , style "font-size" "14px"
                , style "font-family" "Comic Sans MS, monospace"
                , style "resize" "vertical"
                , style "transition" "border-color 0.3s ease"
                ]
                []
            -- Bouton d'action
            , div
                [ style "display" "flex"
                , style "gap" "12px"
                , style "margin-top" "20px"
                , style "justify-content" "center"
                ]
                [ -- Bouton "Dessiner" : lance l'analyse et le rendu
                  button
                    [ onClick Dessiner
                    , style "padding" "12px 28px"
                    , style "background" "linear-gradient(135deg, #ff0000 0%, #5eff00 25%, #4e9acd 50%, #4547d1 75%, #ff00d4 100%)"
                    , style "color" "white"
                    , style "border" "none"
                    , style "border-radius" "8px"
                    , style "cursor" "pointer"
                    , style "font-family" "Comic Sans MS"
                    , style "font-size" "16px"
                    , style "font-weight" "600"
                    , style "box-shadow" "0 4px 12px rgba(0, 0, 0, 0.3)"
                    , style "transition" "all 0.3s ease"
                    ]
                    [ text "Dessiner" ]
                ]
            ]
        
        -- Section d'affichage du résultat
        -- Affiche soit le dessin SVG, soit un message d'erreur
        , div
            [ style "margin-top" "40px"
            , style "padding" "30px"
            , style "background-color" "#ffffff"
            , style "border-radius" "16px"
            , style "box-shadow" "0 8px 32px rgba(0,0,0,0.15)"
            , style "max-width" "900px"
            , style "width" "90%"
            , style "display" "flex"
            , style "justify-content" "center"
            , style "align-items" "center"
            , style "min-height" "500px"
            ]
            [ case model.dessin of
                -- Cas succès : afficher le dessin
                Ok programme ->
                    afficher True programme
                -- Cas erreur : afficher le message d'erreur en rouge
                Err erreur ->
                    div
                        [ style "color" "#d32f2f"
                        , style "font-weight" "bold"
                        , style "padding" "20px"
                        , style "background-color" "#ffebee"
                        , style "border-radius" "8px"
                        , style "border-left" "4px solid #d32f2f"
                        ]
                        [ text erreur ]
            ]
        ]
        
