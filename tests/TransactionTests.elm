module TransactionTests exposing (suite)

import Expect
import Test exposing (Test, describe, test)
import Dict
import Models.Good as Good
import Models.Planet as Planet
import Models.Player as Player
import Models.Ship as Ship
import Logic.Transaction as Transaction


suite : Test
suite =
    describe "Transaction Logic"
        [ test "buyGood: Successfully buys a good" <|
            \_ ->
                let
                    -- Setup initial state
                    initialPlayer = 
                        { name = "Test Player"
                        , credits = 1000
                        }
                    
                    initialShip =
                        { name = "Test Ship"
                        , shipType = Ship.Cargo
                        , cargoCapacity = 10
                        , cargo = Dict.empty
                        , fuelCapacity = 100
                        , fuel = 100
                        }
                    
                    initialMarket =
                        Dict.fromList
                            [ ( "Food"
                              , { price = 10
                                , stock = 5
                                }
                              )
                            ]
                    
                    initialPlanet =
                        { name = "Test Planet"
                        , market = initialMarket
                        , position = ( 0, 0 )
                        , description = "A test planet"
                        }
                    
                    -- Execute the transaction
                    result =
                        Transaction.buyGood 
                            "Food" 
                            [ initialShip ] 
                            0 
                            initialPlayer 
                            initialPlanet
                in
                Expect.true "Should successfully buy food" result.success
        
        , test "sellGood: Successfully sells a good" <|
            \_ ->
                let
                    -- Setup initial state with cargo
                    initialPlayer = 
                        { name = "Test Player"
                        , credits = 1000
                        }
                    
                    initialShip =
                        { name = "Test Ship"
                        , shipType = Ship.Cargo
                        , cargoCapacity = 10
                        , cargo = Dict.fromList [ ("Food", 1) ]
                        , fuelCapacity = 100
                        , fuel = 100
                        }
                    
                    initialMarket =
                        Dict.fromList
                            [ ( "Food"
                              , { price = 10
                                , stock = 5
                                }
                              )
                            ]
                    
                    initialPlanet =
                        { name = "Test Planet"
                        , market = initialMarket
                        , position = ( 0, 0 )
                        , description = "A test planet"
                        }
                    
                    -- Execute the transaction
                    result =
                        Transaction.sellGood 
                            "Food" 
                            [ initialShip ] 
                            0 
                            initialPlayer 
                            initialPlanet
                in
                Expect.true "Should successfully sell food" result.success
        
        , test "buyGood: Fails with not enough credits" <|
            \_ ->
                let
                    initialPlayer = 
                        { name = "Test Player"
                        , credits = 1  -- Not enough for food
                        }
                    
                    initialShip =
                        { name = "Test Ship"
                        , shipType = Ship.Cargo
                        , cargoCapacity = 10
                        , cargo = Dict.empty
                        , fuelCapacity = 100
                        , fuel = 100
                        }
                    
                    initialMarket =
                        Dict.fromList
                            [ ( "Food"
                              , { price = 10
                                , stock = 5
                                }
                              )
                            ]
                    
                    initialPlanet =
                        { name = "Test Planet"
                        , market = initialMarket
                        , position = ( 0, 0 )
                        , description = "A test planet"
                        }
                    
                    result =
                        Transaction.buyGood 
                            "Food" 
                            [ initialShip ] 
                            0 
                            initialPlayer 
                            initialPlanet
                in
                Expect.equal (Just Transaction.NotEnoughCredits) result.error
        ]
