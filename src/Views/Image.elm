module Views.Image exposing (..)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Image exposing (ImageOption)


viewImage : msg -> ImageOption -> Bool -> Html msg
viewImage msg images selected =
    img
        [ src images.url
        , onClick msg
        , class "rounded-md w-full aspect-square object-cover"
        , classList [ ( "ring", selected ) ]
        ]
        []


imageList :
    (String -> msg)
    -> Dict String ImageOption
    -> Maybe String
    -> List ( String, Html msg )
imageList msg images selected =
    images
        |> Dict.toList
        |> List.map
            (\( id, image ) ->
                ( id, viewImage (msg id) image (selected == Just id) )
            )
