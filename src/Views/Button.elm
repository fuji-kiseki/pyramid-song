module Views.Button exposing (ButtonType(..), viewButton)

import Html exposing (..)
import Html.Attributes exposing (class, disabled)
import Html.Events exposing (onClick)


type ButtonType
    = Confirm
    | Close


viewButton : ButtonType -> Maybe msg -> List (Html msg) -> Html msg
viewButton type_ msg content =
    button
        [ class "px-3 py-2 rounded-md text-sm transition-colors"
        , class
            (case ( type_, msg ) of
                ( Confirm, Just _ ) ->
                    "bg-dn-emphasis-100 text-dn-emphasis-foreground hover:bg-dn-emphasis-hover cursor-pointer"

                ( Confirm, Nothing ) ->
                    "bg-dn-background-200 text-dn-foreground-100 cursor-not-allowed"

                ( Close, _ ) ->
                    "border border-dn-border-100 bg-dn-background-100 text-dn-foreground-200 cursor-pointer hover:bg-dn-background-200"
            )
        , msg
            |> Maybe.map onClick
            |> Maybe.withDefault (disabled True)
        ]
        content
