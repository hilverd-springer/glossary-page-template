module Extras.ArrayTests exposing (..)

import Array
import Expect exposing (Expectation)
import Extras.Array
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)


suite : Test
suite =
    describe "The Extras.Array module"
        [ describe "Array.delete"
            [ test "removes an element from an array" <|
                \_ ->
                    let
                        array =
                            Array.fromList [ "a", "b", "c", "d" ]
                    in
                    array
                        |> Extras.Array.delete 1
                        |> Expect.equal (Array.fromList [ "a", "c", "d" ])
            , test "does nothing if index is out of bounds" <|
                \_ ->
                    let
                        array =
                            Array.fromList [ "a", "b" ]
                    in
                    array
                        |> Extras.Array.delete 2
                        |> Expect.equal array
            ]
        , describe "Array.update"
            [ test "updates an element in an array" <|
                \_ ->
                    let
                        array =
                            Array.fromList [ 0, 1, 2, 3 ]
                    in
                    array
                        |> Extras.Array.update ((*) 4) 1
                        |> Expect.equal (Array.fromList [ 0, 4, 2, 3 ])
            , test "does nothing if index is out of bounds" <|
                \_ ->
                    let
                        array =
                            Array.fromList [ "a", "b" ]
                    in
                    array
                        |> Extras.Array.update (always "z") 2
                        |> Expect.equal array
            ]
        ]