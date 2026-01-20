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
- `zoomAuto`: active/désactive le zoom automatique pour adapter le dessin
-}
type alias Model =
    { saisi : String
    , dessin : Result String (List Instruction)
    , zoomAuto : Bool
    }


{-| Messages de l'application

- `ModifierSaisi`: l'utilisateur modifie le texte du programme
- `Dessiner`: l'utilisateur appuie sur le bouton "Dessiner"
- `BasculerZoom`: active ou désactive le zoom automatique
-}
type Msg
    = ModifierSaisi String
    | Dessiner
    | BasculerZoom

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
      , zoomAuto = True
      }
    , Cmd.none
    )


{-| Traite les messages et met à jour le modèle

Gère trois cas:

1. **ModifierSaisi**: met à jour le texte saisi
2. **Dessiner**: analyse et affiche le programme
3. **BasculerZoom**: active/désactive le zoom automatique
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

        -- L'utilisateur bascule le zoom automatique
        BasculerZoom ->
            ( { model | zoomAuto = not model.zoomAuto }
            , Cmd.none
            )


{-| Affiche l'interface graphique de l'application

Composants:
- Titre "Dessin TcTurtle"
- Zone de texte pour entrer le programme
- Boutons "Dessiner" et "Zoom auto"
- Zone d'affichage du dessin ou des erreurs
- Temps de traitement affiché en vert après un rendu réussi

Erreurs:
- Affichées en rouge avec un fond clair
- Contiennent le message d'erreur syntaxique
-}
affichage : Model -> Html Msg
affichage model =
    div
        [ style "font-family" "Arial, sans-serif"
        , style "display" "flex"
        , style "flex-direction" "column"
        , style "align-items" "center"
        , style "justify-content" "center"
        , style "min-height" "100vh"
        , style "background-color" "#f0f0f0"
        ]
        [ -- Titre principal
          h1
            [ style "color" "#333" ]
            [ text "Dessin TcTurtle" ]
        
        -- Section d'entrée : zone de texte + boutons
        -- Contient la textarea pour le programme et les boutons de contrôle
        , div
            [ style "background-color" "white"
            , style "padding" "20px"
            , style "border-radius" "8px"
            , style "box-shadow" "0 2px 5px rgba(0,0,0,0.1)"
            , style "max-width" "600px"
            , style "width" "90%"
            ]
            [ -- Zone de texte pour l'entrée du programme
              textarea
                [ placeholder "Ex: [Repeat 4 [Forward 50, Left 90]]"
                , value model.saisi
                , onInput ModifierSaisi
                , style "width" "100%"
                , style "height" "50px"
                , style "box-sizing" "border-box"
                , style "resize" "none"
                ]
                []
            -- Boutons d'action
            , div
                [ style "display" "flex"
                , style "gap" "10px"
                , style "margin-top" "16px"
                ]
                [ -- Bouton "Dessiner" : lance l'analyse et le rendu
                  button
                    [ onClick Dessiner
                    , style "padding" "10px 20px"
                    , style "background-color" "#007BFF"
                    , style "color" "white"
                    , style "border" "none"
                    , style "border-radius" "4px"
                    , style "cursor" "pointer"
                    ]
                    [ text "Dessiner" ]
                -- Bouton "Zoom auto" : bascule le mode zoom
                -- Vert si actif, gris si inactif
                , button
                    [ onClick BasculerZoom
                    , style "padding" "10px 20px"
                    , style "background-color" (if model.zoomAuto then "#28a745" else "#6c757d")
                    , style "color" "white"
                    , style "border" "none"
                    , style "border-radius" "4px"
                    , style "cursor" "pointer"
                    ]
                    [ text ("Zoom auto: " ++ (if model.zoomAuto then "ON" else "OFF")) ]
                ]
            ]
        
        -- Section d'affichage du résultat
        -- Affiche soit le dessin SVG, soit un message d'erreur
        , div
            [ style "margin-top" "30px"
            , style "padding" "20px"
            , style "background-color" "#ffffff"
            , style "border-radius" "8px"
            , style "box-shadow" "0 2px 5px rgba(0,0,0,0.1)"
            ]
            [ case model.dessin of
                -- Cas succès : afficher le dessin
                Ok programme ->
                    afficher model.zoomAuto programme
                -- Cas erreur : afficher le message d'erreur en rouge
                Err erreur ->
                    div
                        [ style "color" "red"
                        , style "font-weight" "bold"
                        , style "padding" "20px"
                        , style "background-color" "#fff0f0"
                        , style "border-radius" "4px"
                        , style "border" "1px solid #ffcccc"
                        ]
                        [ text erreur ]
            ]
        ]
        
