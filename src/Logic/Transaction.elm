module Logic.Transaction exposing (buyCommodity, sellCommodity)

import Dict
import Logic.Ship as ShipLogic
import Models.Planet exposing (Planet)
import Models.Player exposing (Player)
import Models.Ship exposing (Ship)


buyCommodity : String -> List Ship -> Int -> Player -> Planet -> ( List Ship, Player, Planet )
buyCommodity commodityName ships activeShipIndex player planet =
    let
        activeShipResult =
            List.head (List.drop activeShipIndex ships)

        marketItemResult =
            Dict.get commodityName planet.market
    in
    case ( activeShipResult, marketItemResult ) of
        ( Just ship, Just item ) ->
            if player.credits >= item.price && item.stock > 0 then
                case ShipLogic.addCargo commodityName 1 ship of
                    Just newShip ->
                        let
                            newPlayer =
                                { player | credits = player.credits - item.price }

                            updatedShips =
                                List.indexedMap (\i s -> if i == activeShipIndex then newShip else s) ships

                            newMarket =
                                Dict.update commodityName
                                    (\maybeItem ->
                                        Maybe.map (\i -> { i | stock = i.stock - 1 }) maybeItem
                                    )
                                    planet.market

                            newPlanet =
                                { planet | market = newMarket }
                        in
                        ( updatedShips, newPlayer, newPlanet )

                    Nothing ->
                        ( ships, player, planet )

            else
                ( ships, player, planet )

        _ ->
            ( ships, player, planet )


sellCommodity : String -> List Ship -> Int -> Player -> Planet -> ( List Ship, Player, Planet )
sellCommodity commodityName ships activeShipIndex player planet =
    let
        activeShipResult =
            List.head (List.drop activeShipIndex ships)

        marketItemResult =
            Dict.get commodityName planet.market
    in
    case ( activeShipResult, marketItemResult ) of
        ( Just ship, Just item ) ->
            case ShipLogic.removeCargo commodityName 1 ship of
                Just newShip ->
                    let
                        newPlayer =
                            { player | credits = player.credits + item.price }

                        updatedShips =
                            List.indexedMap (\i s -> if i == activeShipIndex then newShip else s) ships

                        newMarket =
                            Dict.update commodityName
                                (\maybeItem ->
                                    Maybe.map (\i -> { i | stock = i.stock + 1 }) maybeItem
                                )
                                planet.market

                        newPlanet =
                            { planet | market = newMarket }
                    in
                    ( updatedShips, newPlayer, newPlanet )

                Nothing ->
                    ( ships, player, planet )

        _ ->
            ( ships, player, planet )
