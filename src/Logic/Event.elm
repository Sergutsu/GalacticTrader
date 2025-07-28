module Logic.Event exposing (handleTick)

import Time
import Types exposing (Model)


handleTick : Time.Posix -> Model -> Model
handleTick newTime model =
    case model.travelState of
        Just travel ->
            if Time.posixToMillis newTime >= Time.posixToMillis travel.arrivalTime then
                { model | travelState = Nothing, currentLocation = Just travel.destination, currentTime = newTime }
            else
                { model | currentTime = newTime }
        Nothing ->
            model


-- This module will handle game events.
