module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Parsing exposing (Instruction)
import Drawing exposing (afficher, traiter)
import Levels exposing (GameMode(..), getLevelDescription, getTotalLevels)
import Validation exposing (validateCommand)



{-| État de l'application

Champs:
- `saisi`: le texte entré par l'utilisateur (le programme)
- `dessin`: le résultat de l'analyse (liste d'instructions ou message d'erreur)
- `gameMode`: mode de jeu (FreeMode ou LevelMode avec le numéro)
- `currentLevel`: numéro du niveau actuel (0 si FreeMode)
- `levelMessage`: message de feedback pour le niveau
- `showLevelInfo`: true si on affiche les informations du niveau
-}
type alias Model =
    { saisi : String
    , dessin : Result String (List Instruction)
    , gameMode : GameMode
    , currentLevel : Int
    , levelMessage : String
    , showLevelInfo : Bool
    }


{-| Messages de l'application

- `ModifierSaisi`: l'utilisateur modifie le texte du programme
- `Dessiner`: l'utilisateur appuie sur le bouton "Dessiner"
- `DemarrerMode`: l'utilisateur choisit un mode (FreeMode ou LevelMode)
- `ProchainNiveau`: passer au niveau suivant
- `NiveauPrecedent`: revenir au niveau précédent
- `AfficherInfoNiveau`: afficher/masquer les infos du niveau
-}
type Msg
    = ModifierSaisi String
    | Dessiner
    | DemarrerFreeMode
    | DemarrerLevelMode
    | ProchainNiveau
    | NiveauPrecedent
    | AfficherInfoNiveau

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
      , gameMode = FreeMode
      , currentLevel = 1
      , levelMessage = ""
      , showLevelInfo = False
      }
    , Cmd.none
    )


{-| Traite les messages et met à jour le modèle

Gère plusieurs cas:

1. **ModifierSaisi**: met à jour le texte saisi
2. **Dessiner**: analyse et affiche le programme
3. **DemarrerFreeMode**: lance le mode libre
4. **DemarrerLevelMode**: lance le mode niveaux
5. **ProchainNiveau**: passe au niveau suivant
6. **NiveauPrecedent**: revient au niveau précédent
7. **AfficherInfoNiveau**: affiche/masque les infos
-}
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        -- L'utilisateur modifie le texte du programme
        ModifierSaisi saisi ->
            ( { model | saisi = saisi }, Cmd.none )

        -- L'utilisateur clique sur "Dessiner"
        Dessiner ->
            let
                resultat = Parsing.lire model.saisi
                validationMessage =
                    case resultat of
                        Ok instructions ->
                            case model.gameMode of
                                FreeMode ->
                                    -- En mode libre, on vérifie juste que c'est un dessin valide
                                    let
                                        validation = validateCommand instructions [] 0
                                    in
                                    "Dessin créé ! " ++ validation.message
                                LevelMode _ ->
                                    -- En mode niveau, on récupère les infos du niveau et on valide
                                    case Levels.getLevel model.currentLevel of
                                        Just level ->
                                            let
                                                validation = validateCommand instructions level.formes level.taille
                                            in
                                            if validation.isValid then
                                                "Bravo ! Niveau complété ! " ++ validation.message
                                            else
                                                "NUUUUL !" ++ validation.message
                                        Nothing ->
                                            "Erreur: niveau introuvable"
                        Err _ ->
                            ""
            in
            ( { model | dessin = resultat, levelMessage = validationMessage }
            , Cmd.none
            )

        -- Démarrer le mode libre
        DemarrerFreeMode ->
            ( { model 
              | gameMode = FreeMode
              , levelMessage = "Mode libre activé ! Dessine ce que tu veux"
              , saisi = ""
              , dessin = Err "Mode libre"
              }
            , Cmd.none
            )

        -- Démarrer le mode niveaux
        DemarrerLevelMode ->
            let
                descr = getLevelDescription 1
            in
            ( { model 
              | gameMode = LevelMode 1
              , currentLevel = 1
              , levelMessage = "Mode niveaux activé ! Commence au niveau 1"
              , showLevelInfo = True
              , saisi = ""
              , dessin = Err descr
              }
            , Cmd.none
            )

        -- Passer au niveau suivant
        ProchainNiveau ->
            if model.currentLevel < getTotalLevels then
                let
                    newLevel = model.currentLevel + 1
                    levelDescr = getLevelDescription newLevel
                in
                ( { model 
                  | currentLevel = newLevel
                  , levelMessage = "Niveau " ++ String.fromInt newLevel ++ " débloqué !"
                  , dessin = Err levelDescr
                  , saisi = ""
                  }
                , Cmd.none
                )
            else
                ( { model | levelMessage = "Tu as fini tous les niveaux ! Tu est le GOAT de TC" }
                , Cmd.none
                )

        -- Revenir au niveau précédent
        NiveauPrecedent ->
            if model.currentLevel > 1 then
                let
                    newLevel = model.currentLevel - 1
                    levelDescr = getLevelDescription newLevel
                in
                ( { model 
                  | currentLevel = newLevel
                  , levelMessage = "Retour au niveau " ++ String.fromInt newLevel
                  , dessin = Err levelDescr
                  , saisi = ""
                  }
                , Cmd.none
                )
            else
                ( { model | levelMessage = "Tu es déjà au premier niveau" }
                , Cmd.none
                )

        -- Afficher/masquer les infos
        AfficherInfoNiveau ->
            ( { model | showLevelInfo = not model.showLevelInfo }
            , Cmd.none
            )


{-| Retourne la couleur du bouton selon le mode actif -}
getButtonColor : GameMode -> GameMode -> String
getButtonColor currentMode buttonMode =
    case (currentMode, buttonMode) of
        (FreeMode, FreeMode) -> "#4CAF50"
        (LevelMode _, LevelMode _) -> "#2196F3"
        _ -> "#cccccc"


{-| Affiche l'interface graphique de l'application

Composants:
- Titre principal
- Sélecteur de mode (Libre ou Niveaux)
- Zone de texte pour l'entrée du programme
- Affichage du dessin ou des erreurs
- Messages de feedback
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
        , style "background" "transparent"
        , style "padding" "20px"
        ]
        [ -- Titre principal
          h1
            [ style "color" "#333"
            , style "font-size" "2.5em"
            , style "margin-bottom" "20px"
            , style "text-shadow" "0 2px 4px rgba(0,0,0,0.1)"
            ]
            [ text "Turtle Sans MS" ]
        
        -- Affichage du mode actuel
        , div
            [ style "background-color" "white"
            , style "padding" "20px"
            , style "border-radius" "12px"
            , style "box-shadow" "0 4px 16px rgba(0,0,0,0.1)"
            , style "margin-bottom" "20px"
            , style "min-width" "500px"
            ]
            [ case model.gameMode of
                FreeMode ->
                    div
                        [ style "color" "#4CAF50"
                        , style "font-size" "18px"
                        , style "font-weight" "bold"
                        , style "text-align" "center"
                        ]
                        [ text "Mode Libre " ]
                LevelMode _ ->
                    div
                        [ style "display" "flex"
                        , style "justify-content" "space-between"
                        , style "align-items" "center"
                        ]
                        [ button
                            [ onClick NiveauPrecedent
                            , style "padding" "8px 16px"
                            , style "background-color" "#FF9800"
                            , style "color" "white"
                            , style "border" "none"
                            , style "border-radius" "6px"
                            , style "cursor" "pointer"
                            , style "font-weight" "bold"
                            ]
                            [ text "◀ Précédent" ]
                        , div
                            [ style "font-weight" "bold"
                            , style "font-size" "18px"
                            , style "color" "#2196F3"
                            ]
                            [ text ("Niveau " ++ String.fromInt model.currentLevel ++ " / " ++ String.fromInt getTotalLevels) ]
                        , button
                            [ onClick ProchainNiveau
                            , style "padding" "8px 16px"
                            , style "background-color" "#4CAF50"
                            , style "color" "white"
                            , style "border" "none"
                            , style "border-radius" "6px"
                            , style "cursor" "pointer"
                            , style "font-weight" "bold"
                            ]
                            [ text "Suivant ▶" ]
                        ]
            ]
        
        -- Sélecteur de mode
        , div
            [ style "display" "flex"
            , style "gap" "20px"
            , style "margin-bottom" "20px"
            ]
            [ button
                [ onClick DemarrerFreeMode
                , style "padding" "12px 28px"
                , style "background-color" (getButtonColor model.gameMode FreeMode)
                , style "color" "white"
                , style "border" "none"
                , style "border-radius" "8px"
                , style "cursor" "pointer"
                , style "font-family" "Comic Sans MS"
                , style "font-size" "16px"
                , style "font-weight" "600"
                , style "box-shadow" "0 4px 12px rgba(0, 0, 0, 0.2)"
                ]
                [ text "Mode Libre " ]
            , button
                [ onClick DemarrerLevelMode
                , style "padding" "12px 28px"
                , style "background-color" (getButtonColor model.gameMode (LevelMode 1))
                , style "color" "white"
                , style "border" "none"
                , style "border-radius" "8px"
                , style "cursor" "pointer"
                , style "font-family" "Comic Sans MS"
                , style "font-size" "16px"
                , style "font-weight" "600"
                , style "box-shadow" "0 4px 12px rgba(0, 0, 0, 0.2)"
                ]
                [ text "Mode Niveaux" ]
            ]
        
        -- Section d'entrée
        , div
            [ style "background-color" "white"
            , style "padding" "30px"
            , style "border-radius" "16px"
            , style "box-shadow" "0 8px 32px rgba(0,0,0,0.15)"
            , style "max-width" "600px"
            , style "width" "100%"
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
                [ button
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
                    [ text "Dessiner " ]
                ]
            ]
        
        -- Affichage des infos du niveau
        , if model.showLevelInfo then
            div
                [ style "background-color" "white"
                , style "padding" "20px"
                , style "border-radius" "12px"
                , style "box-shadow" "0 4px 16px rgba(0,0,0,0.1)"
                , style "max-width" "600px"
                , style "width" "100%"
                , style "margin-top" "20px"
                , style "border-left" "4px solid #2196F3"
                ]
                [ case model.gameMode of
                    FreeMode ->
                        div
                            [ style "color" "#333"
                            , style "line-height" "1.6"
                            ]
                            [ text "Mode libre: Crée ce que tu veux avec tes propres commandes!"
                            ]
                    LevelMode _ ->
                        div
                            [ style "color" "#333"
                            , style "line-height" "1.6"
                            , style "white-space" "pre-wrap"
                            ]
                            [ text (getLevelDescription model.currentLevel) ]
                ]
          else
            text ""
        
        -- Message de feedback (masqué en mode Libre)
        , if model.levelMessage /= "" && model.gameMode /= FreeMode then
            div
                [ style "background-color" "white"
                , style "padding" "15px"
                , style "border-radius" "10px"
                , style "box-shadow" "0 4px 12px rgba(0,0,0,0.1)"
                , style "max-width" "600px"
                , style "width" "100%"
                , style "margin-top" "15px"
                , style "text-align" "center"
                , style "color" (if String.contains "✓" model.levelMessage || String.contains "" model.levelMessage then "#4CAF50" else "#FF9800")
                , style "font-weight" "bold"
                ]
                [ text model.levelMessage ]          else
            text ""
        
        -- Section d'affichage du résultat
        , div
            [ style "margin-top" "40px"
            , style "padding" "30px"
            , style "background-color" "#ffffff"
            , style "border-radius" "16px"
            , style "box-shadow" "0 8px 32px rgba(0,0,0,0.15)"
            , style "max-width" "900px"
            , style "width" "100%"
            , style "display" "flex"
            , style "justify-content" "center"
            , style "align-items" "center"
            , style "min-height" "500px"
            ]
            [ case model.dessin of
                Ok programme ->
                    afficher True programme
                Err erreur ->
                    div
                        [ style "color" "#d32f2f"
                        , style "font-weight" "bold"
                        , style "padding" "20px"
                        , style "background-color" "#ffebee"
                        , style "border-radius" "8px"
                        , style "border-left" "4px solid #d32f2f"
                        , style "white-space" "pre-wrap"
                        , style "max-height" "300px"
                        , style "overflow-y" "auto"
                        ]
                        [ text erreur ]
            ]
        ]

        
