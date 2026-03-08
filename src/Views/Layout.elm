module Views.Layout exposing (..)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (alt, class, draggable, src)
import Html.Events exposing (onClick)
import Html.Keyed as Keyed
import Image exposing (ImageState)
import Svg.Attributes
import Views.Icons exposing (viewImagePlus)


viewLayoutGrid : Dict String ImageState -> (String -> msg) -> Html msg
viewLayoutGrid entries msg =
    Keyed.ul
        [ class "grid grid-cols-3 grid-rows-3 gap-1 max-w-fit m-auto" ]
        (entries
            |> Dict.toList
            |> List.map (viewKeyedEntry msg)
        )


viewKeyedEntry : (String -> msg) -> ( String, ImageState ) -> ( String, Html msg )
viewKeyedEntry msg ( key, entry ) =
    ( key
    , div
        [ onClick (msg key)
        , class "flex items-center select-none justify-center overflow-hidden h-50 w-50 cursor-pointer aspect-square"
        ]
        [ case entry of
            Image.Empty ->
                viewImagePlus [ Svg.Attributes.class "h-6 w-6" ]

            Image.Loaded { url, name } ->
                img
                    [ src url
                    , alt name
                    , draggable "false"
                    , class "object-cover w-full h-full block"
                    ]
                    []
        ]
    )
