module View.Ownership exposing (viewOwnership)

import Dict
import Html exposing (Html, button, div, h3, li, p, text, ul)
import Html.Events exposing (onClick)
import Models.Ship exposing (Ship, ShipType(..))


viewOwnership : Int -> (Int -> msg) -> List Ship -> Html msg
viewOwnership activeShipIndex selectShipMsg ships =
    div []
        [ h3 [] [ text "Player Assets" ]
        , ul [] (List.indexedMap (viewShip activeShipIndex selectShipMsg) ships)
        ]


viewShip : Int -> (Int -> msg) -> Int -> Ship -> Html msg
viewShip activeShipIndex selectShipMsg idx ship =
    let
        isActive = idx == activeShipIndex
    in
    li []
        ([ p [] [ text ("Ship: " ++ ship.name ++ (if isActive then " (ACTIVE)" else "")) ]
         , p [] [ text ("Type: " ++ shipTypeToString ship.shipType) ]
         , button [ onClick (selectShipMsg idx) ] [ text (if isActive then "Commanding" else "Command") ]
         , p [] [ text ("Fuel: " ++ String.fromInt ship.fuel ++ "/" ++ String.fromInt ship.fuelCapacity) ]
         , p [] [ text ("Cargo Capacity: " ++ String.fromInt ship.cargoCapacity) ]
         , h3 [] [ text "Cargo Hold" ]
         , ul [] (ship.cargo |> Dict.toList |> List.map viewCargoItem)
         ]
        )


shipTypeToString : ShipType -> String
shipTypeToString shipType =
    case shipType of
        Cargo -> "Cargo"
        Explorer -> "Explorer"
        Military -> "Military"


viewCargoItem : ( String, Int ) -> Html msg
viewCargoItem ( name, quantity ) =
    li [] [ text (name ++ ": " ++ String.fromInt quantity) ]
