module View.Market exposing (viewMarket)

import Dict
import Html exposing (Html, button, div, h2, h3, p, table, tbody, td, text, th, thead, tr, span)
import Html.Attributes exposing (class, disabled, style)
import Html.Events exposing (onClick)
import Models.Good as Good exposing (GoodType, allGoods, goodBasePrice, goodCategory, goodName)
import Models.Planet exposing (Planet)


type alias MarketItem =
    { goodType : GoodType
    , price : Int
    , stock : Int
    , baseStock : Int
    }



{-| View the market panel with categorized goods
-}
viewMarket : (String -> msg) -> (String -> msg) -> Planet -> Html msg
viewMarket buyMsg sellMsg planet =
    let
        -- Convert market Dict to a list of MarketItems
        marketItems : List MarketItem
        marketItems =
            allGoods
                |> List.filterMap
                    (\goodType ->
                        let
                            goodId =
                                goodType
                                    |> goodName
                                    |> String.toLower
                                    |> String.replace " " "_"
                        in
                        Dict.get goodId planet.market
                            |> Maybe.map
                                (\good ->
                                    { goodType = goodType
                                    , price = good.price
                                    , stock = good.stock
                                    , baseStock = good.baseStock
                                    }
                                )
                    )

        -- Group by category
        goodsByCategory : List ( String, List MarketItem )
        goodsByCategory =
            let
                -- Helper function to group items by category
                groupByCategory : List MarketItem -> List ( String, List MarketItem )
                groupByCategory items =
                    items
                        |> List.sortBy (.goodType >> goodName)
                        |> List.foldr
                            (\item acc ->
                                let
                                    category =
                                        goodCategory item.goodType
                                in
                                case List.head (List.filter (\( c, _ ) -> c == category) acc) of
                                    Just ( _, itemsInCategory ) ->
                                        ( category, item :: itemsInCategory ) :: List.filter (\( c, _ ) -> c /= category) acc
                                    Nothing ->
                                        ( category, [ item ] ) :: acc
                            )
                            []
            in
            groupByCategory marketItems
    in
    div [ class "market-panel" ]
        [ h2 [ class "panel-title" ] [ text "Local Market" ]
        , p [ class "location" ] [ text ("Location: " ++ planet.name) ]
        , div [ class "market-categories" ]
            (List.map (viewCategory buyMsg sellMsg planet) goodsByCategory)
        ]


{-| View a category of goods
-}
viewCategory : (String -> msg) -> (String -> msg) -> Planet -> ( String, List MarketItem ) -> Html msg
viewCategory buyMsg sellMsg planet ( category, items ) =
    let
        categoryId =
            String.toLower (String.replace " " "-" category)
    in
    div [ class "market-category", class ("category-" ++ categoryId) ]
        [ h3 [ class "category-header" ] [ text category ]
        , if List.isEmpty items then
            p [ class "no-items" ] [ text ("No " ++ String.toLower category ++ " available in this market.") ]
          else
            table [ class "market-table" ]
                [ thead []
                    [ tr []
                        [ th [] [ text "Item" ]
                        , th [ class "text-right" ] [ text "Price" ]
                        , th [ class "text-right" ] [ text "Stock" ]
                        , th [ class "text-center" ] [ text "Actions" ]
                        ]
                    ]
                , tbody [] (List.map (viewMarketItem buyMsg sellMsg planet) items)
                ]
        ]


{-| View a single market item
-}
viewMarketItem : (String -> msg) -> (String -> msg) -> Planet -> MarketItem -> Html msg
viewMarketItem buyMsg sellMsg _ marketItem =
    let
        goodType =
            marketItem.goodType

        goodNameStr =
            goodName goodType

        goodId =
            goodNameStr
                |> String.toLower
                |> String.replace " " "_"

        priceDifference =
            let
                basePrice =
                    goodBasePrice goodType
            in
            if marketItem.price > basePrice then
                "▲ " ++ String.fromInt (marketItem.price - basePrice)
            else if marketItem.price < basePrice then
                "▼ " ++ String.fromInt (basePrice - marketItem.price)
            else
                ""

        stockPercentage =
            if marketItem.baseStock > 0 then
                (toFloat marketItem.stock / toFloat marketItem.baseStock) * 100
            else
                0

        stockClass =
            if stockPercentage < 10 then
                "stock-low"
            else if stockPercentage < 30 then
                "stock-medium"
            else
                "stock-high"



    in
    tr [ class "market-item" ]
        [ td [ class "item-name" ]
            [ div [ class "item-name-text" ] [ text goodNameStr ]
            , if priceDifference /= "" then
                div [ class "price-difference" ] [ text priceDifference ]
              else
                text ""
            ]
        , td [ class "text-right" ] [ text (String.fromInt marketItem.price ++ " ¢") ]
        , td [ class "text-right" ]
            [ div [ class "stock-bar-container" ]
                [ div
                    [ class "stock-bar"
                    , class stockClass
                    , style "width" (String.fromFloat stockPercentage ++ "%")
                    ]
                    []
                , span [ class "stock-amount" ] [ text (String.fromInt marketItem.stock) ]
                ]
            ]
        , td [ class "actions" ]
            [ button
                [ class "btn-buy"
                , onClick (buyMsg goodId)
                , disabled (marketItem.stock <= 0)
                ]
                [ text "Buy" ]
            , button
                [ class "btn-sell"
                , onClick (sellMsg goodId)
                , disabled (marketItem.stock <= 0)
                ]
                [ text "Sell" ]
            ]
        ]
