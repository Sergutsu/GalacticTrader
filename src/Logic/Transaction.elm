module Logic.Transaction exposing (buyGood, sellGood, buyBulkGoods, sellBulkGoods, createPlayerTrade, acceptPlayerTrade, TransactionError(..), TransactionResult, TradeOffer, TradeStatus(..))

import Dict exposing (Dict)
import List.Extra as List
import Logic.Ship as ShipLogic
import Models.Good exposing (Good)
import Models.Planet exposing (Planet)
import Models.Player exposing (Player, PlayerId)
import Models.Ship exposing (Ship)
import Time exposing (Posix)


{-| Check if all key-value pairs in a dictionary satisfy a predicate.
This is similar to List.all but for dictionaries.
-}
dictAll : (comparable -> v -> Bool) -> Dict comparable v -> Bool
dictAll predicate dict =
    Dict.foldl
        (\k v acc -> acc && predicate k v)
        True
        dict


type alias TransactionFee =
    { percentage : Float  -- Percentage fee (0.0 - 1.0)
    , flat : Int         -- Flat fee in credits
    }


type TransactionError
    = NotEnoughCredits
    | NotEnoughStock
    | NotEnoughCargoSpace
    | ItemNotInCargo
    | ItemNotInMarket
    | InvalidShip
    | InvalidQuantity
    | TradeOfferExpired
    | TradeOfferNotFound
    | TradeOfferInvalid
    | TradeWithSelf


type TradeStatus
    = Pending
    | Accepted
    | Rejected
    | Expired


type alias TradeOffer =
    { id : String
    , fromPlayerId : PlayerId
    , toPlayerId : PlayerId
    , offerGoods : Dict String Int  -- Good name to quantity
    , requestGoods : Dict String Int  -- Good name to quantity
    , offerCredits : Int
    , requestCredits : Int
    , status : TradeStatus
    , expiresAt : Posix
    , createdAt : Posix
    }


type alias TransactionResult =
    { success : Bool
    , error : Maybe TransactionError
    , updatedShips : List Ship
    , updatedPlayer : Player
    , updatedPlanet : Planet
    , transactionFees : Int
    }


{-| Calculate the dynamic price based on supply and demand
-}
calculateDynamicPrice : String -> Planet -> Int -> Int
calculateDynamicPrice goodName planet quantity =
    case Dict.get goodName planet.market of
        Just good ->
            let
                -- Base price with supply/demand adjustment
                supplyRatio = toFloat good.stock / toFloat (max 1 good.baseStock)
                demandFactor = 1.0 + (1.0 - supplyRatio) * 0.5  -- 0.5 is the max price multiplier
                basePrice = good.price
                
                -- Bulk discount (buying more gives better prices)
                bulkDiscount = 
                    if quantity >= 10 then 0.9    -- 10% discount for 10+ units
                    else if quantity >= 5 then 0.95 -- 5% discount for 5+ units
                    else 1.0
                
                -- Final price calculation
                adjustedPrice = toFloat basePrice * demandFactor * bulkDiscount
            in
            max 1 (round adjustedPrice)  -- Ensure price is at least 1
            
        Nothing ->
            0


{-| Calculate transaction fees
-}
calculateTransactionFees : Int -> TransactionFee -> Int
calculateTransactionFees amount { percentage, flat } =
    let
        percentageFee = toFloat amount * percentage |> round
    in
    percentageFee + flat


{-| Buy a single good
-}
buyGood : String -> Int -> List Ship -> Int -> Player -> Planet -> TransactionResult
buyGood goodName quantity ships activeShipIndex player planet =
    if quantity <= 0 then
        transactionError InvalidQuantity ships player planet 0
    else
        buyBulkGoods (Dict.singleton goodName quantity) ships activeShipIndex player planet


{-| Sell a single good
-}
sellGood : String -> Int -> List Ship -> Int -> Player -> Planet -> TransactionResult
sellGood goodName quantity ships activeShipIndex player planet =
    if quantity <= 0 then
        transactionError InvalidQuantity ships player planet 0
    else
        sellBulkGoods (Dict.singleton goodName quantity) ships activeShipIndex player planet


{-| Buy multiple goods in a single transaction with bulk discounts
-}
buyBulkGoods : Dict String Int -> List Ship -> Int -> Player -> Planet -> TransactionResult
buyBulkGoods goods ships activeShipIndex player planet =
    case getActiveShip activeShipIndex ships of
        Just ship ->
            let
                -- Calculate total cost and check stock
                ( totalCost, hasEnoughStock, hasEnoughSpace ) =
                    Dict.foldl
                        (\goodName q (cost, stockOk, spaceOk) ->
                            case Dict.get goodName planet.market of
                                Just good ->
                                    let
                                        price = calculateDynamicPrice goodName planet q
                                        newCost = cost + (price * q)
                                        newStockOk = stockOk && good.stock >= q
                                        newSpaceOk = spaceOk && (ShipLogic.getAvailableCargoSpace ship >= q)
                                    in
                                    ( newCost, newStockOk, newSpaceOk )
                                        
                                Nothing ->
                                    ( cost, False, spaceOk )
                        )
                        ( 0, True, True )
                        goods
                
                -- Calculate transaction fees
                transactionFees = calculateTransactionFees totalCost { percentage = 0.05, flat = 10 }
                totalWithFees = totalCost + transactionFees
                
                -- Check if transaction is possible
                canProceed = 
                    hasEnoughStock 
                    && hasEnoughSpace 
                    && player.credits >= totalWithFees
                    && not (Dict.isEmpty goods)
            in
            if not canProceed then
                let
                    error =
                        if not hasEnoughStock then
                            NotEnoughStock
                        else if not hasEnoughSpace then
                            NotEnoughCargoSpace
                        else if player.credits < totalWithFees then
                            NotEnoughCredits
                        else
                            InvalidQuantity
                in
                transactionError error ships player planet transactionFees
                
            else
                -- Process the transaction
                let
                    -- Update ship cargo
                    ( updatedShip, cargoUpdated ) =
                        Dict.foldl
                            (\goodName q (currentShip, success) ->
                                if not success then
                                    ( currentShip, False )
                                else
                                    case ShipLogic.addCargo goodName q currentShip of
                                        Just updated -> ( updated, True )
                                        Nothing -> ( currentShip, False )
                            )
                            ( ship, True )
                            goods
                    
                    -- Update market stock
                    updatedMarket =
                        Dict.foldl
                            (\goodName q market ->
                                updateMarketStock goodName -q market
                            )
                            planet.market
                            goods
                    
                    -- Update player credits
                    updatedPlayer = 
                        { player | credits = player.credits - totalWithFees }
                    
                    updatedPlanet = 
                        { planet | market = updatedMarket }
                    
                    updatedShips = updateShips activeShipIndex updatedShip ships
                in
                if cargoUpdated then
                    transactionSuccess updatedShips updatedPlayer updatedPlanet transactionFees
                else
                    transactionError NotEnoughCargoSpace ships player planet transactionFees
                    
        Nothing ->
            transactionError InvalidShip ships player planet 0


{-| Sell multiple goods in a single transaction
-}
sellBulkGoods : Dict String Int -> List Ship -> Int -> Player -> Planet -> TransactionResult
sellBulkGoods goods ships activeShipIndex player planet =
    case getActiveShip activeShipIndex ships of
        Just ship ->
            let
                -- Calculate total value and check cargo
                ( totalValue, hasEnoughCargo, allGoodsInMarket ) =
                    Dict.foldl
                        (\goodName q (value, cargoOk, marketOk) ->
                            -- Check if we have enough in cargo
                            let
                                hasEnough = Dict.get goodName ship.cargo |> Maybe.map (\stock -> stock >= q) |> Maybe.withDefault False
                                
                                -- Calculate value based on market price
                                goodValue =
                                    case Dict.get goodName planet.market of
                                        Just _ ->
                                            let
                                                price = calculateDynamicPrice goodName planet -q  -- Negative quantity for selling
                                            in
                                            price * q
                                                
                                        Nothing ->
                                            0
                            in
                            ( value + goodValue
                            , cargoOk && hasEnough
                            , marketOk && Dict.member goodName planet.market
                            )
                        )
                        ( 0, True, True )
                        goods
                
                -- Calculate transaction fees (lower for selling to encourage trading)
                transactionFees = calculateTransactionFees totalValue { percentage = 0.02, flat = 5 }
                totalAfterFees = max 0 (totalValue - transactionFees)  -- Ensure we don't go negative
                
                -- Check if transaction is possible
                canProceed = 
                    hasEnoughCargo 
                    && allGoodsInMarket 
                    && not (Dict.isEmpty goods)
            in
            if not canProceed then
                let
                    error =
                        if not hasEnoughCargo then
                            ItemNotInCargo
                        else if not allGoodsInMarket then
                            ItemNotInMarket
                        else
                            InvalidQuantity
                in
                transactionError error ships player planet transactionFees
                
            else
                -- Process the transaction
                let
                    -- Update ship cargo
                    ( updatedShip, cargoUpdated ) =
                        Dict.foldl
                            (\goodName q (currentShip, success) ->
                                if not success then
                                    ( currentShip, False )
                                else
                                    case ShipLogic.removeCargo goodName q currentShip of
                                        Just updated -> ( updated, True )
                                        Nothing -> ( currentShip, False )
                            )
                            ( ship, True )
                            goods
                    
                    -- Update market stock
                    updatedMarket =
                        Dict.foldl
                            (\goodName q market ->
                                updateMarketStock goodName q market
                            )
                            planet.market
                            goods
                    
                    -- Update player credits
                    updatedPlayer = 
                        { player | credits = player.credits + totalAfterFees }
                    
                    updatedPlanet = 
                        { planet | market = updatedMarket }
                    
                    updatedShips = updateShips activeShipIndex updatedShip ships
                in
                if cargoUpdated then
                    transactionSuccess updatedShips updatedPlayer updatedPlanet transactionFees
                else
                    transactionError ItemNotInCargo ships player planet transactionFees
                    
        Nothing ->
            transactionError InvalidShip ships player planet 0


{-| Create a trade offer between players
-}
createPlayerTrade : 
    PlayerId 
    -> PlayerId 
    -> Dict String Int  -- Offer goods
    -> Dict String Int  -- Request goods
    -> Int  -- Offer credits
    -> Int  -- Request credits
    -> Posix  -- Current time
    -> Posix  -- Expiration time
    -> Result String TradeOffer
createPlayerTrade fromPlayerId toPlayerId offerGoods requestGoods offerCredits requestCredits now expiresAt =
    if fromPlayerId == toPlayerId then
        Err "Cannot trade with yourself"
    else if Dict.isEmpty offerGoods && offerCredits <= 0 then
        Err "Must offer something in the trade"
    else if Dict.isEmpty requestGoods && requestCredits <= 0 then
        Err "Must request something in the trade"
    else if Time.posixToMillis expiresAt <= Time.posixToMillis now then
        Err "Expiration time must be in the future"
    else
        Ok
            { id = "trade_" ++ String.fromInt (Time.posixToMillis now)
            , fromPlayerId = fromPlayerId
            , toPlayerId = toPlayerId
            , offerGoods = offerGoods
            , requestGoods = requestGoods
            , offerCredits = offerCredits
            , requestCredits = requestCredits
            , status = Pending
            , expiresAt = expiresAt
            , createdAt = now
            }


{-| Accept a trade offer
-}
acceptPlayerTrade : 
    TradeOffer 
    -> Player  -- From player
    -> Player  -- To player
    -> List Ship  -- From player's ships
    -> List Ship  -- To player's ships
    -> Posix  -- Current time
    -> Result TransactionError { fromPlayer : Player, toPlayer : Player, fromShips : List Ship, toShips : List Ship }
acceptPlayerTrade tradeOffer fromPlayer toPlayer fromShips toShips now =
    if tradeOffer.status /= Pending then
        Err TradeOfferInvalid
    else if Time.posixToMillis tradeOffer.expiresAt <= Time.posixToMillis now then
        Err TradeOfferExpired
    else if fromPlayer.id /= tradeOffer.fromPlayerId || toPlayer.id /= tradeOffer.toPlayerId then
        Err TradeOfferInvalid
    else if fromPlayer.credits < tradeOffer.offerCredits then
        Err NotEnoughCredits
    else if toPlayer.credits < tradeOffer.requestCredits then
        Err NotEnoughCredits
    else
        -- Check if both players have the required goods
        let
            fromPlayerHasGoods =
                dictAll
                    (\goodName quantity ->
                        ShipLogic.getCargoTotal goodName fromShips >= quantity
                    )
                    tradeOffer.offerGoods
            
            toPlayerHasGoods =
                dictAll
                    (\goodName quantity ->
                        ShipLogic.getCargoTotal goodName toShips >= quantity
                    )
                    tradeOffer.requestGoods
        in
        if not (fromPlayerHasGoods && toPlayerHasGoods) then
            Err ItemNotInCargo
        else
            -- Process the trade
            let
                -- Transfer goods from fromPlayer to toPlayer
                ( updatedFromShips, fromTransferSuccess ) =
                    Dict.foldl
                        (\goodName quantity (currentShips, success) ->
                            if not success then
                                ( currentShips, False )
                            else
                                -- Find the first ship with the cargo to transfer
                                case List.find (\ship -> Dict.member goodName ship.cargo) currentShips of
                                    Just sourceShip ->
                                        -- Find the first ship with enough space
                                        case List.find (\ship -> 
                                            let
                                                currentQty = Dict.get goodName ship.cargo |> Maybe.withDefault 0
                                                spaceNeeded = max 0 (quantity - currentQty)
                                            in
                                            ShipLogic.getAvailableCargoSpace ship >= spaceNeeded
                                        ) toShips of
                                            Just targetShip ->
                                                case ShipLogic.transferCargoBetweenShips goodName quantity sourceShip targetShip of
                                                    Just transferResult ->
                                                        ( List.map (\s -> 
                                                            if s.id == sourceShip.id then transferResult.fromShip 
                                                            else if s.id == targetShip.id then transferResult.toShip 
                                                            else s
                                                          ) currentShips
                                                        , True
                                                        )
                                                    Nothing ->
                                                        ( currentShips, False )
                                            Nothing ->
                                                ( currentShips, False )
                                    Nothing ->
                                        ( currentShips, False )
                        )
                        ( fromShips, True )
                        tradeOffer.offerGoods
                
                -- Transfer goods from toPlayer to fromPlayer
                ( updatedToShips, toTransferSuccess ) =
                    if not fromTransferSuccess then
                        ( toShips, False )
                    else
                        Dict.foldl
                            (\goodName quantity (currentShips, success) ->
                                if not success then
                                    ( currentShips, False )
                                else
                                    -- Find the first ship with the cargo to transfer
                                    case List.find (\ship -> Dict.member goodName ship.cargo) toShips of
                                        Just sourceShip ->
                                            -- Find the first ship with enough space
                                            case List.find (\ship -> 
                                                let
                                                    currentQty = Dict.get goodName ship.cargo |> Maybe.withDefault 0
                                                    spaceNeeded = max 0 (quantity - currentQty)
                                                in
                                                ShipLogic.getAvailableCargoSpace ship >= spaceNeeded
                                            ) updatedFromShips of
                                                Just targetShip ->
                                                    case ShipLogic.transferCargoBetweenShips goodName quantity sourceShip targetShip of
                                                        Just transferResult ->
                                                            ( List.map (\s -> 
                                                                if s.id == sourceShip.id then transferResult.fromShip 
                                                                else if s.id == targetShip.id then transferResult.toShip 
                                                                else s
                                                              ) currentShips
                                                            , True
                                                            )
                                                        Nothing ->
                                                            ( currentShips, False )
                                                Nothing ->
                                                    ( currentShips, False )
                                        Nothing ->
                                            ( currentShips, False )
                            )
                            ( toShips, True )
                            tradeOffer.requestGoods
                
                -- Update player credits
                updatedFromPlayer =
                    { fromPlayer 
                        | credits = fromPlayer.credits - tradeOffer.offerCredits + tradeOffer.requestCredits
                    }
                
                updatedToPlayer =
                    { toPlayer
                        | credits = toPlayer.credits + tradeOffer.offerCredits - tradeOffer.requestCredits
                    }
            in
            if fromTransferSuccess && toTransferSuccess then
                Ok
                    { fromPlayer = updatedFromPlayer
                    , toPlayer = updatedToPlayer
                    , fromShips = updatedFromShips
                    , toShips = updatedToShips
                    }
            else
                Err TradeOfferInvalid


-- Helper functions

getActiveShip : Int -> List Ship -> Maybe Ship
getActiveShip activeShipIndex ships =
    List.head (List.drop activeShipIndex ships)


updateShips : Int -> Ship -> List Ship -> List Ship
updateShips index updatedShip ships =
    List.indexedMap (\i s -> if i == index then updatedShip else s) ships


updateMarketStock : String -> Int -> Dict String Good -> Dict String Good
updateMarketStock goodName delta market =
    Dict.update goodName
        (Maybe.map (\good -> { good | stock = good.stock + delta }))
        market


transactionError : TransactionError -> List Ship -> Player -> Planet -> Int -> TransactionResult
transactionError error ships player planet fees =
    { success = False
    , error = Just error
    , updatedShips = ships
    , updatedPlayer = player
    , updatedPlanet = planet
    , transactionFees = fees
    }


transactionSuccess : List Ship -> Player -> Planet -> Int -> TransactionResult
transactionSuccess ships player planet fees =
    { success = True
    , error = Nothing
    , updatedShips = ships
    , updatedPlayer = player
    , updatedPlanet = planet
    , transactionFees = fees
    }
