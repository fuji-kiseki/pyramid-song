module Views.Switch exposing (..)

import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)


switch : List (Html msg) -> Html msg
switch content =
    div [ class "flex w-fit p-0.5 bg-white border border-gray-200 rounded-sm" ] content


type alias Control value action =
    { label : String
    , value : value
    , action : value -> action
    }


viewControl : value -> Control value action -> Html action
viewControl selected ctl =
    button
        [ onClick (ctl.action ctl.value)
        , classList
            [ ( "rounded-xs px-2 py-1 pointer cursor-pointer", True )
            , ( "bg-gray-200", selected == ctl.value )
            ]
        ]
        [ text ctl.label ]
