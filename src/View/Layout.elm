module View.Layout exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (class, draggable, src)
import Html.Events exposing (onClick)
import Html.Keyed as Keyed
import Image exposing (Image)
import Svg.Attributes
import View.Icons exposing (viewImagePlus)


viewLayoutGrid : Array Image -> (Int -> msg) -> Html msg
viewLayoutGrid entries msg =
    Keyed.ul
        [ class "grid grid-cols-3 grid-rows-3 gap-1 max-w-fit m-auto" ]
        (entries
            |> Array.indexedMap (\i image -> viewKeyedEntry msg ( i, image ))
            |> Array.toList
        )


viewKeyedEntry : (Int -> msg) -> ( Int, Image ) -> ( String, Html msg )
viewKeyedEntry msg ( key, entry ) =
    ( String.fromInt key
    , div
        [ onClick (msg key)
        , class "flex items-center select-none justify-center overflow-hidden h-50 w-50 cursor-pointer aspect-square"
        ]
        [ case entry of
            Image.Empty ->
                viewImagePlus [ Svg.Attributes.class "h-6 w-6" ]

            Image.Loaded { url } ->
                img
                    [ src url
                    , draggable "false"
                    , class "object-cover w-full h-full block"
                    ]
                    []
        ]
    )
