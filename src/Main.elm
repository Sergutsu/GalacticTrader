module Main exposing (..)

import Browser
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Css exposing (..)
import Css.Global
import Css.Media as Media
import Dict exposing (Dict)
import Time

-- MAIN

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view >> toUnstyled
        , subscriptions = subscriptions
        }


-- MODEL

type alias Model =
    { credits : Int
    , currentPlanet : String
    , fuel : Int
    , hull : Int
    , cargoUsed : Float
    , maxCargo : Float
    , inventory : Dict String Int
    , selectedDestination : Maybe String
    , inTransit : Bool
    , travelTimeLeft : Int
    , planets : Dict String Planet
    , commodities : Dict String Commodity
    , eventLog : List LogEntry
    , currentTime : Int
    }

type alias Planet =
    { distance : Float
    , market : Dict String MarketItem
    }

type alias MarketItem =
    { price : Int
    , stock : Int
    , demand : Demand
    }

type alias Commodity =
    { weight : Float
    }

type alias LogEntry =
    { message : String
    , colorClass : String
    , timestamp : String
    }

type Demand
    = High
    | Medium
    | Low

init : () -> ( Model, Cmd Msg )
init _ =
    let
        initialModel =
            { credits = 10000
            , currentPlanet = "Earth"
            , fuel = 100
            , hull = 100
            , cargoUsed = 0
            , maxCargo = 50
            , inventory = Dict.empty
            , selectedDestination = Nothing
            , inTransit = False
            , travelTimeLeft = 0
            , planets = initialPlanets
            , commodities = initialCommodities
            , eventLog = 
                [ { message = "Your journey begins on Earth. Buy low, sell high, and explore the galaxy!"
                  , colorClass = "text-gray-400"
                  , timestamp = "00:00:00"
                  }
                , { message = "Welcome to Galactic Trader, Captain!"
                  , colorClass = "text-blue-400"
                  , timestamp = "00:00:00"
                  }
                ]
            , currentTime = 0
            }
    in
    ( initialModel, Cmd.none )

initialPlanets : Dict String Planet
initialPlanets =
    Dict.fromList
        [ ( "Earth"
          , { distance = 0
            , market = Dict.fromList
                [ ( "Food", { price = 100, stock = 500, demand = High } )
                , ( "Water", { price = 50, stock = 800, demand = Medium } )
                , ( "Ore", { price = 300, stock = 200, demand = Low } )
                ]
            }
          )
        , ( "Mars"
          , { distance = 1.5
            , market = Dict.fromList
                [ ( "Food", { price = 200, stock = 300, demand = High } )
                , ( "Water", { price = 100, stock = 400, demand = High } )
                , ( "Minerals", { price = 400, stock = 150, demand = Medium } )
                ]
            }
          )
        , ( "Alpha Centauri"
          , { distance = 4.3
            , market = Dict.fromList
                [ ( "Food", { price = 500, stock = 100, demand = High } )
                , ( "Technology", { price = 1500, stock = 50, demand = Medium } )
                , ( "Luxury Goods", { price = 2000, stock = 30, demand = Low } )
                ]
            }
          )
        , ( "Titan"
          , { distance = 8.7
            , market = Dict.fromList
                [ ( "Water", { price = 80, stock = 600, demand = Medium } )
                , ( "Minerals", { price = 350, stock = 300, demand = High } )
                , ( "Fuel", { price = 250, stock = 400, demand = High } )
                ]
            }
          )
        , ( "Andromeda Station"
          , { distance = 12.2
            , market = Dict.fromList
                [ ( "Technology", { price = 1200, stock = 80, demand = Medium } )
                , ( "Luxury Goods", { price = 2500, stock = 20, demand = High } )
                , ( "Exotic Matter", { price = 5000, stock = 10, demand = Low } )
                ]
            }
          )
        ]

initialCommodities : Dict String Commodity
initialCommodities =
    Dict.fromList
        [ ( "Food", { weight = 1 } )
        , ( "Water", { weight = 1 } )
        , ( "Ore", { weight = 2 } )
        , ( "Minerals", { weight = 2 } )
        , ( "Technology", { weight = 1 } )
        , ( "Luxury Goods", { weight = 0.5 } )
        , ( "Fuel", { weight = 1 } )
        , ( "Exotic Matter", { weight = 0.2 } )
        ]


-- UPDATE

type Msg
    = SelectDestination String
    | StartTravel
    | TravelTick
    | BuyCommodity String Int
    | SellCommodity String Int
    | UpdateTime Int
    | Refuel

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectDestination planet ->
            ( { model | selectedDestination = Just planet }, Cmd.none )

        StartTravel ->
            case model.selectedDestination of
                Just destination ->
                    let
                        planetData = Dict.get destination model.planets
                    in
                    case planetData of
                        Just planet ->
                            let
                                distance = planet.distance
                                fuelCost = Basics.round (distance * 5)
                                travelTime = Basics.round (distance * 10) -- 10 seconds per LY
                            in
                            if travelTime <= 0 then
                                completeTravel { model | selectedDestination = Just destination }
                            else if fuelCost <= model.fuel && not model.inTransit then
                                let
                                    newModel =
                                        { model
                                            | inTransit = True
                                            , fuel = model.fuel - fuelCost
                                            , travelTimeLeft = travelTime
                                        }
                                    
                                    logEntry =
                                        { message = "Departing for " ++ destination ++ ". Estimated arrival in " ++ String.fromFloat (toFloat travelTime / 60) ++ " hours."
                                        , colorClass = "text-blue-400"
                                        , timestamp = formatTime model.currentTime
                                        }
                                in
                                ( addLogEntry logEntry newModel, Cmd.none )
                            else
                                let
                                    logEntry =
                                        { message = "Insufficient fuel for this journey!"
                                        , colorClass = "text-red-400"
                                        , timestamp = formatTime model.currentTime
                                        }
                                in
                                ( addLogEntry logEntry model, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        TravelTick ->
            if model.inTransit && model.travelTimeLeft > 0 then
                let
                    newTimeLeft = model.travelTimeLeft - 1
                in
                if newTimeLeft <= 0 then
                    completeTravel model
                else
                    ( { model | travelTimeLeft = newTimeLeft }, Cmd.none )
            else
                ( model, Cmd.none )

        BuyCommodity commodity quantity ->
            buyCommodity commodity quantity model

        SellCommodity commodity quantity ->
            sellCommodity commodity quantity model

        Refuel ->
            refuel model

        UpdateTime time ->
            ( { model | currentTime = time }, Cmd.none )

completeTravel : Model -> ( Model, Cmd Msg )
completeTravel model =
    case model.selectedDestination of
        Just destination ->
            let
                -- Small chance of hull damage (5%)
                (hullDamage, damageMessage) =
                    if modBy 20 model.currentTime == 0 then -- Simple random based on time
                        let damage = modBy 10 model.currentTime + 1
                        in (damage, Just ("Your ship sustained " ++ String.fromInt damage ++ "% hull damage during the journey!"))
                    else
                        (0, Nothing)

                newHull = Basics.max 0 (model.hull - hullDamage)
                
                arrivalEntry =
                    { message = "Arrived at " ++ destination ++ "!"
                    , colorClass = "text-green-400"
                    , timestamp = formatTime model.currentTime
                    }
                
                updatedModel =
                    { model
                        | currentPlanet = destination
                        , selectedDestination = Nothing
                        , inTransit = False
                        , travelTimeLeft = 0
                        , hull = newHull
                    }
                    |> addLogEntry arrivalEntry
                
                finalModel =
                    case damageMessage of
                        Just msg ->
                            let
                                damageEntry =
                                    { message = msg
                                    , colorClass = "text-red-400"
                                    , timestamp = formatTime model.currentTime
                                    }
                            in
                            addLogEntry damageEntry updatedModel
                        
                        Nothing ->
                            updatedModel
            in
            ( finalModel, Cmd.none )

        Nothing ->
            ( model, Cmd.none )

buyCommodity : String -> Int -> Model -> ( Model, Cmd Msg )
buyCommodity commodity quantity model =
    let
        currentPlanetData = Dict.get model.currentPlanet model.planets
        commodityData = Dict.get commodity model.commodities
    in
    case (currentPlanetData, commodityData) of
        (Just planet, Just commData) ->
            case Dict.get commodity planet.market of
                Just item ->
                    let
                        totalCost = item.price * quantity
                        totalWeight = commData.weight * toFloat quantity
                        hasEnoughCredits = model.credits >= totalCost
                        hasEnoughStock = item.stock >= quantity
                        hasEnoughSpace = model.cargoUsed + totalWeight <= model.maxCargo
                    in
                    if hasEnoughCredits && hasEnoughStock && hasEnoughSpace then
                        let
                            newCredits = model.credits - totalCost
                            newCargoUsed = model.cargoUsed + totalWeight
                            currentInventory = Dict.get commodity model.inventory |> Maybe.withDefault 0
                            newInventory = Dict.insert commodity (currentInventory + quantity) model.inventory
                            
                            updatedMarket = Dict.insert commodity { item | stock = item.stock - quantity } planet.market
                            updatedPlanet = { planet | market = updatedMarket }
                            newPlanets = Dict.insert model.currentPlanet updatedPlanet model.planets
                            
                            logEntry =
                                { message = "Purchased " ++ String.fromInt quantity ++ " units of " ++ commodity ++ " for " ++ formatCredits totalCost ++ " CR."
                                , colorClass = "text-green-400"
                                , timestamp = formatTime model.currentTime
                                }
                            
                            newModel =
                                { model
                                    | credits = newCredits
                                    , cargoUsed = newCargoUsed
                                    , inventory = newInventory
                                    , planets = newPlanets
                                }
                                |> addLogEntry logEntry
                        in
                        ( newModel, Cmd.none )
                    else
                        let
                            errorMsg =
                                if not hasEnoughCredits then
                                    "Insufficient credits to buy " ++ String.fromInt quantity ++ " units of " ++ commodity ++ "!"
                                else if not hasEnoughStock then
                                    "Not enough " ++ commodity ++ " available in the market!"
                                else
                                    "Not enough cargo space for " ++ String.fromInt quantity ++ " units of " ++ commodity ++ "!"
                            
                            logEntry =
                                { message = errorMsg
                                , colorClass = "text-red-400"
                                , timestamp = formatTime model.currentTime
                                }
                        in
                        ( addLogEntry logEntry model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )

sellCommodity : String -> Int -> Model -> ( Model, Cmd Msg )
sellCommodity commodity quantity model =
    let
        currentInventory = Dict.get commodity model.inventory |> Maybe.withDefault 0
        currentPlanetData = Dict.get model.currentPlanet model.planets
        commodityData = Dict.get commodity model.commodities
    in
    if currentInventory >= quantity then
        case (currentPlanetData, commodityData) of
            (Just planet, Just commData) ->
                case Dict.get commodity planet.market of
                    Just item ->
                        let
                            totalValue = item.price * quantity
                            totalWeight = commData.weight * toFloat quantity
                            
                            newCredits = model.credits + totalValue
                            newCargoUsed = model.cargoUsed - totalWeight
                            newInventoryAmount = currentInventory - quantity
                            newInventory = 
                                if newInventoryAmount <= 0 then
                                    Dict.remove commodity model.inventory
                                else
                                    Dict.insert commodity newInventoryAmount model.inventory
                            
                            updatedMarket = Dict.insert commodity { item | stock = item.stock + quantity } planet.market
                            updatedPlanet = { planet | market = updatedMarket }
                            newPlanets = Dict.insert model.currentPlanet updatedPlanet model.planets
                            
                            logEntry =
                                { message = "Sold " ++ String.fromInt quantity ++ " units of " ++ commodity ++ " for " ++ formatCredits totalValue ++ " CR."
                                , colorClass = "text-green-400"
                                , timestamp = formatTime model.currentTime
                                }
                            
                            newModel =
                                { model
                                    | credits = newCredits
                                    , cargoUsed = newCargoUsed
                                    , inventory = newInventory
                                    , planets = newPlanets
                                }
                                |> addLogEntry logEntry
                        in
                        ( newModel, Cmd.none )

                    Nothing ->
                        let
                            logEntry =
                                { message = "Nobody wants to buy " ++ commodity ++ " on this planet!"
                                , colorClass = "text-red-400"
                                , timestamp = formatTime model.currentTime
                                }
                        in
                        ( addLogEntry logEntry model, Cmd.none )

            _ ->
                ( model, Cmd.none )
    else
        let
            logEntry =
                { message = "You don't have " ++ String.fromInt quantity ++ " units of " ++ commodity ++ " to sell!"
                , colorClass = "text-red-400"
                , timestamp = formatTime model.currentTime
                }
        in
        ( addLogEntry logEntry model, Cmd.none )

addLogEntry : LogEntry -> Model -> Model
addLogEntry entry model =
    let
        newLog = entry :: model.eventLog |> List.take 50
    in
    { model | eventLog = newLog }

formatCredits : Int -> String
formatCredits credits =
    String.fromInt credits

refuel : Model -> ( Model, Cmd Msg )
refuel model =
    let
        fuelNeeded = 100 - model.fuel
        costPerFuel = 10
        totalCost = fuelNeeded * costPerFuel
    in
    if fuelNeeded <= 0 then
        ( model, Cmd.none )
    else if model.credits >= totalCost then
        let
            logEntry =
                { message = "Refueled " ++ String.fromInt fuelNeeded ++ " units for " ++ formatCredits totalCost ++ " CR."
                , colorClass = "text-green-400"
                , timestamp = formatTime model.currentTime
                }

            newModel =
                { model
                    | fuel = 100
                    , credits = model.credits - totalCost
                }
                |> addLogEntry logEntry
        in
        ( newModel, Cmd.none )
    else
        let
            logEntry =
                { message = "Insufficient credits to refuel."
                , colorClass = "text-red-400"
                , timestamp = formatTime model.currentTime
                }
        in
        ( addLogEntry logEntry model, Cmd.none )

formatTime : Int -> String
formatTime time =
    let
        hours = time // 3600
        minutes = (time // 60) |> modBy 60
        seconds = time |> modBy 60
    in
    String.padLeft 2 '0' (String.fromInt hours) ++ ":" ++
    String.padLeft 2 '0' (String.fromInt minutes) ++ ":" ++
    String.padLeft 2 '0' (String.fromInt seconds)


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    if model.inTransit then
        Time.every 1000 (\_ -> TravelTick)
    else
        Time.every 1000 (\posix -> UpdateTime (Time.posixToMillis posix // 1000))


-- VIEW

view : Model -> Html Msg
view model =
    div
        [ css
            [ backgroundColor (hex "000428")
            , backgroundImage (linearGradient2 toBottom (stop (hex "000428")) (stop (hex "000000")) [])
            , color (hex "ffffff")
            , minHeight (vh 100)
            , fontFamily monospace
            ]
        ]
        [ Css.Global.global
            [ Css.Global.everything
                [ boxSizing borderBox
                ]
            ]
        , div
            [ css
                [ maxWidth (px 1200)
                , margin2 zero auto
                , padding (px 32)
                ]
            ]
            [ viewHeader model
            , div
                [ css
                    [ displayFlex
                    , flexWrap Css.wrap
                    , marginTop (px 24)
                    , Css.property "gap" "24px"
                    ]
                ]
                [ viewLeftPanel model
                , viewRightPanel model
                ]
            , viewEventLog model
            ]
        ]

viewHeader : Model -> Html Msg
viewHeader model =
    header
        [ css
            [ displayFlex
            , flexDirection column
            , alignItems center
            , marginBottom (px 32)
            , borderBottom3 (px 1) solid (hex "3b82f6")
            , paddingBottom (px 16)
            , Media.withMedia [ Media.all [ Media.minWidth (px 768) ] ]
                [ flexDirection row
                , justifyContent spaceBetween
                ]
            ]
        ]
        [ div
            [ css
                [ displayFlex
                , alignItems center
                , marginBottom (px 16)
                , Media.withMedia [ Media.all [ Media.minWidth (px 768) ] ]
                    [ marginBottom zero
                    ]
                ]
            ]
            [ i
                [ css
                    [ fontSize (px 24)
                    , color (hex "60a5fa")
                    , marginRight (px 12)
                    ]
                ]
                [ text "🚀" ]
            , h1
                [ css
                    [ fontSize (px 24)
                    , fontWeight bold
                    , backgroundImage (linearGradient2 toRight (stop (hex "60a5fa")) (stop (hex "a855f7")) [])
                    , Css.property "-webkit-background-clip" "text"
                    , Css.property "-webkit-text-fill-color" "transparent"
                    , Css.property "background-clip" "text"
                    ]
                ]
                [ text "GALACTIC TRADER" ]
            ]
        , div
            [ css
                [ displayFlex
                , flexDirection column
                , Css.property "gap" "16px"
                , fontSize (px 14)
                , Media.withMedia [ Media.all [ Media.minWidth (px 640) ] ]
                    [ flexDirection row
                    ]
                ]
            ]
            [ viewStatBox "💰" (formatCredits model.credits ++ " CR")
            , viewStatBox "📦" (String.fromFloat model.cargoUsed ++ "/" ++ String.fromFloat model.maxCargo ++ " T")
            , viewStatBox "📍" model.currentPlanet
            ]
        ]

viewStatBox : String -> String -> Html Msg
viewStatBox icon text_ =
    div
        [ css
            [ backgroundColor (hex "1f2937")
            , padding2 (px 8) (px 16)
            , borderRadius (px 8)
            , displayFlex
            , alignItems center
            ]
        ]
        [ span [ css [ marginRight (px 8) ] ] [ text icon ]
        , text text_
        ]

viewLeftPanel : Model -> Html Msg
viewLeftPanel model =
    div
        [ css
            [ flex (int 1)
            , minWidth (px 300)
            , Css.property "gap" "24px"
            , displayFlex
            , flexDirection column
            ]
        ]
        [ viewShipDisplay model
        , viewNavigationPanel model
        ]

viewShipDisplay : Model -> Html Msg
viewShipDisplay model =
    div
        [ css
            [ backgroundColor (rgba 0 0 0 0.7)
            , border3 (px 1) solid (hex "00bfff")
            , borderRadius (px 8)
            , padding (px 16)
            ]
        ]
        [ h2
            [ css
                [ fontSize (px 20)
                , fontWeight bold
                , marginBottom (px 16)
                , borderBottom3 (px 1) solid (hex "3b82f6")
                , paddingBottom (px 8)
                , displayFlex
                , alignItems center
                ]
            ]
            [ span [ css [ marginRight (px 8) ] ] [ text "🚀" ]
            , text "STARHAWK"
            ]
        , viewProgressBar "Fuel" model.fuel 100
        , viewProgressBar "Hull" model.hull 100
        , button
            [ css
                [ Css.width (pct 100)
                , marginTop (px 16)
                , padding2 (px 8) zero
                , borderRadius (px 8)
                , fontWeight bold
                , border zero
                , color (hex "ffffff")
                , cursor pointer
                , backgroundColor (hex "16a34a")
                , hover [ backgroundColor (hex "15803d") ]
                ]
            , onClick Refuel
            ]
            [ text "Refuel" ]
        , div
            [ css
                [ displayFlex
                , Css.property "gap" "8px"
                , fontSize (px 14)
                , marginTop (px 16)
                ]
            ]
            [ viewInfoBox "Speed" "5 LY/h"
            , viewInfoBox "Cargo" "50 T"
            ]
        ]

viewProgressBar : String -> Int -> Int -> Html Msg
viewProgressBar label current max_ =
    div
        [ css
            [ marginBottom (px 16)
            ]
        ]
        [ div
            [ css
                [ displayFlex
                , justifyContent spaceBetween
                , fontSize (px 14)
                , marginBottom (px 4)
                ]
            ]
            [ text label
            , text (String.fromInt current ++ "/" ++ String.fromInt max_ ++ if label == "Fuel" then " LY" else "%")
            ]
        , div
            [ css
                [ Css.width (pct 100)
                , backgroundColor (hex "374151")
                , borderRadius (px 2)
                , Css.height (px 8)
                ]
            ]
            [ div
                [ css
                    [ Css.height (px 8)
                    , borderRadius (px 2)
                    , Css.width (pct (toFloat current / toFloat max_ * 100))
                    , backgroundImage 
                        (if current < 20 && label == "Fuel" then
                            linearGradient2 toRight (stop (hex "ff0000")) (stop (hex "990000")) []
                        else
                            linearGradient2 toRight (stop (hex "00bfff")) (stop (hex "0066ff")) []
                        )
                    ]
                ]
                []
            ]
        ]

viewInfoBox : String -> String -> Html Msg
viewInfoBox label value =
    div
        [ css
            [ backgroundColor (hex "1f2937")
            , padding (px 8)
            , borderRadius (px 4)
            , flex (int 1)
            ]
        ]
        [ div [ css [ color (hex "9ca3af"), fontSize (px 12) ] ] [ text label ]
        , div [] [ text value ]
        ]

viewNavigationPanel : Model -> Html Msg
viewNavigationPanel model =
    div
        [ css
            [ backgroundColor (rgba 17 24 39 0.7)
            , padding (px 16)
            , borderRadius (px 8)
            , border3 (px 1) solid (hex "3b82f6")
            ]
        ]
        [ h2
            [ css
                [ fontSize (px 20)
                , fontWeight bold
                , marginBottom (px 16)
                , borderBottom3 (px 1) solid (hex "3b82f6")
                , paddingBottom (px 8)
                , displayFlex
                , alignItems center
                ]
            ]
            [ span [ css [ marginRight (px 8) ] ] [ text "🗺️" ]
            , text "NAVIGATION"
            ]
        , div
            [ css
                [ Css.property "gap" "12px"
                , displayFlex
                , flexDirection column
                ]
            ]
            (viewPlanetList model)
        , viewTravelInfo model
        , viewTravelButton model
        ]

viewPlanetList : Model -> List (Html Msg)
viewPlanetList model =
    model.planets
        |> Dict.toList

        |> List.map (viewPlanetItem model)

viewPlanetItem : Model -> (String, Planet) -> Html Msg
viewPlanetItem model (name, planet) =
    let
        isSelected = model.selectedDestination == Just name
    in
    div
        [ css
            [ displayFlex
            , justifyContent spaceBetween
            , alignItems center
            , padding (px 8)
            , borderRadius (px 8)
            , cursor pointer
            , backgroundColor 
                (if isSelected then
                    rgba 59 130 246 0.5
                else
                    hex "1f2937"
                )
            , border3 (px 1) solid 
                (if isSelected then
                    hex "3b82f6"
                else
                    (rgba 0 0 0 0)
                )
            , hover
                [ backgroundColor (rgba 59 130 246 0.3)
                ]
            ]
        , onClick (SelectDestination name)
        ]
        [ div
            [ css
                [ displayFlex
                , alignItems center
                ]
            ]
            [ span [ css [ marginRight (px 8) ] ] [ text "🌍" ]
            , span [ css [ fontWeight (int 500) ] ] [ text name ]
            ]
        , div
            [ css
                [ fontSize (px 14)
                , color (hex "9ca3af")
                ]
            ]
            [ text (String.fromFloat planet.distance ++ " LY") ]
        ]

viewTravelInfo : Model -> Html Msg
viewTravelInfo model =
    case model.selectedDestination of
        Just destination ->
            case Dict.get destination model.planets of
                Just planet ->
                    let
                        distance = planet.distance
                        fuelCost = distance * 5
                        travelTime = distance / 5
                    in
                    div
                        [ css
                            [ marginTop (px 16)
                            , padding (px 12)
                            , backgroundColor (rgba 59 130 246 0.3)
                            , borderRadius (px 4)
                            , border3 (px 1) solid (hex "3b82f6")
                            , fontSize (px 14)
                            ]
                        ]
                        [ viewTravelInfoRow "Distance:" (String.fromFloat distance ++ " LY")
                        , viewTravelInfoRow "Fuel Cost:" (String.fromFloat fuelCost ++ " LY")
                        , viewTravelInfoRow "Travel Time:" (String.fromFloat travelTime ++ " h")
                        ]

                Nothing ->
                    div [] []

        Nothing ->
            div [] []

viewTravelInfoRow : String -> String -> Html Msg
viewTravelInfoRow label value =
    div
        [ css
            [ displayFlex
            , justifyContent spaceBetween
            , marginBottom (px 4)
            ]
        ]
        [ text label
        , text value
        ]

viewTravelButton : Model -> Html Msg
viewTravelButton model =
    let
        canTravel = 
            case model.selectedDestination of
                Just destination ->
                    case Dict.get destination model.planets of
                        Just planet ->
                            let fuelCost = Basics.round (planet.distance * 5)
                            in fuelCost <= model.fuel && not model.inTransit
                        Nothing -> False
                Nothing -> False
        
        buttonText =
            if model.inTransit then
                let
                    hours = model.travelTimeLeft // 60
                    minutes = model.travelTimeLeft |> modBy 60
                in
                "🚀 TRAVELING (" ++ String.fromInt hours ++ "h " ++ String.fromInt minutes ++ "m)"
            else
                "🚀 ENGAGE DRIVE"
    in
    button
        [ css
            [ Css.width (pct 100)
            , marginTop (px 16)
            , backgroundColor 
                (if canTravel then
                    hex "2563eb"
                else
                    hex "6b7280"
                )
            , hover 
                (if canTravel then
                    [ backgroundColor (hex "1d4ed8") ]
                else
                    []
                )
            , padding2 (px 8) zero
            , borderRadius (px 8)
            , fontWeight bold
            , displayFlex
            , alignItems center
            , justifyContent center
            , border zero
            , color (hex "ffffff")
            , cursor 
                (if canTravel then
                    pointer
                else
                    notAllowed
                )
            , opacity 
                (if canTravel then
                    num 1
                else
                    num 0.5
                )
            ]
        , onClick StartTravel
        , Html.Styled.Attributes.disabled (not canTravel)
        ]
        [ text buttonText ]

viewRightPanel : Model -> Html Msg
viewRightPanel model =
    div
        [ css
            [ flex (int 2)
            , minWidth (px 600)
            , Css.property "gap" "24px"
            , displayFlex
            , flexDirection column
            ]
        ]
        [ viewMarket model
        , viewInventory model
        ]

viewMarket : Model -> Html Msg
viewMarket model =
    div
        [ css
            [ backgroundColor (rgba 17 24 39 0.7)
            , padding (px 16)
            , borderRadius (px 8)
            , border3 (px 1) solid (hex "3b82f6")
            ]
        ]
        [ h2
            [ css
                [ fontSize (px 20)
                , fontWeight bold
                , marginBottom (px 16)
                , borderBottom3 (px 1) solid (hex "3b82f6")
                , paddingBottom (px 8)
                , displayFlex
                , alignItems center
                ]
            ]
            [ span [ css [ marginRight (px 8) ] ] [ text "🛒" ]
            , text "LOCAL MARKET"
            ]
        , div
            [ css
                [ overflowX auto
                ]
            ]
            [ Html.Styled.table
                [ css
                    [ Css.width (pct 100)
                    , fontSize (px 14)
                    ]
                ]
                [ thead []
                    [ tr
                        [ css
                            [ textAlign left
                            , borderBottom3 (px 1) solid (hex "3b82f6")
                            ]
                        ]
                        [ th [ css [ paddingBottom (px 8) ] ] [ text "Commodity" ]
                        , th [ css [ paddingBottom (px 8) ] ] [ text "Price" ]
                        , th [ css [ paddingBottom (px 8) ] ] [ text "Stock" ]
                        , th [ css [ paddingBottom (px 8) ] ] [ text "Demand" ]
                        , th [ css [ paddingBottom (px 8) ] ] [ text "You Have" ]
                        , th [ css [ paddingBottom (px 8) ] ] [ text "Action" ]
                        ]
                    ]
                , tbody []
                    (viewMarketItems model)
                ]
            ]
        ]

viewMarketItems : Model -> List (Html Msg)
viewMarketItems model =
    case Dict.get model.currentPlanet model.planets of
        Just planet ->
            planet.market
                |> Dict.toList
                |> List.map (viewMarketItem model)
        
        Nothing ->
            []

viewMarketItem : Model -> (String, MarketItem) -> Html Msg
viewMarketItem model (commodity, item) =
    let
        inInventory = Dict.get commodity model.inventory |> Maybe.withDefault 0
    in
    tr
        [ css
            [ borderBottom3 (px 1) solid (hex "374151")
            , hover [ backgroundColor (hex "1f2937") ]
            ]
        ]
        [ td [ css [ paddingTop (px 12), paddingBottom (px 12) ] ] [ text commodity ]
        , td [ css [ paddingTop (px 12), paddingBottom (px 12) ] ] [ text (formatCredits item.price ++ " CR") ]
        , td [ css [ paddingTop (px 12), paddingBottom (px 12) ] ] [ text (formatCredits item.stock ++ " T") ]
        , td [ css [ paddingTop (px 12), paddingBottom (px 12) ] ] [ viewDemandBadge item.demand ]
        , td [ css [ paddingTop (px 12), paddingBottom (px 12) ] ] [ text (String.fromInt inInventory) ]
        , td [ css [ paddingTop (px 12), paddingBottom (px 12) ] ]
            [ div
                [ css
                    [ displayFlex
                    , Css.property "gap" "8px"
                    ]
                ]
                [ button
                    [ css
                        [ padding2 (px 4) (px 8)
                        , backgroundColor (hex "2563eb")
                        , hover [ backgroundColor (hex "1d4ed8") ]
                        , borderRadius (px 4)
                        , fontSize (px 12)
                        , border zero
                        , color (hex "ffffff")
                        , cursor pointer
                        ]
                    , onClick (BuyCommodity commodity 1)
                    ]
                    [ text "Buy 1" ]
                , button
                    [ css
                        [ padding2 (px 4) (px 8)
                        , backgroundColor (hex "1d4ed8")
                        , hover [ backgroundColor (hex "1e40af") ]
                        , borderRadius (px 4)
                        , fontSize (px 12)
                        , border zero
                        , color (hex "ffffff")
                        , cursor pointer
                        ]
                    , onClick (BuyCommodity commodity 5)
                    ]
                    [ text "Buy 5" ]
                ]
            ]
        ]

viewDemandBadge : Demand -> Html Msg
viewDemandBadge demand =
    let
        (bgColor, textColor, demandText) =
            case demand of
                High ->
                    (hex "166534", hex "22c55e", "High")
                
                Medium ->
                    (hex "92400e", hex "fbbf24", "Medium")
                
                Low ->
                    (hex "991b1b", hex "ef4444", "Low")
    in
    span
        [ css
            [ padding2 (px 2) (px 8)
            , borderRadius (px 4)
            , fontSize (px 12)
            , backgroundColor bgColor
            , color textColor
            ]
        ]
        [ text demandText ]

viewInventory : Model -> Html Msg
viewInventory model =
    div
        [ css
            [ backgroundColor (rgba 17 24 39 0.7)
            , padding (px 16)
            , borderRadius (px 8)
            , border3 (px 1) solid (hex "3b82f6")
            ]
        ]
        [ h2
            [ css
                [ fontSize (px 20)
                , fontWeight bold
                , marginBottom (px 16)
                , borderBottom3 (px 1) solid (hex "3b82f6")
                , paddingBottom (px 8)
                , displayFlex
                , alignItems center
                ]
            ]
            [ span [ css [ marginRight (px 8) ] ] [ text "📦" ]
            , text "CARGO HOLD"
            ]
        , div
            [ css
                [ overflowX auto
                ]
            ]
            [ Html.Styled.table
                [ css
                    [ Css.width (pct 100)
                    , fontSize (px 14)
                    ]
                ]
                [ thead []
                    [ tr
                        [ css
                            [ textAlign left
                            , borderBottom3 (px 1) solid (hex "3b82f6")
                            ]
                        ]
                        [ th [ css [ paddingBottom (px 8) ] ] [ text "Commodity" ]
                        , th [ css [ paddingBottom (px 8) ] ] [ text "Qty" ]
                        , th [ css [ paddingBottom (px 8) ] ] [ text "Buy Price" ]
                        , th [ css [ paddingBottom (px 8) ] ] [ text "Current Value" ]
                        , th [ css [ paddingBottom (px 8) ] ] [ text "Action" ]
                        ]
                    ]
                , tbody []
                    (viewInventoryItems model)
                ]
            ]
        ]

viewInventoryItems : Model -> List (Html Msg)
viewInventoryItems model =
    model.inventory
        |> Dict.toList
        |> List.filter (\(_, quantity) -> quantity > 0)
        |> List.map (viewInventoryItem model)

viewInventoryItem : Model -> (String, Int) -> Html Msg
viewInventoryItem model (commodity, quantity) =
    let
        currentPlanet = Dict.get model.currentPlanet model.planets
        currentPrice = 
            case currentPlanet of
                Just planet ->
                    case Dict.get commodity planet.market of
                        Just item -> item.price
                        Nothing -> 0
                Nothing -> 0
        
        buyPrice = Basics.round (toFloat currentPrice * 0.8) -- Simplified buy price calculation
        _ = Basics.round (toFloat currentPrice * 1.1) -- Simplified sell price calculation
        totalValue = currentPrice * quantity
    in
    tr
        [ css
            [ borderBottom3 (px 1) solid (hex "374151")
            , hover [ backgroundColor (hex "1f2937") ]
            ]
        ]
        [ td [ css [ paddingTop (px 12), paddingBottom (px 12) ] ] [ text commodity ]
        , td [ css [ paddingTop (px 12), paddingBottom (px 12) ] ] [ text (formatCredits quantity ++ " T") ]
        , td [ css [ paddingTop (px 12), paddingBottom (px 12) ] ] [ text (formatCredits buyPrice ++ " CR") ]
        , td [ css [ paddingTop (px 12), paddingBottom (px 12) ] ] [ text (formatCredits totalValue ++ " CR") ]
        , td [ css [ paddingTop (px 12), paddingBottom (px 12) ] ]
            [ div
                [ css
                    [ displayFlex
                    , Css.property "gap" "8px"
                    ]
                ]
                [ button
                    [ css
                        [ padding2 (px 4) (px 8)
                        , backgroundColor (hex "7c3aed")
                        , hover [ backgroundColor (hex "6d28d9") ]
                        , borderRadius (px 4)
                        , fontSize (px 12)
                        , border zero
                        , color (hex "ffffff")
                        , cursor pointer
                        ]
                    , onClick (SellCommodity commodity 1)
                    ]
                    [ text "Sell 1" ]
                , button
                    [ css
                        [ padding2 (px 4) (px 8)
                        , backgroundColor (hex "6d28d9")
                        , hover [ backgroundColor (hex "5b21b6") ]
                        , borderRadius (px 4)
                        , fontSize (px 12)
                        , border zero
                        , color (hex "ffffff")
                        , cursor pointer
                        ]
                    , onClick (SellCommodity commodity 5)
                    ]
                    [ text "Sell 5" ]
                ]
            ]
        ]

viewEventLog : Model -> Html Msg
viewEventLog model =
    div
        [ css
            [ marginTop (px 32)
            , backgroundColor (rgba 17 24 39 0.7)
            , padding (px 16)
            , borderRadius (px 8)
            , border3 (px 1) solid (hex "3b82f6")
            , maxHeight (px 192)
            , overflowY auto
            ]
        ]
        [ h2
            [ css
                [ fontSize (px 20)
                , fontWeight bold
                , marginBottom (px 8)
                , borderBottom3 (px 1) solid (hex "3b82f6")
                , paddingBottom (px 8)
                , displayFlex
                , alignItems center
                ]
            ]
            [ span [ css [ marginRight (px 8) ] ] [ text "📜" ]
            , text "SHIP'S LOG"
            ]
        , div
            [ css
                [ fontSize (px 14)
                , Css.property "gap" "4px"
                , displayFlex
                , flexDirection column
                ]
            ]
            (model.eventLog |> List.map viewLogEntry)
        ]

viewLogEntry : LogEntry -> Html Msg
viewLogEntry entry =
    div
        [ css
            [ color 
                (case entry.colorClass of
                    "text-blue-400" -> hex "60a5fa"
                    "text-green-400" -> hex "4ade80"
                    "text-red-400" -> hex "f87171"
                    "text-gray-400" -> hex "9ca3af"
                    _ -> hex "ffffff"
                )
            ]
        ]
        [ text ("[" ++ entry.timestamp ++ "] " ++ entry.message) ]