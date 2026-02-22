module Views.Upload exposing (viewUpload)

import File exposing (File)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on)
import Json.Decode as D
import Svg.Attributes
import Views.Icons.ImagePlus exposing (imagePlusIcon)


viewUpload : (List File -> msg) -> Html msg
viewUpload msg =
    label
        [ attribute "aria-label" "Upload image"
        , class "h-full aspect-square flex flex-col items-center justify-center rounded-md"
        , class "border border-gray-200 border-dashed cursor-pointer group hover:border-gray-400"
        ]
        [ input
            [ type_ "file"
            , multiple False
            , accept "image/*"
            , on "change" (D.map msg filesDecoder)
            , class "hidden"
            ]
            []
        , imagePlusIcon
            [ Svg.Attributes.class "h-6 w-6 text-gray-600 group-hover:text-black"
            ]
        , span [ class "text-gray-600  text-xs pt-2 group-hover:text-black" ]
            [ text "Upload" ]
        ]


filesDecoder : D.Decoder (List File)
filesDecoder =
    D.at [ "target", "files" ] (D.list File.decoder)
