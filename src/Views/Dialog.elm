module Views.Dialog exposing (ModalConfig, viewDialog, viewHeader)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (..)


type alias ModalConfig msg =
    { onClose : msg
    , onConfirm : Maybe msg
    }


viewDialog : ModalConfig msg -> List (Html msg) -> Html msg
viewDialog { onClose, onConfirm } content =
    div [ class "fixed inset-0 flex items-center justify-center" ]
        [ div
            [ class "flex flex-col justify-center w-3xl bg-white border border-gray-200 rounded-xl overflow-hidden max-w-9/10 max-h-8/10" ]
            [ div [ class "overflow-auto" ] content
            , footer [ class "flex justify-between bg-gray-50/90 border-t border-gray-200 p-4" ]
                [ button [ baseBtnStyle, closeBtnStyle, onClick onClose ] [ text "Cancel" ]
                , button
                    (baseBtnStyle
                        :: (case onConfirm of
                                Nothing ->
                                    [ confirmBtnStyle False ]

                                Just msg ->
                                    [ confirmBtnStyle True, onClick msg ]
                           )
                    )
                    [ text "confirm" ]
                ]
            ]
        ]


viewHeader : List (Html msg) -> Html msg
viewHeader content =
    header [ class "sticky top-0 p-4 bg-gray-50/90 backdrop-blur-sm border-b border-gray-200" ] content


baseBtnStyle : Attribute msg
baseBtnStyle =
    class "p-2 rounded-md transition-colors duration-200"


closeBtnStyle : Attribute msg
closeBtnStyle =
    class "p-2 bg-white cursor-pointer border rounded-md border-gray-200 hover:bg-gray-100"


confirmBtnStyle : Bool -> Attribute msg
confirmBtnStyle isActive =
    if isActive then
        class "bg-neutral-950 text-white cursor-pointer hover:bg-neutral-800"

    else
        class "bg-gray-200 text-neutral-400 cursor-not-allowed"
