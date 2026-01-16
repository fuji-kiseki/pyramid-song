module Main exposing (..)

import Browser
import Dict exposing (Dict)
import File exposing (File)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed as Keyed
import Html.Lazy exposing (lazy2)
import Image exposing (Image, ImageState, setImage)
import Json.Decode as Decode
import Svg exposing (circle, path, svg)
import Svg.Attributes exposing (cx, cy, d, fill, r, stroke, strokeLinecap, strokeLinejoin, strokeWidth, viewBox)
import Task exposing (..)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    { images : Dict Int ImageState
    , modal : { target : Maybe Int, input : String }
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { images =
            List.range 0 8
                |> List.map (\i -> ( i, Image.Empty ))
                |> Dict.fromList
      , modal = { target = Nothing, input = "" }
      }
    , Cmd.none
    )


type Msg
    = GotFiles Int (List File)
    | ImageLoaded Int Image
    | OpenModal Int
    | CloseModal
    | ChangeModalInput String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotFiles index files ->
            ( model
            , List.head files
                |> Maybe.map setImage
                |> Maybe.map (Task.perform <| ImageLoaded index)
                |> Maybe.withDefault Cmd.none
            )

        ImageLoaded index image ->
            ( { model | images = Dict.insert index (Image.Loaded image) model.images }
            , Cmd.none
            )

        OpenModal target ->
            ( { model | modal = { target = Just target, input = model.modal.input } }, Cmd.none )

        CloseModal ->
            ( { model | modal = { target = Nothing, input = model.modal.input } }, Cmd.none )

        ChangeModalInput value ->
            ( { model | modal = { target = model.modal.target, input = value } }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ Keyed.node "ul"
            [ class "grid grid-cols-3 grid-rows-3 gap-1 max-w-fit m-auto" ]
            (model.images
                |> Dict.toList
                |> List.map (\( index, imageState ) -> viewKeyedImage index imageState)
            )
        , case model.modal.target of
            Just target ->
                viewModal target model.modal.input

            Nothing ->
                text ""
        ]


viewKeyedImage : Int -> ImageState -> ( String, Html Msg )
viewKeyedImage index image =
    ( String.fromInt index, lazy2 viewImage index image )


viewImage : Int -> ImageState -> Html Msg
viewImage index image =
    div [ onClick (OpenModal index) ]
        [ div
            [ class "flex items-center select-none justify-center overflow-hidden h-50 w-50 cursor-pointer aspect-square"
            ]
            [ case image of
                Image.Empty ->
                    imagePlusIcon [ Svg.Attributes.class "h-6 w-6" ]

                Image.Loaded { url, name } ->
                    img [ src url, alt name, draggable "false", class "object-cover w-full h-full block" ] []
            ]
        ]


viewModal : Int -> String -> Html Msg
viewModal index modalValue =
    let
        inputId =
            "file-input"
    in
    div [ class "fixed inset-0 flex items-center justify-center" ]
        [ div
            [ class "flex justify-center items-center gap-4  bg-white border border-gray-700 rounded p-4" ]
            [ input
                [ type_ "file"
                , id inputId
                , multiple False
                , accept "image/*"
                , value ""
                , on "change" (Decode.map (GotFiles index) filesDecoder)
                , class "hidden"
                ]
                []
            , label
                [ class "cursor-pointer"
                , for inputId
                ]
                [ imagePlusIcon [ Svg.Attributes.class "h-6 w-6" ] ]
            , input
                [ type_ "text"
                , name "url"
                , placeholder "url"
                , on "keydown"
                    (Decode.field "key" Decode.string
                        |> Decode.andThen
                            (\key ->
                                if key == "Enter" then
                                    -- TODO: validate url
                                    Decode.succeed (ImageLoaded index { url = modalValue, name = modalValue })

                                else
                                    Decode.fail ""
                            )
                    )
                , onInput ChangeModalInput
                , class "border border-gray-500"
                ]
                []
            , button
                [ onClick CloseModal, class "p-2 border rounded bg-gray-700 text-white m-2" ]
                [ text "close" ]
            ]
        ]


filesDecoder : Decode.Decoder (List File)
filesDecoder =
    Decode.at [ "target", "files" ] (Decode.list File.decoder)


imagePlusIcon : List (Svg.Attribute msg) -> Html msg
imagePlusIcon extraAttrs =
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
