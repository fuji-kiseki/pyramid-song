module Main exposing (..)

import Browser
import Dict exposing (Dict)
import File exposing (File)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed as Keyed
import Html.Lazy exposing (lazy2)
import Image exposing (Image, ImageSelector, ImageState, alterImageSelector, setImage)
import Json.Decode as Decode
import Svg exposing (circle, path, svg)
import Svg.Attributes exposing (cx, cy, d, fill, r, stroke, strokeLinecap, strokeLinejoin, strokeWidth, viewBox)
import Task exposing (..)
import Views.Modal exposing (viewModal)
import Views.Switch as ImagePicker


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
    , modal : { target : Maybe Int }
    , imageSelector : ImageSelector
    }


type alias ImagePreview =
    { search : String
    , images : Dict String ImageState
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { images =
            List.range 0 8
                |> List.map (\i -> ( i, Image.Empty ))
                |> Dict.fromList
      , modal = { target = Nothing }
      , imageSelector =
            { selectedCategory = Image.Upload
            , searchQuery = ""
            , selectedImage = Nothing
            , availableImages = []
            }
      }
    , Cmd.none
    )


type Msg
    = GotFiles (List File)
    | ImageLoaded Int Image
    | OpenModal Int
    | CloseModal
    | ChangeSearchQuery String
    | AddImage Image.ImageOption
    | SelectImage String
    | ChangeCategory Image.ImageCategory


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotFiles files ->
            ( model
            , List.head files
                |> Maybe.map setImage
                |> Maybe.map
                    (Task.perform <|
                        \{ name, url } ->
                            AddImage
                                { id = name
                                , filename = name
                                , category = Image.Upload
                                , url = url
                                }
                    )
                |> Maybe.withDefault Cmd.none
            )

        ImageLoaded index image ->
            ( { model | images = Dict.insert index (Image.Loaded image) model.images, modal = { target = Nothing } }
            , Cmd.none
            )

        OpenModal target ->
            ( { model | modal = { target = Just target } }, Cmd.none )

        CloseModal ->
            ( { model | modal = { target = Nothing } }, Cmd.none )

        ChangeSearchQuery value ->
            ( alterImageSelector (\s -> { s | searchQuery = value }) model, Cmd.none )

        AddImage options ->
            ( alterImageSelector (\s -> { s | availableImages = s.availableImages ++ [ options ] }) model, Cmd.none )

        SelectImage selected ->
            ( alterImageSelector (\s -> { s | selectedImage = Just selected }) model, Cmd.none )

        ChangeCategory category ->
            ( alterImageSelector (\s -> { s | selectedCategory = category }) model, Cmd.none )


view : Model -> Html Msg
view { modal, images, imageSelector } =
    div []
        [ Keyed.node "ul"
            [ class "grid grid-cols-3 grid-rows-3 gap-1 max-w-fit m-auto" ]
            (images
                |> Dict.toList
                |> List.map (\( index, imageState ) -> viewKeyedImage index imageState)
            )
        , case modal.target of
            Just index ->
                viewModal
                    { onClose = CloseModal
                    , onConfirm =
                        Maybe.andThen
                            (\selectedId ->
                                imageSelector.availableImages
                                    |> List.filter (\image -> image.id == selectedId)
                                    |> List.head
                            )
                            imageSelector.selectedImage
                            |> Maybe.map (\{ id, url } -> ImageLoaded index { name = id, url = url })
                    }
                    [ ImagePicker.switch
                        [ ImagePicker.Control "files" Image.Upload ChangeCategory
                            |> ImagePicker.viewControl imageSelector.selectedCategory
                        , ImagePicker.Control "Url" Image.Url ChangeCategory
                            |> ImagePicker.viewControl imageSelector.selectedCategory
                        ]
                    , case imageSelector.selectedCategory of
                        Image.Upload ->
                            div []
                                [ input
                                    [ type_ "file"
                                    , id "file-input"
                                    , multiple False
                                    , accept "image/*"
                                    , value ""
                                    , on "change" (Decode.map GotFiles filesDecoder)
                                    , class "hidden"
                                    ]
                                    []
                                , label
                                    [ class "block w-fit cursor-pointer"
                                    , for "file-input"
                                    ]
                                    [ imagePlusIcon [ Svg.Attributes.class "h-6 w-6" ] ]
                                ]

                        Image.Url ->
                            div []
                                [ input
                                    [ type_ "text"
                                    , name "url"
                                    , placeholder "url"
                                    , value imageSelector.searchQuery
                                    , on "keydown"
                                        (Decode.field "key" Decode.string
                                            |> Decode.andThen
                                                (\key ->
                                                    if key == "Enter" then
                                                        -- TODO: validate url
                                                        Decode.succeed
                                                            (AddImage
                                                                { id = imageSelector.searchQuery
                                                                , filename = imageSelector.searchQuery
                                                                , category = Image.Upload
                                                                , url = imageSelector.searchQuery
                                                                }
                                                            )

                                                    else
                                                        Decode.fail ""
                                                )
                                        )
                                    , onInput ChangeSearchQuery
                                    , class "border border-gray-500"
                                    ]
                                    []
                                ]
                    , div
                        [ class "flex flex-wrap justify-center gap-2" ]
                        (List.map
                            (\i ->
                                img
                                    [ width 150
                                    , height 150
                                    , src i.url
                                    , onClick (SelectImage i.id)
                                    , class "rounded-md"
                                    , imageSelector.selectedImage
                                        |> Maybe.map
                                            (\id ->
                                                if id == i.id then
                                                    class "ring-4"

                                                else
                                                    class "hover:ring-2"
                                            )
                                        |> Maybe.withDefault (class "hover:ring-2")
                                    ]
                                    []
                            )
                            imageSelector.availableImages
                        )
                    ]

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
