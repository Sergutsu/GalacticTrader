module Logic.Transaction exposing (buyGood, sellGood, TransactionError(..))

import Dict exposing (Dict)
import Logic.Ship as ShipLogic
import Models.Good exposing (Good)
import Models.Planet exposing (Planet)
import Models.Player exposing (Player)
import Models.Ship exposing (Ship)


type TransactionError
    = NotEnoughCredits
    | NotEnoughStock
    | NotEnoughCargoSpace
    | ItemNotInCargo
    | ItemNotInMarket
    | InvalidShip


type alias TransactionResult =
    { success : Bool
    , error : Maybe TransactionError
    , updatedShips : List Ship
    , updatedPlayer : Player
    , updatedPlanet : Planet
    }


buyGood : String -> List Ship -> Int -> Player -> Planet -> TransactionResult
buyGood goodName ships activeShipIndex player planet =
    case ( getActiveShip activeShipIndex ships, Dict.get goodName planet.market ) of
        ( Just ship, Just marketGood ) ->
            if player.credits < marketGood.price then
                transactionError NotEnoughCredits ships player planet
                
            else if marketGood.stock <= 0 then
                transactionError NotEnoughStock ships player planet
                
            else
                case ShipLogic.addCargo goodName 1 ship of
                    Just updatedShip ->
                        let
                            updatedShips = updateShips activeShipIndex updatedShip ships
                            updatedPlayer = { player | credits = player.credits - marketGood.price }
                            updatedMarket = updateMarketStock goodName -1 planet.market
                            updatedPlanet = { planet | market = updatedMarket }
                        in
                        transactionSuccess updatedShips updatedPlayer updatedPlanet
                            
                    Nothing ->
                        transactionError NotEnoughCargoSpace ships player planet
                        
        ( Nothing, _ ) ->
            transactionError InvalidShip ships player planet
            
        ( _, Nothing ) ->
            transactionError ItemNotInMarket ships player planet


sellGood : String -> List Ship -> Int -> Player -> Planet -> TransactionResult
sellGood goodName ships activeShipIndex player planet =
    case ( getActiveShip activeShipIndex ships, Dict.get goodName planet.market ) of
        ( Just ship, Just marketGood ) ->
            case ShipLogic.removeCargo goodName 1 ship of
                Just updatedShip ->
                    let
                        updatedShips = updateShips activeShipIndex updatedShip ships
                        updatedPlayer = { player | credits = player.credits + marketGood.price }
                        updatedMarket = updateMarketStock goodName 1 planet.market
                        updatedPlanet = { planet | market = updatedMarket }
                    in
                    transactionSuccess updatedShips updatedPlayer updatedPlanet
                    
                Nothing ->
                    transactionError ItemNotInCargo ships player planet
                    
        ( Nothing, _ ) ->
            transactionError InvalidShip ships player planet
            
        ( _, Nothing ) ->
            transactionError ItemNotInMarket ships player planet


-- Helper functions

getActiveShip : Int -> List Ship -> Maybe Ship
getActiveShip activeShipIndex ships =
    List.head (List.drop activeShipIndex ships)


updateShips : Int -> Ship -> List Ship -> List Ship
updateShips index updatedShip ships =
    List.indexedMap (\i s -> if i == index then updatedShip else s) ships


updateMarketStock : String -> Int -> Dict String Good -> Dict String Good
updateMarketStock goodName delta market =
    Dict.update goodName
        (Maybe.map (\good -> { good | stock = good.stock + delta }))
        market


transactionSuccess : List Ship -> Player -> Planet -> TransactionResult
transactionSuccess ships player planet =
    { success = True
    , error = Nothing
    , updatedShips = ships
    , updatedPlayer = player
    , updatedPlanet = planet
    }


transactionError : TransactionError -> List Ship -> Player -> Planet -> TransactionResult
transactionError error ships player planet =
    { success = False
    , error = Just error
    , updatedShips = ships
    , updatedPlayer = player
    , updatedPlanet = planet
    }
