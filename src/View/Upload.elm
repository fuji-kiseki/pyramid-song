module View.Upload exposing (viewUpload)

import File exposing (File)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on)
import Json.Decode as D
import Svg.Attributes
import View.Icons exposing (viewFileUp)


viewUpload : (List File -> msg) -> Html msg
viewUpload msg =
    label
        [ attribute "aria-label" "Upload image"
        , class "group flex h-full aspect-square flex-col items-center justify-center rounded-md"
        , class "cursor-pointer border border-dashed border-dn-border-100 hover:border-dn-border-100"
        , class "bg-dn-background-100 hover:bg-dn-background-300 transition-colors"
        ]
        [ input
            [ type_ "file"
            , multiple False
            , accept "image/*"
            , on "change" (D.map msg filesDecoder)
            , class "hidden"
            ]
            []
        , viewFileUp
            [ Svg.Attributes.class "h-6 w-6 text-dn-muted-200 group-hover:text-dn-foreground-300 transition-colors"
            ]
        , span
            [ class "pt-2 text-xs text-dn-muted-200 group-hover:text-dn-foreground-200 transition-colors"
            ]
            [ text "Upload" ]
        ]


filesDecoder : D.Decoder (List File)
filesDecoder =
    D.at [ "target", "files" ] (D.list File.decoder)
