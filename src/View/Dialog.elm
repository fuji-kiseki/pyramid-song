module View.Dialog exposing (ModalConfig, viewDialog, viewHeader)

import Html exposing (..)
import Html.Attributes exposing (class)
import View.Button as Button exposing (ButtonType(..), viewButton)


type alias ModalConfig msg =
    { onClose : msg
    , onConfirm : Maybe msg
    }


viewDialog : ModalConfig msg -> Bool -> List (Html msg) -> Html msg
viewDialog { onClose, onConfirm } open content =
    if open then
        div
            [ class "fixed inset-0 flex items-center justify-center bg-dn-foreground-200/20 backdrop-blur-sm" ]
            [ div
                [ class "flex flex-col justify-center w-3xl max-w-9/10 max-h-8/10 overflow-hidden rounded-xl border border-dn-border-100 bg-dn-background-100" ]
                [ div [ class "overflow-auto" ] content
                , footer
                    [ class "flex justify-between p-4 border-t border-dn-border-100 bg-dn-background-200/90 backdrop-blur-sm" ]
                    [ viewButton Button.Close
                        (Just onClose)
                        [ text "Cancel" ]
                    , viewButton Button.Confirm
                        onConfirm
                        [ text "Confirm" ]
                    ]
                ]
            ]

    else
        text ""


viewHeader : List (Html msg) -> Html msg
viewHeader content =
    header
        [ class "sticky top-0 p-4 border-b border-dn-border-100 bg-dn-background-200/90 backdrop-blur-sm" ]
        content
