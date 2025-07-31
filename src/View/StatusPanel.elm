module View.StatusPanel exposing (viewStatusPanel)

import Html exposing (Html, div, h3, h4, p, text, span)
import Html.Attributes exposing (class)
import Models.Player exposing (Player)
import Models.Ship exposing (Ship, ShipType(..))
import Dict


{-| Displays the main status panel with player and ship information.
-}
viewStatusPanel : Player -> Maybe Ship -> Html msg
viewStatusPanel player maybeShip =
    div [ class "status-panel" ]
        [ h3 [ class "panel-title" ] [ text "Status" ]
        , viewPlayerStatus player
        , viewShipStatus maybeShip
        ]


{-| Displays the player's status information.
-}
viewPlayerStatus : Player -> Html msg
viewPlayerStatus player =
    div [ class "player-status" ]
        [ h4 [ class "section-title" ] [ text "Player" ]
        , statusItem "Name" player.name
        , statusItem "Credits" (formatCredits player.credits)
        , statusItem "Faction" (Maybe.withDefault "Unaffiliated" player.factionId)
        ]


{-| Displays the ship's status information if available.
-}
viewShipStatus : Maybe Ship -> Html msg
viewShipStatus maybeShip =
    case maybeShip of
        Just ship ->
            div [ class "ship-status" ]
                [ h4 [ class "section-title" ] [ text "Active Ship" ]
                , statusItem "Name" ship.name
                , statusItem "Type" (shipTypeToString ship.shipType)
                , statusItem "Fuel" (formatFuel ship.fuel ship.fuelCapacity)
                , statusItem "Cargo" (formatCargo (Dict.size ship.cargo) ship.cargoCapacity)
                , statusItem "Location" (formatLocation ship.location)
                ]

        Nothing ->
            div [ class "no-ship" ]
                [ p [] [ text "No active ship selected" ] ]


{-| Helper function to create a status item with a label and value.
-}
statusItem : String -> String -> Html msg
statusItem label value =
    div [ class "status-item" ]
        [ span [ class "status-label" ] [ text (label ++ ": ") ]
        , span [ class "status-value" ] [ text value ]
        ]


{-| Formats the credits with a currency symbol.
-}
formatCredits : Int -> String
formatCredits credits =
    "₡" ++ String.fromInt credits


{-| Formats the fuel level as a percentage.
-}
formatFuel : Int -> Int -> String
formatFuel current max =
    let
        percentage =
            if max > 0 then
                toFloat current / toFloat max * 100
            else
                0
    in
    String.fromInt current ++ "/" ++ String.fromInt max ++ " (" ++ String.fromFloat (toFloat (round (percentage * 10)) / 10) ++ "%)"


{-| Formats the cargo capacity.
-}
formatCargo : Int -> Int -> String
formatCargo current max =
    String.fromInt current ++ "/" ++ String.fromInt max


{-| Formats the ship's location.
-}
formatLocation : Maybe ( String, String ) -> String
formatLocation location =
    case location of
        Just (system, planet) ->
            system ++ ": " ++ planet

        Nothing ->
            "In Transit"


{-| Converts ShipType to a readable string.
-}
shipTypeToString : Models.Ship.ShipType -> String
shipTypeToString shipType =
    case shipType of
        Models.Ship.Cargo ->
            "Cargo Ship"

        Models.Ship.Explorer ->
            "Exploration Vessel"

        Models.Ship.Military ->
            "Warship"
