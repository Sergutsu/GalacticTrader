module Types exposing (Model, Msg(..), TravelState, Asset(..))


import Models.StarSystem
import Models.Player exposing (Player)
import Models.Ship exposing (Ship)
import Models.Artifact exposing (Artifact)
import Models.Station exposing (Station)
-- Add more as needed
import Time


-- MODEL
type alias Model =
    {
        player : Player
        , ships : List Ship
        , assets : List Asset
        , activeAssetIndex : Int
        , starSystems : List Models.StarSystem.StarSystem
        , activeShipIndex : Int -- legacy, will be removed
        , currentLocation : Maybe (String, String) -- (systemName, planetName)
        , travelState : Maybe TravelState
        , currentTime : Time.Posix
    }

type Asset
    = ShipAsset Ship
    | ArtifactAsset Artifact
    | StationAsset Station
    -- Add more as needed


type alias TravelState =
    {
        destination : (String, String) -- (systemName, planetName)
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
    | SelectShip Int
    | SelectAsset Int
