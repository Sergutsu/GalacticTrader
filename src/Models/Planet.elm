module Models.Planet exposing (Planet, Market)

import Dict exposing (Dict)
import Models.Good exposing (Good)

type alias Market =
    Dict String Good

type alias Planet =
    { name : String
    , market : Market
    }
