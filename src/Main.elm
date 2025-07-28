module Main exposing (..)

import Browser
import Dict
import Html exposing (Html, div, hr, p, text)
import View.Ownership exposing (viewOwnership)
import View.ControlPanel
import Logic.Event as Event
import Logic.Game as Game
import Models.Planet exposing (Planet)
import Models.Player exposing (Player)
import Models.Ship exposing (Ship, ShipType(..))
import Time
import Types exposing (Model, Msg(..))



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
        , planets = initialPlanets
        , activeShipIndex = 0
        , currentLocation = Just "Earth"
        , travelState = Nothing
        , currentTime = Time.millisToPosix 0
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

initialPlanets : List Planet
initialPlanets = 
    [ { name = "Earth", market = Dict.fromList [("Food", { price = 10, stock = 100 }), ("Water", { price = 5, stock = 200 })] }
    , { name = "Mars", market = Dict.fromList [("Ore", { price = 50, stock = 50 }), ("Robots", { price = 150, stock = 10 })] }
    , { name = "Jupiter", market = Dict.fromList [("Gas", { price = 20, stock = 1000 })] }
    ]


-- UPDATE
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

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
    let


        activeShip =
            List.head (List.drop model.activeShipIndex model.ships)
    in
    div []
        [ p [] [ text ("Player: " ++ model.player.name) ]
        , p [] [ text ("Credits: " ++ String.fromInt model.player.credits) ]
        , hr [] []
        , case activeShip of
            Just ship ->
                View.ControlPanel.viewControlPanel
                    { activeShip = ship
                    , currentLocation = model.currentLocation
                    , planets = model.planets
                    , onTravel = TravelTo
                    , onBuy = BuyCommodity
                    , onSell = SellCommodity
                    }
            Nothing ->
                div [] [ text "No active ship." ]
        , hr [] []
        , viewOwnership model.activeShipIndex SelectShip model.ships
        ]


shipTypeToString : ShipType -> String
shipTypeToString shipType =
    case shipType of
        Cargo -> "Cargo"
        Explorer -> "Explorer"
        Military -> "Military"
