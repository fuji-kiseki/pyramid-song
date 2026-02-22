module Views.Grid exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)


viewGrid : List (Html msg) -> Html msg
viewGrid content =
    div
        [ class "grid grid-cols-3 grid-flow-row gap-2 mt-4" ]
        content
