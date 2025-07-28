module View.Market exposing (viewMarket)

import Dict
import Html exposing (Html, button, div, h3, p, text)
import Html.Events exposing (onClick)
import Models.Planet exposing (Planet)


viewMarket : (String -> msg) -> (String -> msg) -> Planet -> Html msg
viewMarket buyMsg sellMsg planet =
    div []
        [ h3 [] [ text "Market" ]
        , div []
            (planet.market
                |> Dict.toList
                |> List.map
                    (\( name, good ) ->
                        p []
                            [ text (name ++ " - Price: " ++ String.fromInt good.price ++ ", Stock: " ++ String.fromInt good.stock)
                            , button [ onClick (buyMsg name) ] [ text "Buy" ]
                            , button [ onClick (sellMsg name) ] [ text "Sell" ]
                            ]
                    )
            )
        ]
