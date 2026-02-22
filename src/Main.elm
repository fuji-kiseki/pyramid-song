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
import Svg.Attributes
import Task exposing (..)
import Views.Grid exposing (viewGrid)
import Views.Icons.ImagePlus exposing (imagePlusIcon)
import Views.Modal exposing (viewModal, viewModalHeader)
import Views.Switch as ImagePicker
import Views.Upload exposing (viewUpload)


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
                    [ viewModalHeader
                        [ div [ class "flex justify-between" ]
                            [ ImagePicker.switch
                                [ ImagePicker.Control "files" Image.Upload ChangeCategory
                                    |> ImagePicker.viewControl imageSelector.selectedCategory
                                , ImagePicker.Control "Url" Image.Url ChangeCategory
                                    |> ImagePicker.viewControl imageSelector.selectedCategory
                                ]
                            , div [ class "flex w-fit px-2 border border-gray-200 rounded-sm" ]
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
                                    , class "outline-none caret-gray-600"
                                    ]
                                    []
                                ]
                            ]
                        ]
                    , viewGrid
                        ((case imageSelector.selectedCategory of
                            Image.Upload ->
                                viewUpload GotFiles

                            _ ->
                                text ""
                         )
                            :: List.map
                                (\i ->
                                    img
                                        [ src i.url
                                        , onClick (SelectImage i.id)
                                        , class "rounded-md w-full aspect-square object-cover"
                                        , class
                                            (imageSelector.selectedImage
                                                |> Maybe.map
                                                    (\id ->
                                                        if id == i.id then
                                                            "ring"

                                                        else
                                                            ""
                                                    )
                                                |> Maybe.withDefault ""
                                            )
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
