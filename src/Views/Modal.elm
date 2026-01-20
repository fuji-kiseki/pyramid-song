module Views.Modal exposing (ModalConfig, viewModal)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (..)
import Svg exposing (path, svg)
import Svg.Attributes exposing (d, fill, stroke, strokeLinecap, strokeLinejoin, strokeWidth, viewBox)


type alias ModalConfig msg =
    { onClose : msg
    , onConfirm : msg
    }


viewModal : ModalConfig msg -> List (Html msg) -> Html msg
viewModal { onClose, onConfirm } content =
    div [ class "fixed inset-0 flex items-center justify-center" ]
        [ div
            [ class "flex flex-col justify-center gap-4  bg-white border border-gray-700 rounded p-4" ]
            [ header [ class "flex justify-end items-center" ]
                [ button
                    [ onClick onClose, class "inline-block cursor-pointer text-gray-600 hover:text-gray-950" ]
                    [ viewCloseSvg [ Svg.Attributes.class "ml-auto h-6 w-6" ] ]
                ]
            , div [] content
            , footer [ class "flex justify-end" ]
                [ button
                    [ onClick onConfirm, class "p-2 border cursor-pointer" ]
                    [ text "confirm" ]
                ]
            ]
        ]


viewCloseSvg : List (Svg.Attribute msg) -> Html msg
viewCloseSvg extraAttrs =
    svg
        ([ viewBox "0 0 24 24"
         , fill "none"
         , stroke "currentColor"
         , strokeWidth "2"
         , strokeLinecap "round"
         , strokeLinejoin "round"
         ]
            ++ extraAttrs
        )
        [ path [ d "M18 6 6 18M6 6l12 12" ] []
        ]
