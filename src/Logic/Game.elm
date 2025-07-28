module Logic.Game exposing (handleBuy, handleSell, handleTravel)

import Logic.Transaction as Transaction
import Logic.Travel as Travel
import Models.Planet exposing (Planet)
import Task
import Time
import Types exposing (Model, Msg(..))


getCurrentPlanet : Model -> Maybe Planet
getCurrentPlanet model =
    model.currentLocation
        |> Maybe.andThen
            (\locationName ->
                model.planets
                    |> List.filter (\p -> p.name == locationName)
                    |> List.head
            )


handleBuy : String -> Model -> ( Model, Cmd Msg )
handleBuy commodityName model =
    case getCurrentPlanet model of
        Just planet ->
            let
                ( updatedShips, updatedPlayer, updatedPlanet ) =
                    Transaction.buyCommodity commodityName model.ships model.activeShipIndex model.player planet

                updatedPlanets =
                    model.planets
                        |> List.map (\p -> if p.name == updatedPlanet.name then updatedPlanet else p)

                newModel =
                    { model | ships = updatedShips, player = updatedPlayer, planets = updatedPlanets }
            in
            ( newModel, Cmd.none )

        Nothing ->
            ( model, Cmd.none )


handleSell : String -> Model -> ( Model, Cmd Msg )
handleSell commodityName model =
    case getCurrentPlanet model of
        Just planet ->
            let
                ( updatedShips, updatedPlayer, updatedPlanet ) =
                    Transaction.sellCommodity commodityName model.ships model.activeShipIndex model.player planet

                updatedPlanets =
                    model.planets
                        |> List.map (\p -> if p.name == updatedPlanet.name then updatedPlanet else p)

                newModel =
                    { model | ships = updatedShips, player = updatedPlayer, planets = updatedPlanets }
            in
            ( newModel, Cmd.none )

        Nothing ->
            ( model, Cmd.none )


handleTravel : String -> Model -> ( Model, Cmd Msg )
handleTravel destinationName model =
    case Travel.startTravel destinationName model.ships model.activeShipIndex model.planets model.currentTime of
        Just ( updatedShips, travelState ) ->
            ( { model | ships = updatedShips, travelState = Just travelState, currentLocation = Nothing }, Time.now |> Task.perform SetCurrentTime )

        Nothing ->
            ( model, Cmd.none )
