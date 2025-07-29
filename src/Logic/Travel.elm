module Logic.Travel exposing (startTravel)

import Models.Planet exposing (Planet)
import Models.Ship exposing (Ship)
import Time
import Types exposing (TravelState)


startTravel : String -> List Ship -> Int -> List Planet -> Time.Posix -> Maybe ( List Ship, TravelState )
startTravel destinationName ships activeShipIndex planets currentTime =
    let
        activeShip =
            List.head (List.drop activeShipIndex ships)

        fuelCost = 10 -- Example fuel cost
        travelDuration = 10000 -- in milliseconds (10 seconds)
    in
    activeShip
        |> Maybe.andThen
            (\ship ->
                if ship.fuel >= fuelCost then
                    let
                        newShip =
                            { ship | fuel = ship.fuel - fuelCost }

                        updatedShips =
                            List.indexedMap (\i s -> if i == activeShipIndex then newShip else s) ships

                        -- For now, we'll use the current system and the destination name as the planet
                        -- In a real implementation, you'd want to look up the actual system and planet
                        currentSystem = Maybe.map (\(systemName, _) -> systemName) (List.head (List.map (\p -> ("", p.name)) planets))
                                    |> Maybe.withDefault "Unknown System"
                                    
                        travelState =
                            { destination = (currentSystem, destinationName)
                            , arrivalTime = Time.millisToPosix (Time.posixToMillis currentTime + round travelDuration)
                            , travelDuration = travelDuration
                            }
                    in
                    Just ( updatedShips, travelState )

                else
                    Nothing
            )
