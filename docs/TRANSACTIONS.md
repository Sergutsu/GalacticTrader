# Galactic Trader - Transaction System

This document describes the transaction system used in the Galactic Trader game for handling buying and selling of goods.

## Overview

The transaction system provides a simple and robust way to handle in-game transactions between players and planet markets. It ensures that all transactions are atomic and that the game state remains consistent.

## Core Types

### TransactionError

```elm
type TransactionError
    = NotEnoughCredits
    | NotEnoughStock
    | NotEnoughCargoSpace
    | ItemNotInCargo
    | ItemNotInMarket
    | InvalidShip
```

### TransactionResult

```elm
type alias TransactionResult =
    { success : Bool
    , error : Maybe TransactionError
    , updatedShips : List Ship
    , updatedPlayer : Player
    , updatedPlanet : Planet
    }
```

## Main Functions

### `buyGood`

```elm
buyGood : String -> List Ship -> Int -> Player -> Planet -> TransactionResult
```

Attempts to buy a specified good from a planet's market and add it to the player's ship cargo.

**Parameters:**
- `goodName`: The name of the good to buy
- `ships`: List of all ships
- `activeShipIndex`: Index of the player's active ship
- `player`: The player making the purchase
- `planet`: The planet where the transaction is taking place

**Returns:**
A `TransactionResult` indicating success/failure and containing the updated game state.

### `sellGood`

```elm
sellGood : String -> List Ship -> Int -> Player -> Planet -> TransactionResult
```

Attempts to sell a specified good from the player's ship cargo to a planet's market.

**Parameters:**
- `goodName`: The name of the good to sell
- `ships`: List of all ships
- `activeShipIndex`: Index of the player's active ship
- `player`: The player making the sale
- `planet`: The planet where the transaction is taking place

**Returns:**
A `TransactionResult` indicating success/failure and containing the updated game state.

## Error Handling

The system provides detailed error information through the `TransactionError` type. All possible error conditions are explicitly handled:

- `NotEnoughCredits`: Player doesn't have enough money for the transaction
- `NotEnoughStock`: Planet market doesn't have enough of the requested item
- `NotEnoughCargoSpace`: Player's ship doesn't have enough cargo space
- `ItemNotInCargo`: Player tried to sell an item they don't have
- `ItemNotInMarket`: Requested item is not available in the market
- `InvalidShip`: The specified ship doesn't exist

## Integration with Game Loop

The transaction system is integrated with the main game loop through the `handleBuy` and `handleSell` functions in `Logic/Game.elm`. These functions:

1. Get the current planet's market data
2. Execute the transaction
3. Update the game state with the results
4. Add appropriate messages to the game log

## Testing

Unit tests are available in `tests/TransactionTests.elm` and can be run using:

```bash
npx elm-test
```

## Example Usage

```elm
-- Buying an item
case getCurrentPlanet model of
    Just planet ->
        let
            result = 
                Transaction.buyGood 
                    "Food" 
                    model.ships 
                    model.activeShipIndex 
                    model.player 
                    planet
        in
        if result.success then
            { model 
                | ships = result.updatedShips
                , player = result.updatedPlayer
                , starSystems = updatePlanetInSystems result.updatedPlanet model.starSystems
                , messages = "Bought 1 Food" :: model.messages
            }
        else
            -- Handle error
            { model | messages = (errorToString result.error) :: model.messages }
    
    Nothing ->
        { model | messages = "Not at a valid location" :: model.messages }
```

## Future Improvements

- Add bulk transaction support
- Implement price fluctuations based on supply and demand
- Add transaction fees or taxes
- Support for player-to-player trading
