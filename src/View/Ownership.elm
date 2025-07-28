module View.Ownership exposing (viewOwnership)

import Dict
import Html exposing (Html, div, h3, li, p, text, ul)
import Models.Ship exposing (Ship)


viewOwnership : List Ship -> Html msg
viewOwnership ships =
    div []
        [ h3 [] [ text "Player Assets" ]
        , ul [] (ships |> List.map viewShip)
        ]


viewShip : Ship -> Html msg
viewShip ship =
    li []
        [ p [] [ text ("Ship: " ++ ship.name) ]
        , p [] [ text ("Fuel: " ++ String.fromInt ship.fuel ++ "/" ++ String.fromInt ship.fuelCapacity) ]
        , p [] [ text ("Cargo Capacity: " ++ String.fromInt ship.cargoCapacity) ]
        , h3 [] [ text "Cargo Hold" ]
        , ul [] (ship.cargo |> Dict.toList |> List.map viewCargoItem)
        ]


viewCargoItem : ( String, Int ) -> Html msg
viewCargoItem ( name, quantity ) =
    li [] [ text (name ++ ": " ++ String.fromInt quantity) ]
