module Models.Ship exposing (Ship)

import Dict exposing (Dict)

type alias Ship =
    { name : String
    , cargoCapacity : Int
    , cargo : Dict String Int
    , fuel : Int
    , fuelCapacity : Int
    }
