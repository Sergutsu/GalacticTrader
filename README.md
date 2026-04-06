# Galactic Trader

A browser-based space trading prototype built in **Elm 0.19.1**.

Galactic Trader currently focuses on a playable core loop:
1. pick an owned ship,
2. inspect local market supply/price,
3. buy/sell cargo,
4. travel between planets,
5. track credits + message log.

The codebase also includes broader design docs for future systems like ownership trees, advanced economy simulation, AI behavior, and expanded UI panels.

## Current gameplay snapshot

- **Single-player trading loop** with credits, cargo, and local planet markets.
- **Asset selector** that lets you switch between multiple owned ships.
- **Ship-type-aware control panel** (Cargo ship market is functional, Military/Explorer panels are scaffolded).
- **Planet-to-planet travel flow** within a star system.
- **Transaction engine** with:
  - buy/sell validation,
  - dynamic pricing,
  - bulk operations,
  - transaction fees,
  - explicit error reporting.
- **Basic automated tests** focused on cargo-capacity rules in ship logic.

## Tech stack

- [Elm](https://elm-lang.org/) 0.19.1
- `elm-live` for local dev
- `npm-run-all` for concurrent dev tasks
- Node.js scripts for static asset handling

## Project structure

```text
src/
  Main.elm                  # App entrypoint (init/update/view)
  Types.elm                 # Shared Model / Msg definitions

  Logic/
    Game.elm                # Buy/sell/travel integration with main model
    Transaction.elm         # Core transaction + pricing + trade-offer logic
    Ship.elm                # Cargo operations and ship utility logic
    Event.elm               # Tick/time-based game updates

  Models/                   # Domain models (Player, Ship, Planet, Goods, etc.)
  View/                     # UI modules (control panel, HUD, market, ownership)

static/
  styles.css                # Runtime-copied global stylesheet

docs/
  TRANSACTIONS.md           # Transaction system walkthrough
  Logic.md                  # Planned core systems
  models.md                 # Planned domain model catalog
  views.md                  # Planned UI panel map

tests/
  Logic/ShipTest.elm        # Cargo-capacity behavior tests
  Example.elm               # Placeholder suite
```

## Getting started

### Prerequisites

- Node.js 18+ (or a recent LTS)
- npm 9+

### Install dependencies

```bash
npm install
```

### Run in development

```bash
npm run dev
```

This runs:
- `elm-live src/Main.elm --open -- --output=elm.js`
- `node scripts/copy-assets.js`

### Build for deployment

```bash
npm run deploy
```

This runs build + asset copy.

> `npm run build` emits Elm output to `public/elm.js`; make sure your hosting setup serves from a matching location.

## Tests

Run Elm tests with:

```bash
npx elm-test
```

If `elm-test` is not available in your environment, add it as a dev dependency:

```bash
npm install --save-dev elm-test
```

## Key architecture notes

- **State model** is centralized in `Types.Model` and managed in Elm Architecture style (`init`, `update`, `view`) from `Main.elm`.
- **Trading actions** (`BuyCommodity` / `SellCommodity`) are routed through `Logic.Game`, which resolves the active location and then delegates validation + updates to `Logic.Transaction`.
- **Travel flow** currently sets a temporary `travelState` and resolves timing through tick handling.
- **UI composition** is modular, with `View.ControlPanel` providing the active ship interaction surface.

## Documentation

See the docs folder for design direction and in-progress system planning:
- `docs/TRANSACTIONS.md`
- `docs/Logic.md`
- `docs/models.md`
- `docs/views.md`

## Roadmap ideas (from existing docs/code)

- Expand ship-specific markets and special commands.
- Complete advanced supply/demand economy simulation.
- Add ownership hierarchy and permissions in gameplay.
- Introduce mission/event chains and faction/reputation systems.
- Increase test coverage around transaction and travel logic.

## License

MIT.
