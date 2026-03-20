module View.Image exposing (..)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Image exposing (Image(..))


viewImage : msg -> Image -> Bool -> Html msg
viewImage msg state selected =
    case state of
        Loaded image ->
            img
                [ src image.url
                , onClick msg
                , class "rounded-md w-full aspect-square object-cover"
                , classList [ ( "ring", selected ) ]
                ]
                []

        Empty ->
            text ""


imageList :
    (String -> msg)
    -> Dict String Image
    -> Maybe String
    -> List ( String, Html msg )
imageList msg images selected =
    images
        |> Dict.toList
        |> List.map
            (\( id, image ) ->
                ( id, viewImage (msg id) image (selected == Just id) )
            )
