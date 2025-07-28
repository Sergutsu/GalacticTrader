module Types exposing (Model, Msg(..), TravelState)

import Models.Planet exposing (Planet)
import Models.Player exposing (Player)
import Models.Ship exposing (Ship)
import Time


-- MODEL
type alias Model =
    {
        player : Player
        , ships : List Ship
        , planets : List Planet
        , activeShipIndex : Int
        , currentLocation : Maybe String
        , travelState : Maybe TravelState
        , currentTime : Time.Posix
    }


type alias TravelState =
    {
        destination : String
        , arrivalTime : Time.Posix
        , travelDuration : Float
    }


-- MESSAGES
type Msg
    = NoOp
    | BuyCommodity String
    | SellCommodity String
    | TravelTo String
    | Tick Time.Posix
    | SetCurrentTime Time.Posix
