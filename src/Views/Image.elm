module Views.Image exposing (..)

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
    -> List ImageOption
    -> Maybe String
    -> List ( String, Html msg )
imageList msg images selected =
    List.map
        (\image ->
            ( image.id
            , viewImage (msg image.id) image (selected == Just image.id)
            )
        )
        images
