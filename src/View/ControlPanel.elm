module View.ControlPanel exposing (viewControlPanel)

import Html exposing (Html, button, div, h3, p, text, ul, li)
import Html.Events exposing (onClick)
import Models.Planet exposing (Planet)
import Models.Ship exposing (Ship, ShipType(..))
import Dict

{-| Unified control panel for all ships. Shows:
    - Current location
    - Navigation options
    - Market (context-sensitive)
    - Special commands (context-sensitive)
-}

viewControlPanel :
    { activeShip : Ship
    , currentLocation : Maybe String
    , planets : List Planet
    , onTravel : String -> msg
    , onBuy : String -> msg
    , onSell : String -> msg
    }
    -> Html msg
viewControlPanel { activeShip, currentLocation, planets, onTravel, onBuy, onSell } =
    let
        -- Navigation: show all planets except current
        otherPlanets =
            case currentLocation of
                Just loc -> List.filter (\p -> p.name /= loc) planets
                Nothing -> planets

        navigationPanel =
            div []
                (h3 [] [ text "Navigation" ] ::
                 (if List.isEmpty otherPlanets then [ p [] [ text "No destinations" ] ]
                  else
                    otherPlanets
                        |> List.map (\planet ->
                            p []
                                [ text planet.name
                                , button [ onClick (onTravel planet.name) ] [ text "Travel" ]
                                ]
                        )
                 )
                )

        locationPanel =
            div []
                [ h3 [] [ text "Location" ]
                , p [] [ text <| case currentLocation of
                                    Just loc -> loc
                                    Nothing -> "Lost in space"
                            ]
                ]

        marketPanel =
            case activeShip.shipType of
                Cargo ->
                    div []
                        [ h3 [] [ text "Market (Goods)" ]
                        , case currentLocation of
                            Just loc ->
                                case List.filter (\p -> p.name == loc) planets |> List.head of
                                    Just planet ->
                                        ul []
                                            (planet.market
                                                |> Dict.toList
                                                |> List.map (\( name, good ) ->
                                                    li []
                                                        [ text (name ++ " - Price: " ++ String.fromInt good.price ++ ", Stock: " ++ String.fromInt good.stock)
                                                        , button [ onClick (onBuy name) ] [ text "Buy" ]
                                                        , button [ onClick (onSell name) ] [ text "Sell" ]
                                                        ]
                                                )
                                            )
                                    Nothing -> p [] [ text "No market at this location." ]
                            Nothing -> p [] [ text "Not at a market location." ]
                        ]
                Military ->
                    div []
                        [ h3 [] [ text "Market (Arms)" ]
                        , p [] [ text "[Arms market coming soon]" ]
                        ]
                Explorer ->
                    div []
                        [ h3 [] [ text "Market (Exploration Equipment)" ]
                        , p [] [ text "[Exploration equipment market coming soon]" ]
                        ]

        specialPanel =
            case activeShip.shipType of
                Cargo -> text ""
                Military -> div [] [ h3 [] [ text "Special Commands" ], p [] [ text "[Military commands coming soon]" ] ]
                Explorer -> div [] [ h3 [] [ text "Special Commands" ], p [] [ text "[Exploration actions coming soon]" ] ]
    in
    div []
        [ locationPanel
        , navigationPanel
        , marketPanel
        , specialPanel
        ]
