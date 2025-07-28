module Logic.Game exposing (handleBuy, handleSell, handleTravel)

import Logic.Transaction as Transaction

import Models.Planet exposing (Planet)
import Task
import Time
import Types exposing (Model, Msg(..), Asset(..))


getCurrentPlanet : Model -> Maybe Planet
getCurrentPlanet model =
    case model.currentLocation of
        Just (systemName, planetName) ->
            model.starSystems
                |> List.filter (\sys -> sys.name == systemName)
                |> List.head
                |> Maybe.andThen (\sys ->
                    sys.planets
                        |> List.filter (\p -> p.name == planetName)
                        |> List.head
                )
        Nothing ->
            Nothing


handleBuy : String -> Model -> ( Model, Cmd Msg )
handleBuy commodityName model =
    case getCurrentPlanet model of
        Just planet ->
            let
                ( updatedShips, updatedPlayer, updatedPlanet ) =
                    Transaction.buyCommodity commodityName model.ships model.activeShipIndex model.player planet

                updatedStarSystems =
                    case model.currentLocation of
                        Just (systemName, planetName) ->
                            model.starSystems
                                |> List.map (\sys ->
                                    if sys.name == systemName then
                                        { sys | planets = List.map (\p -> if p.name == updatedPlanet.name then updatedPlanet else p) sys.planets }
                                    else
                                        sys
                                )
                        Nothing ->
                            model.starSystems

                newModel =
                    { model
                        | ships = updatedShips
                        , assets = List.map ShipAsset updatedShips
                        , player = updatedPlayer
                        , starSystems = updatedStarSystems
                    }
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

                updatedStarSystems =
                    case model.currentLocation of
                        Just (systemName, planetName) ->
                            model.starSystems
                                |> List.map (\sys ->
                                    if sys.name == systemName then
                                        { sys | planets = List.map (\p -> if p.name == updatedPlanet.name then updatedPlanet else p) sys.planets }
                                    else
                                        sys
                                )
                        Nothing ->
                            model.starSystems

                newModel =
                    { model
                        | ships = updatedShips
                        , assets = List.map ShipAsset updatedShips
                        , player = updatedPlayer
                        , starSystems = updatedStarSystems
                    }
            in
                ( newModel, Cmd.none )

        Nothing ->
            ( model, Cmd.none )


handleTravel : String -> Model -> ( Model, Cmd Msg )
handleTravel destinationName model =
    case model.currentLocation of
        Just (systemName, _) ->
            case List.filter (\sys -> sys.name == systemName) model.starSystems |> List.head of
                Just sys ->
                    case List.filter (\p -> p.name == destinationName) sys.planets |> List.head of
                        Just _ ->
                            let
                                -- For now, travel is instant and time is set to now. You can add duration logic here.
                                updatedShips = model.ships -- (No ship update for simple travel)
                                newTravelState =
                                    { destination = (systemName, destinationName)
                                    , arrivalTime = model.currentTime
                                    , travelDuration = 0
                                    }
                            in
                            ( { model
                                | ships = updatedShips
                                , assets = List.map ShipAsset updatedShips
                                , travelState = Just newTravelState
                                , currentLocation = Nothing
                              }
                            , Time.now |> Task.perform SetCurrentTime
                            )
                        Nothing -> ( model, Cmd.none )
                Nothing -> ( model, Cmd.none )
        Nothing -> ( model, Cmd.none )
