module Models.Ship exposing (Ship, ShipType(..))

import Dict exposing (Dict)

type ShipType
    = Cargo
    | Explorer
    | Military


type alias Ship =
    { name : String
    , shipType : ShipType
    , cargoCapacity : Int
    , cargo : Dict String Int
    , fuel : Int
    , fuelCapacity : Int
    }
