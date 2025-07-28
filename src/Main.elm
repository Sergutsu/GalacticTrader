module Main exposing (..)

import Browser
import Dict
import Html exposing (Html, div, hr, p, text)
import View.Market exposing (viewMarket)
import View.Navigation exposing (viewNavigation)
import View.Ownership exposing (viewOwnership)
import Logic.Event as Event
import Logic.Game as Game
import Models.Planet exposing (Planet)
import Models.Player exposing (Player)
import Models.Ship exposing (Ship)
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
initialShips = [{ name = "Stardust Cruiser", cargo = Dict.fromList [("Food", 5)], cargoCapacity = 10, fuel = 100, fuelCapacity = 100 }]

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
        currentPlanet =
            model.currentLocation
                |> Maybe.andThen
                    (\locationName ->
                        List.head (List.filter (\p -> p.name == locationName) model.planets)
                    )

        activeShip =
            List.head (List.drop model.activeShipIndex model.ships)
    in
    div []
        [ p [] [ text ("Player: " ++ model.player.name) ]
        , p [] [ text ("Credits: " ++ String.fromInt model.player.credits) ]
        , hr [] []
        , case activeShip of
            Just ship ->
                div []
                    [ p [] [ text ("Active Ship: " ++ ship.name) ]
                    , p [] [ text ("Fuel: " ++ String.fromInt ship.fuel ++ "/" ++ String.fromInt ship.fuelCapacity) ]
                    ]

            Nothing ->
                div [] [ text "No active ship." ]
        , hr [] []
        , case currentPlanet of
            Just planet ->
                div []
                    [ p [] [ text ("Location: " ++ planet.name) ]
                    , viewMarket BuyCommodity SellCommodity planet
                    ]

            Nothing ->
                div [] [ text "Lost in space." ]
        , hr [] []
        , viewOwnership model.ships
        , hr [] []
        , viewNavigation TravelTo model.currentLocation model.planets
        ]

