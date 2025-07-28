module Logic.Ship exposing (addCargo, removeCargo)

import Dict
import Models.Ship exposing (Ship)


addCargo : String -> Int -> Ship -> Maybe Ship
addCargo commodityName quantity ship =
    if Dict.size ship.cargo >= ship.cargoCapacity && not (Dict.member commodityName ship.cargo) then
        Nothing

    else
        let
            newCargo =
                Dict.update commodityName
                    (\maybeValue ->
                        Just (Maybe.withDefault 0 maybeValue + quantity)
                    )
                    ship.cargo
        in
        Just { ship | cargo = newCargo }


removeCargo : String -> Int -> Ship -> Maybe Ship
removeCargo commodityName quantity ship =
    ship.cargo
        |> Dict.get commodityName
        |> Maybe.andThen
            (\currentQuantity ->
                if currentQuantity >= quantity then
                    let
                        newQuantity =
                            currentQuantity - quantity

                        newCargo =
                            if newQuantity > 0 then
                                Dict.insert commodityName newQuantity ship.cargo

                            else
                                Dict.remove commodityName ship.cargo
                    in
                    Just { ship | cargo = newCargo }

                else
                    Nothing
            )
