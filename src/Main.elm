module Main exposing (..)

import Browser
import Dict
import Html exposing (Html, div, hr, p, text, button)
import Html.Attributes
import Html.Events exposing (onClick)
import View.Ownership exposing (viewOwnership)
import View.ControlPanel
import Logic.Event as Event
import Logic.Game as Game

import Models.Player exposing (Player)
import Models.Ship exposing (Ship, ShipType(..))
import Models.StarSystem exposing (StarSystem)
import Time
import Types exposing (Model, Msg(..), Asset(..))



-- MAIN
main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


-- MODEL
init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    {
        player = initialPlayer
        , ships = initialShips
        , assets = List.map ShipAsset initialShips
        , activeAssetIndex = 0
        , starSystems = initialStarSystems
        , activeShipIndex = 0 -- legacy
        , currentLocation = Just ("Sol", "Earth")
        , travelState = Nothing
        , currentTime = Time.millisToPosix 0
        , messages = ["Welcome to Galactic Trader!", "Docked at Earth in the Sol system."]
    }


initialPlayer : Player
initialPlayer = { name = "Captain Sergut", credits = 1000 }


initialShips : List Ship
initialShips =
    [ { name = "Stardust Cruiser"
      , shipType = Cargo
      , cargoCapacity = 10
      , cargo = Dict.fromList [("Food", 5)]
      , fuel = 100
      , fuelCapacity = 100
      }
    , { name = "Star Explorer"
      , shipType = Explorer
      , cargoCapacity = 5
      , cargo = Dict.empty
      , fuel = 80
      , fuelCapacity = 80
      }
    , { name = "Defender"
      , shipType = Military
      , cargoCapacity = 8
      , cargo = Dict.empty
      , fuel = 120
      , fuelCapacity = 120
      }
    ]

initialStarSystems : List StarSystem
initialStarSystems =
    [ { name = "Sol"
      , planets =
            [ { name = "Earth", market = Dict.fromList [("Food", { price = 10, stock = 100 }), ("Water", { price = 5, stock = 200 })] }
            , { name = "Mars", market = Dict.fromList [("Ore", { price = 50, stock = 50 }), ("Robots", { price = 150, stock = 10 })] }
            , { name = "Jupiter", market = Dict.fromList [("Gas", { price = 20, stock = 1000 })] }
            ]
      , explored = True
      }
    , { name = "Alpha Centauri"
      , planets = [ { name = "Proxima b", market = Dict.empty } ]
      , explored = False
      }
    ]


-- UPDATE
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SelectAsset idx ->
            ( { model | activeAssetIndex = idx }, Cmd.none )

        SetCurrentTime newTime ->
            ( { model | currentTime = newTime }, Cmd.none )

        Tick newTime ->
            ( Event.handleTick newTime model, Cmd.none )

        BuyCommodity commodityName ->
            Game.handleBuy commodityName model

        SellCommodity commodityName ->
            Game.handleSell commodityName model

        TravelTo destinationName ->
            Game.handleTravel destinationName model

        SelectShip idx ->
            ( { model | activeShipIndex = idx }, Cmd.none )


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
    case model.travelState of
        Just _ ->
            Time.every 1000 Tick

        Nothing ->
            Sub.none


-- VIEW
view : Model -> Html Msg
view model =
    div []
        [ div [] [ text "Galactic Trader" ]
        , hr [] []
        , div []
            [ p [] [ text ("Player: " ++ model.player.name) ]
            , p [] [ text ("Credits: " ++ String.fromInt model.player.credits) ]
            ]
        , hr [] []
        , viewAssetSelector model.assets model.activeAssetIndex
        , hr [] []
        , viewCurrentAssetPanel model.assets model.activeAssetIndex model.starSystems model.currentLocation
        , hr [] []
        , viewMessageLog model.messages
        ]


viewMessageLog : List String -> Html msg
viewMessageLog messages =
    div 
        [ Html.Attributes.style "max-height" "150px"
        , Html.Attributes.style "overflow-y" "auto"
        , Html.Attributes.style "border" "1px solid #ccc"
        , Html.Attributes.style "padding" "8px"
        , Html.Attributes.style "margin-top" "16px"
        ]
        (List.map (\msg -> div [] [ text msg ]) (List.reverse messages))


shipTypeToString : ShipType -> String
shipTypeToString shipType =
    case shipType of
        Cargo -> "Cargo"
        Explorer -> "Explorer"
        Military -> "Military"


viewAssetSelector : List Asset -> Int -> Html Msg
viewAssetSelector assets activeIdx =
    div []
        (List.indexedMap
            (\i asset ->
                let
                    (name, isActive) =
                        case asset of
                            ShipAsset ship -> (ship.name, i == activeIdx)
                            ArtifactAsset _ -> ("Artifact", i == activeIdx)
                            StationAsset _ -> ("Station", i == activeIdx)
                in
                div []
                    [ button [ Html.Events.onClick (SelectAsset i) ] [ text name ]
                    , if isActive then text " A" else text ""
                    ]
            )
            assets
        )

viewCurrentAssetPanel : List Asset -> Int -> List StarSystem -> Maybe (String, String) -> Html Msg
viewCurrentAssetPanel assets activeIdx starSystems currentLocation =
    case List.drop activeIdx assets |> List.head of
        Just asset ->
            case asset of
                ShipAsset ship ->
                    -- Show the real ship control panel
                    View.ControlPanel.viewControlPanel
                        { activeShip = ship
                        , starSystems = starSystems
                        , currentLocation = currentLocation
                        , onTravel = TravelTo
                        , onBuy = BuyCommodity
                        , onSell = SellCommodity
                        }
                ArtifactAsset _ ->
                    div [] [ text "Artifact control panel (empty)" ]
                StationAsset _ ->
                    div [] [ text "Station control panel (empty)" ]
        Nothing -> text "No asset selected"
