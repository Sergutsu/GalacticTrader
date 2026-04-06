module Example exposing (..)

import Expect
import Test exposing (..)


suite : Test
suite =
    describe "placeholder"
        [ test "keeps test suite active" <|
            \_ -> Expect.pass
        ]
