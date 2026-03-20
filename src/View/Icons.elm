module View.Icons exposing (..)

import Html exposing (Html)
import Svg exposing (Attribute, circle, path, svg)
import Svg.Attributes exposing (cx, cy, d, fill, r, stroke, strokeLinecap, strokeLinejoin, strokeWidth, viewBox)


viewImagePlus : List (Attribute msg) -> Html msg
viewImagePlus extraAttrs =
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
        [ path [ d "M16 5h6m-3-3v6m2 3.5V19a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h7.5" ] []
        , path [ d "m21 15-3.086-3.086a2 2 0 0 0-2.828 0L6 21" ] []
        , circle [ cx "9", cy "9", r "2" ] []
        ]


viewFileUp : List (Attribute msg) -> Html msg
viewFileUp extraAttrs =
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
        [ path
            [ d "M6 22a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h8a2.4 2.4 0 0 1 1.704.706l3.588 3.588A2.4 2.4 0 0 1 20 8v12a2 2 0 0 1-2 2z" ]
            []
        , path
            [ d "M14 2v5a1 1 0 0 0 1 1h5m-8 4v6m3-3-3-3-3 3" ]
            []
        ]


viewMoon : List (Attribute msg) -> Html msg
viewMoon extraAttrs =
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
        [ path
            [ d "M20.985 12.486a9 9 0 1 1-9.473-9.472c.405-.022.617.46.402.803a6 6 0 0 0 8.268 8.268c.344-.215.825-.004.803.401"
            ]
            []
        ]


viewSun : List (Attribute msg) -> Html msg
viewSun extraAttrs =
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
        [ circle
            [ cx "12"
            , cy "12"
            , r "4"
            ]
            []
        , path
            [ d "M12 2v2m0 16v2M4.93 4.93l1.41 1.41m11.32 11.32 1.41 1.41M2 12h2m16 0h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41"
            ]
            []
        ]
