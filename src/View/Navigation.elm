module View.Navigation exposing (viewNavigation)

import Html exposing (Html, button, div, h3, p, text)
import Html.Events exposing (onClick)
import Models.Planet exposing (Planet)


viewNavigation : (String -> msg) -> Maybe String -> List Planet -> Html msg
viewNavigation travelMsg currentLocation planets =
    let
        otherPlanets =
            case currentLocation of
                Just loc ->
                    List.filter (\p -> p.name /= loc) planets

                Nothing ->
                    planets
    in
    div []
        [ h3 [] [ text "Navigation" ]
        , div []
            (otherPlanets
                |> List.map
                    (\planet ->
                        p []
                            [ text planet.name
                            , button [ onClick (travelMsg planet.name) ] [ text "Travel" ]
                            ]
                    )
            )
        ]
