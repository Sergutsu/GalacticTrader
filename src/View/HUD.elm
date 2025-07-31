module View.HUD exposing (viewHUD)

import Dict
import Html exposing (Html, div, p, text)
import Html.Attributes exposing (class)
import Models.Player exposing (Player)
import Models.Ship exposing (Ship)


{-| The main HUD component that displays critical game information at a glance.
-}
viewHUD : Player -> Ship -> Html msg
viewHUD player activeShip =
    div [ class "hud" ]
        [ viewPlayerInfo player
        , viewShipStatus activeShip
        ]


{-| Displays player information including credits and faction.
-}
viewPlayerInfo : Player -> Html msg
viewPlayerInfo player =
    div [ class "player-info" ]
        [ p [ class "player-name" ] [ text player.name ]
        , p [ class "player-credits" ] [ text ("Credits: " ++ String.fromInt player.credits) ]
        , p [ class "player-faction" ] 
            [ text "Faction: " 
            , text (case player.factionId of
                    Just faction -> faction
                    Nothing -> "Unaffiliated"
                 )
            ]
        ]


{-| Displays the status of the active ship.
-}
viewShipStatus : Ship -> Html msg
viewShipStatus ship =
    div [ class "ship-status" ]
        [ p [ class "ship-name" ] [ text ship.name ]
        , p [ class "ship-type" ] [ text (shipTypeToString ship.shipType) ]
        , p [ class "ship-fuel" ] 
            [ text ("Fuel: " ++ String.fromInt ship.fuel ++ "/" ++ String.fromInt ship.fuelCapacity) ]
        , p [ class "ship-cargo" ]
            [ text ("Cargo: " ++ 
                  String.fromInt (Dict.size ship.cargo) ++ 
                  "/" ++ 
                  String.fromInt ship.cargoCapacity)
            ]
        ]


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
