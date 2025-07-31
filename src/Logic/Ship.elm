module Logic.Ship exposing (addCargo, removeCargo, getAvailableCargoSpace, getCargoTotal, transferCargoBetweenShips)

import Dict
import Models.Ship exposing (Ship)
import List.Extra as List


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


{-| Calculate the available cargo space in a ship
-}
getAvailableCargoSpace : Ship -> Int
getAvailableCargoSpace ship =
    let
        usedSpace =
            Dict.values ship.cargo
                |> List.sum
    in
    max 0 (ship.cargoCapacity - usedSpace)


{-| Get the total quantity of a specific cargo item across multiple ships
-}
getCargoTotal : String -> List Ship -> Int
getCargoTotal goodName ships =
    ships
        |> List.map (.cargo >> Dict.get goodName >> Maybe.withDefault 0)
        |> List.sum


{-| Transfer cargo from one ship to another
-}
transferCargoBetweenShips : String -> Int -> Ship -> Ship -> Maybe { fromShip : Ship, toShip : Ship }
transferCargoBetweenShips goodName quantity fromShip toShip =
    -- First, check if the source ship has enough cargo
    let
        availableQuantity =
            Dict.get goodName fromShip.cargo |> Maybe.withDefault 0
    in
    if availableQuantity < quantity then
        -- Not enough cargo to transfer
        Nothing
    else
        -- Check if the destination ship has enough space
        let
            spaceNeeded =
                -- If the ship already has some of this cargo, we only need space for the additional quantity
                case Dict.get goodName toShip.cargo of
                    Just existingQty ->
                        max 0 (quantity - existingQty)
                    Nothing ->
                        quantity
        in
        if getAvailableCargoSpace toShip < spaceNeeded then
            -- Not enough space in the destination ship
            Nothing
        else
            -- Perform the transfer
            let
                -- Remove from source
                newFromCargo =
                    let
                        newQty = availableQuantity - quantity
                    in
                    if newQty > 0 then
                        Dict.insert goodName newQty fromShip.cargo
                    else
                        Dict.remove goodName fromShip.cargo
                
                -- Add to destination
                newToCargo =
                    Dict.update goodName
                        (Maybe.map ((+) quantity) >> Maybe.withDefault quantity >> Just)
                        toShip.cargo
                
                updatedFromShip = { fromShip | cargo = newFromCargo }
                updatedToShip = { toShip | cargo = newToCargo }
            in
            Just { fromShip = updatedFromShip, toShip = updatedToShip }
