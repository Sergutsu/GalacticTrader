module View.ControlPanel exposing (viewControlPanel)

import Html exposing (Html, button, div, h3, p, text, ul, li)
import Html.Events exposing (onClick)

import Models.StarSystem exposing (StarSystem)
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
    , starSystems : List StarSystem
    , currentLocation : Maybe (String, String)
    , onTravel : String -> msg
    , onBuy : String -> msg
    , onSell : String -> msg
    }
    -> Html msg
viewControlPanel { activeShip, starSystems, currentLocation, onTravel, onBuy, onSell } =
    let
        (currentSystem, currentPlanet) =
            case currentLocation of
                Just (sys, pl) -> (Just sys, Just pl)
                Nothing -> (Nothing, Nothing)

        maybeSystem =
            currentSystem
                |> Maybe.andThen (\sysName -> List.filter (\s -> s.name == sysName) starSystems |> List.head)
        maybePlanet =
            case (maybeSystem, currentPlanet) of
                (Just sys, Just plName) -> List.filter (\p -> p.name == plName) sys.planets |> List.head
                _ -> Nothing

        otherPlanets =
            case (maybeSystem, currentPlanet) of
                (Just sys, Just plName) -> List.filter (\p -> p.name /= plName) sys.planets
                (Just sys, Nothing) -> sys.planets
                _ -> []

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
                , p [] [ text <| case (currentSystem, currentPlanet) of
                                    (Just sys, Just pl) -> sys ++ ": " ++ pl
                                    (Just sys, Nothing) -> sys ++ ": ???"
                                    _ -> "Lost in space"
                            ]
                ]

        marketPanel =
            case activeShip.shipType of
                Cargo ->
                    div []
                        [ h3 [] [ text "Market (Goods)" ]
                        , case maybePlanet of
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
    let
        cargoPanel =
            div []
                ([ h3 [] [ text "Cargo" ] ] ++
                    (if Dict.isEmpty activeShip.cargo then
                        [ p [] [ text "No cargo on board." ] ]
                     else
                        [ ul []
                            (Dict.toList activeShip.cargo
                                |> List.map (\(name, qty) -> li [] [ text (name ++ ": " ++ String.fromInt qty) ])
                            )
                        ]
                    )
                )
    in
    div []
        [ locationPanel
        , navigationPanel
        , cargoPanel
        , marketPanel
        , specialPanel
        ]
