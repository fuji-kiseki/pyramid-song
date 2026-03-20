module View.Switch exposing (viewController, viewSwitch)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


type alias Switch value msg =
    { toMsg : value -> msg
    , selected : value
    }


type alias Controller value msg =
    { value : value
    , content : List (Html msg)
    }


viewSwitch :
    Switch value msg
    -> List (Controller value msg)
    -> Html msg
viewSwitch opt ctrls =
    div
        [ class "flex w-fit p-0.5 bg-dn-background-100 border border-dn-border-200 rounded-sm"
        ]
        (ctrls
            |> List.map (viewController opt.toMsg opt.selected)
        )


viewController :
    (value -> msg)
    -> value
    -> Controller value msg
    -> Html msg
viewController action selected ctrl =
    button
        [ onClick (action ctrl.value)
        , class "rounded-xs px-2 py-1 cursor-pointer transition-colors"
        , class
            (if ctrl.value == selected then
                "bg-dn-border-100 text-dn-foreground-200"

             else
                "text-dn-foreground-100 hover:bg-dn-background-200"
            )
        ]
        ctrl.content
