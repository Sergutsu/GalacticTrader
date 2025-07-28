module Models.StarSystem exposing (StarSystem)

import Models.Planet exposing (Planet)

{-| A star system contains a name, a list of planets, and an explored flag. -}
type alias StarSystem =
    { name : String
    , planets : List Planet
    , explored : Bool
    }
