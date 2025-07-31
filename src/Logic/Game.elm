module Logic.Game exposing (handleBuy, handleSell, handleTravel)

import Logic.Transaction as Transaction exposing (TransactionError(..))
import Models.Planet exposing (Planet)
import Task
import Time
import Types exposing (Model, Msg(..), Asset(..))


getCurrentPlanet : Model -> Maybe Planet
getCurrentPlanet model =
    model.currentLocation
        |> Maybe.andThen (\(systemName, planetName) ->
            model.starSystems
                |> List.filter (\sys -> sys.name == systemName)
                |> List.head
                |> Maybe.andThen (\sys ->
                    sys.planets
                        |> List.filter (\p -> p.name == planetName)
                        |> List.head
                )
        )


handleBuy : String -> Model -> ( Model, Cmd Msg )
handleBuy goodName model =
    case getCurrentPlanet model of
        Just planet ->
            let
                result = Transaction.buyGood goodName 1 model.ships model.activeShipIndex model.player planet
                
                -- Update star systems if the transaction was successful
                updatedStarSystems =
                    if result.success then
                        case model.currentLocation of
                            Just (systemName, _) ->
                                model.starSystems
                                    |> List.map (\sys ->
                                        if sys.name == systemName then
                                            { sys | planets = List.map (\p -> if p.name == result.updatedPlanet.name then result.updatedPlanet else p) sys.planets }
                                        else
                                            sys
                                    )
                            Nothing ->
                                model.starSystems
                    else
                        model.starSystems
                
                -- Add error message if transaction failed
                newMessage =
                    if not result.success then
                        case result.error of
                            Just NotEnoughCredits -> "Not enough credits to buy " ++ goodName
                            Just NotEnoughStock -> "Not enough stock of " ++ goodName
                            Just NotEnoughCargoSpace -> "Not enough cargo space for " ++ goodName
                            Just ItemNotInCargo -> "You don't have any " ++ goodName ++ " to sell"
                            Just ItemNotInMarket -> goodName ++ " is not available in this market"
                            Just InvalidShip -> "No valid ship selected"
                            Just InvalidQuantity -> "Invalid quantity for " ++ goodName
                            Just TradeOfferExpired -> "Trade offer expired"
                            Just TradeOfferNotFound -> "Trade offer not found"
                            Just TradeOfferInvalid -> "Invalid trade offer"
                            Just TradeWithSelf -> "Cannot trade with yourself"
                            Nothing -> "Unknown error occurred"
                    else
                        "Bought 1 " ++ goodName
                
                updatedMessages = List.take 10 (newMessage :: model.messages)
                
                newModel =
                    { model
                        | ships = result.updatedShips
                        , assets = List.map ShipAsset result.updatedShips
                        , player = result.updatedPlayer
                        , starSystems = updatedStarSystems
                        , messages = updatedMessages
                    }
            in
            ( newModel, Cmd.none )
            
        Nothing ->
            ( { model | messages = "Not at a valid location" :: model.messages }
            , Cmd.none
            )


handleSell : String -> Model -> ( Model, Cmd Msg )
handleSell goodName model =
    case getCurrentPlanet model of
        Just planet ->
            let
                result = Transaction.sellGood goodName 1 model.ships model.activeShipIndex model.player planet
                
                -- Update star systems if the transaction was successful
                updatedStarSystems =
                    if result.success then
                        case model.currentLocation of
                            Just (systemName, _) ->
                                model.starSystems
                                    |> List.map (\sys ->
                                        if sys.name == systemName then
                                            { sys | planets = List.map (\p -> if p.name == result.updatedPlanet.name then result.updatedPlanet else p) sys.planets }
                                        else
                                            sys
                                    )
                            Nothing ->
                                model.starSystems
                    else
                        model.starSystems
                
                -- Add error message if transaction failed
                newMessage =
                    if not result.success then
                        case result.error of
                            Just ItemNotInCargo -> "You don't have any " ++ goodName ++ " to sell"
                            Just ItemNotInMarket -> "Can't sell " ++ goodName ++ " in this market"
                            Just InvalidShip -> "No valid ship selected"
                            Just NotEnoughCredits -> "Not enough credits"
                            Just NotEnoughStock -> "Not enough stock"
                            Just NotEnoughCargoSpace -> "Not enough cargo space"
                            Just InvalidQuantity -> "Invalid quantity for " ++ goodName
                            Just TradeOfferExpired -> "Trade offer expired"
                            Just TradeOfferNotFound -> "Trade offer not found"
                            Just TradeOfferInvalid -> "Invalid trade offer"
                            Just TradeWithSelf -> "Cannot trade with yourself"
                            Nothing -> "Unknown error occurred"
                    else
                        "Sold 1 " ++ goodName
                
                updatedMessages = List.take 10 (newMessage :: model.messages)
                
                newModel =
                    { model
                        | ships = result.updatedShips
                        , assets = List.map ShipAsset result.updatedShips
                        , player = result.updatedPlayer
                        , starSystems = updatedStarSystems
                        , messages = updatedMessages
                    }
            in
            ( newModel, Cmd.none )
            
        Nothing ->
            ( { model | messages = "Not at a valid location" :: model.messages }
            , Cmd.none
            )


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
