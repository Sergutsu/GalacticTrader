module Models.Ship exposing (Ship, ShipId, ShipType(..), newShip)

{-| This module defines the Ship type and related functions.
It's used to represent ships in the game and manage their data.
-}

import Dict exposing (Dict)
import Types.Ownership as OwnershipTypes exposing (Owner)


type alias ShipId =
    String


type ShipType
    = Cargo
    | Explorer
    | Military


type alias Ship =
    { id : ShipId
    , name : String
    , shipType : ShipType
    , cargoCapacity : Int
    , cargo : Dict String Int
    , fuel : Int
    , fuelCapacity : Int
    , owner : Maybe Owner  -- Who currently owns this ship
    , isDocked : Bool     -- Whether the ship is currently docked at a station
    , location : Maybe ( String, String )  -- (system, planet) where the ship is located
    }


{-| Create a new ship with default values
-}
newShip : ShipId -> String -> ShipType -> Owner -> Ship
newShip id name shipType owner =
    let
        baseCapacity =
            case shipType of
                Cargo ->
                    50

                Explorer ->
                    20

                Military ->
                    30
    in
    { id = id
    , name = name
    , shipType = shipType
    , cargoCapacity = baseCapacity
    , cargo = Dict.empty
    , fuel = 100
    , fuelCapacity = 100
    , owner = Just owner
    , isDocked = False
    , location = Nothing
    }


{-| Check if the ship has enough cargo space for additional items
-}
hasCargoSpace : Ship -> Int -> Bool
hasCargoSpace ship additionalItems =
    Dict.foldl (\_ qty total -> total + qty) 0 ship.cargo + additionalItems <= ship.cargoCapacity


{-| Add cargo to the ship if there's enough space
-}
addCargo : String -> Int -> Ship -> Maybe Ship
addCargo item quantity ship =
    if hasCargoSpace ship quantity then
        let
            currentQuantity =
                Dict.get item ship.cargo |> Maybe.withDefault 0

            updatedCargo =
                Dict.insert item (currentQuantity + quantity) ship.cargo
        in
        Just { ship | cargo = updatedCargo }
    else
        Nothing


{-| Remove cargo from the ship if available
-}
removeCargo : String -> Int -> Ship -> Maybe Ship
removeCargo item quantity ship =
    let
        currentQuantity =
            Dict.get item ship.cargo |> Maybe.withDefault 0
    in
    if currentQuantity >= quantity then
        let
            updatedCargo =
                if currentQuantity == quantity then
                    Dict.remove item ship.cargo
                else
                    Dict.insert item (currentQuantity - quantity) ship.cargo
        in
        Just { ship | cargo = updatedCargo }
    else
        Nothing


{-| Check if the ship has a specific item in its cargo
-}
hasCargo : String -> Int -> Ship -> Bool
hasCargo item quantity ship =
    Dict.get item ship.cargo
        |> Maybe.map (\qty -> qty >= quantity)
        |> Maybe.withDefault False


{-| Get the total number of cargo items in the ship
-}
totalCargo : Ship -> Int
totalCargo ship =
    Dict.foldl (\_ qty total -> total + qty) 0 ship.cargo


{-| Check if the ship is owned by a specific owner
-}
isOwnedBy : Owner -> Ship -> Bool
isOwnedBy owner ship =
    ship.owner == Just owner


{-| Transfer ownership of the ship to a new owner
-}
transferOwnership : Owner -> Ship -> Ship
transferOwnership newOwner ship =
    { ship | owner = Just newOwner }


{-| Update the ship's location
-}
updateLocation : Maybe ( String, String ) -> Ship -> Ship
updateLocation newLocation ship =
    { ship | location = newLocation }


{-| Set the ship's docked status
-}
setDocked : Bool -> Ship -> Ship
setDocked isDocked ship =
    { ship | isDocked = isDocked }
