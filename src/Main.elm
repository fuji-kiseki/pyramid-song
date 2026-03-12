module Main exposing (..)

import Browser
import Dict exposing (Dict)
import File exposing (File)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed as Keyed
import Image exposing (Image, ImageSelector, ImageState, alterImageSelector, setImage)
import Json.Decode as Decode
import Json.Encode as Encode
import Svg.Attributes
import Task exposing (..)
import Theme exposing (StoredTheme, Theme)
import Views.Dialog as Dialog
import Views.Icons exposing (viewMoon, viewSun)
import Views.Image as Image
import Views.Layout exposing (viewLayoutGrid)
import Views.Switch as Switch
import Views.Upload exposing (viewUpload)


type alias Model =
    { images : Dict String ImageState
    , modal : { target : Maybe String }
    , imageSelector : ImageSelector
    , theme : Theme.Model
    }


type Msg
    = GotFiles (List File)
    | ImageLoaded String Image
    | OpenModal String
    | CloseModal
    | ChangeSearchQuery String
    | UpdateEntry Image.ImageOption
    | SelectImage String
    | ChangeCategory Image.ImageCategory
    | ToggleColorScheme
    | SystemThemeChanged Theme
    | StoredThemeChanged (Maybe StoredTheme)


main : Program Encode.Value Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : Encode.Value -> ( Model, Cmd Msg )
init flags =
    let
        theme =
            Theme.fromFlags flags
    in
    ( { images =
            List.range 0 8
                |> List.map (\i -> ( String.fromInt i, Image.Empty ))
                |> Dict.fromList
      , modal = { target = Nothing }
      , imageSelector =
            { selectedCategory = Image.Upload
            , searchQuery = ""
            , selectedImage = Nothing
            , availableImages = Dict.empty
            }
      , theme = theme
      }
    , Theme.apply theme.systemTheme <| Maybe.withDefault Theme.Auto theme.storedTheme
    )


view : Model -> Html Msg
view { modal, images, imageSelector, theme } =
    div []
        [ button [ onClick ToggleColorScheme ]
            [ if Theme.Light == Theme.resolve theme.systemTheme theme.storedTheme then
                viewSun [ Svg.Attributes.class "h-6 w-6" ]

              else
                viewMoon [ Svg.Attributes.class "h-6 w-6" ]
            ]
        , viewLayoutGrid images OpenModal
        , Dialog.viewDialog
            { onClose = CloseModal
            , onConfirm =
                imageSelector.selectedImage
                    |> Maybe.andThen
                        (\selectedId ->
                            Dict.get selectedId imageSelector.availableImages
                        )
                    |> Maybe.map2 (\i { id, url } -> ImageLoaded i { name = id, url = url }) modal.target
            }
            (modal.target
                |> Maybe.map (\_ -> True)
                |> Maybe.withDefault False
            )
            [ Dialog.viewHeader
                [ div [ class "flex justify-between" ]
                    [ Switch.viewSwitch
                        { toMsg = ChangeCategory
                        , selected = imageSelector.selectedCategory
                        }
                        [ { value = Image.Upload
                          , content = [ text "Files" ]
                          }
                        , { value = Image.Url
                          , content = [ text "Url" ]
                          }
                        ]
                    , div
                        [ class "flex w-fit px-2 rounded-lg border bg-dn-background-100 border-dn-border-100" ]
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
                                                    (UpdateEntry
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
                            , class "w-full px-2 py-1 bg-transparent outline-none"
                            , class "text-dn-foreground-300"
                            , class "placeholder:text-dn-foreground-100"
                            , class "caret-dn-foreground-100"
                            ]
                            []
                        ]
                    ]
                ]
            , Keyed.ul [ class "grid grid-cols-3 grid-flow-row gap-2 m-4" ]
                ((case imageSelector.selectedCategory of
                    Image.Upload ->
                        ( "upload", viewUpload GotFiles )

                    _ ->
                        ( "nothing", text "" )
                 )
                    :: Image.imageList SelectImage
                        imageSelector.availableImages
                        imageSelector.selectedImage
                )
            ]
        ]


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
                            UpdateEntry
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

        UpdateEntry options ->
            ( alterImageSelector
                (\s ->
                    { s
                        | availableImages = Dict.insert options.id options s.availableImages
                    }
                )
                model
            , Cmd.none
            )

        SelectImage selected ->
            ( alterImageSelector (\s -> { s | selectedImage = Just selected }) model, Cmd.none )

        ChangeCategory category ->
            ( alterImageSelector (\s -> { s | selectedCategory = category }) model, Cmd.none )

        ToggleColorScheme ->
            let
                storedTheme =
                    Theme.toggle model.theme
            in
            ( { model
                | theme =
                    { systemTheme = model.theme.systemTheme
                    , storedTheme = Just storedTheme
                    }
              }
            , Theme.apply model.theme.systemTheme storedTheme
            )

        SystemThemeChanged systemTheme ->
            ( { model
                | theme =
                    { storedTheme = model.theme.storedTheme
                    , systemTheme = systemTheme
                    }
              }
            , Cmd.none
            )

        StoredThemeChanged storedTheme ->
            ( { model
                | theme =
                    { storedTheme = storedTheme
                    , systemTheme = model.theme.systemTheme
                    }
              }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Theme.subscriptions
        { onSystemThemeChanged = SystemThemeChanged
        , onStoredThemeChanged = StoredThemeChanged
        }
