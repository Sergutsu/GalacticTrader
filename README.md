# Galactic Trader

## Architectural Overview

This project has been refactored to follow idiomatic Elm architectural patterns, emphasizing simplicity, modularity, and ease of future expansion. The core principles are:

*   **Centralized State**: The entire application state is managed in a single `Model` located in `Main.elm`, providing a single source of truth.
*   **Stateless Views**: All view logic is consolidated into helper functions within `Main.elm`. These functions are pure and stateless, simply transforming data from the `Model` into `Html`.
*   **Modular Logic**: Business logic is separated into distinct modules within the `src/Logic` directory (e.g., `Logic.Transaction`, `Logic.Travel`, `Logic.Event`). These modules contain pure functions that operate on the `Model` and return an updated `Model` and `Cmd`s.
*   **Clear Data Flow**: The `update` function in `Main.elm` acts as a dispatcher, delegating tasks to the appropriate logic modules. This maintains a clear, unidirectional data flow as prescribed by The Elm Architecture.

This setup ensures that the codebase is easy to reason about, maintain, and refactor.

## Axes of Expansion

The current architecture is designed to be highly extensible. Here are some potential axes of expansion and how the architecture supports them:

### 1. Ship Customization and Upgrades
*   **How**: Extend the `Models.Ship` type to include fields for different modules (e.g., `engine`, `cargoHold`, `shields`). Create a new `Logic.Shipyard` module to handle the business logic of buying, selling, and equipping modules.
*   **Architectural Support**: The modular logic allows for the easy addition of a `Shipyard` module without impacting existing transaction or travel logic. The `viewOwnership` helper in `Main.elm` can be easily extended to display ship modules.

### 2. More Complex Economic Model
*   **How**: Introduce price fluctuations based on supply and demand. This could be managed in a new `Logic.Economy` module that is called during the `Tick` event to update prices across all `planets`.
*   **Architectural Support**: The `Logic.Event` module can be extended to trigger economic updates. The atomized `Logic.Transaction` module will continue to work without changes, as it only cares about the current price, not how it's determined.

### 3. Random Events
*   **How**: Create a `Logic.RandomEvents` module that can generate events (e.g., pirate attacks, finding derelict ships, market booms/crashes) during travel. The `handleTick` function in `Logic.Event` could trigger a check for a random event.
*   **Architectural Support**: The event-driven nature of the `Tick` message is perfect for this. New `Msg` types can be added to handle the outcomes of these events, and the `update` function in `Main` will delegate to the new logic module.

### 4. Multiple Solar Systems
*   **How**: The `Model` could be extended to hold a `Dict String SolarSystem`, where each system contains a list of planets. The `Travel` logic would need to be updated to handle interstellar travel (e.g., via jump gates).
*   **Architectural Support**: The current `Travel` logic is well-encapsulated. It can be expanded to include a concept of "local" vs. "interstellar" travel without requiring a major rewrite of the entire application.

This structure provides a solid foundation for building a rich and complex game while keeping the codebase clean and maintainable.

Welcome to Galactic Trader, a space trading game prototype built with Elm!

## Gameplay

In Galactic Trader, you are the captain of the starship "Starhawk." Your goal is to travel between planets, buy and sell commodities, and amass a fortune. Keep an eye on your fuel and hull integrity, and be prepared for the dangers of space travel!

### Live Version

[Play Galactic Trader Live!](https://sergutsu.github.io/SpaceTrader/)

