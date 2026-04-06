module Logic.ShipTest exposing (suite)

import Dict
import Expect
import Logic.Ship as ShipLogic
import Models.Ship exposing (Ship, ShipType(..))
import Test exposing (..)
import Types.Ownership exposing (Owner(..))


baseShip : String -> Int -> List ( String, Int ) -> Ship
baseShip id capacity cargoItems =
    { id = id
    , name = "Test Ship"
    , shipType = Cargo
    , cargoCapacity = capacity
    , cargo = Dict.fromList cargoItems
    , fuel = 100
    , fuelCapacity = 100
    , owner = Just (PlayerOwner "p1")
    , isDocked = True
    , location = Nothing
    }


suite : Test
suite =
    describe "Logic.Ship cargo rules"
        [ test "addCargo rejects additions that exceed remaining capacity" <|
            \_ ->
                let
                    ship =
                        baseShip "s1" 10 [ ( "Ore", 9 ) ]
                in
                ShipLogic.addCargo "Ore" 2 ship
                    |> Expect.equal Nothing
        , test "transferCargoBetweenShips enforces destination capacity even when cargo already exists" <|
            \_ ->
                let
                    fromShip =
                        baseShip "from" 20 [ ( "Ore", 8 ) ]

                    toShip =
                        baseShip "to" 10 [ ( "Ore", 9 ) ]
                in
                ShipLogic.transferCargoBetweenShips "Ore" 2 fromShip toShip
                    |> Expect.equal Nothing
        ]
