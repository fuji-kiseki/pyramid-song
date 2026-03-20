module Main exposing (..)

import Array exposing (Array)
import Browser
import Dict
import File exposing (File)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed as Keyed
import Image exposing (Image, ImageSelector, alterImageSelector)
import Json.Decode as Decode
import Json.Encode as Encode
import Svg.Attributes
import Task exposing (..)
import Theme exposing (StoredTheme, Theme)
import View.Dialog as Dialog
import View.Icons exposing (viewMoon, viewSun)
import View.Image as Image
import View.Layout exposing (viewLayoutGrid)
import View.Switch as Switch
import View.Upload exposing (viewUpload)


type alias Model =
    { images : Array Image
    , modal : { target : Maybe Int }
    , imageSelector : ImageSelector
    , theme : Theme.Model
    }


type Msg
    = GotFiles (List File)
    | ImageLoaded Int Image
    | OpenModal Int
    | CloseModal
    | ChangeSearchQuery String
    | UpdateEntry ( String, Image )
    | SelectImage String
    | ChangeCategory Image.Category
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
    ( { images = Array.initialize 9 (\_ -> Image.Empty)
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
                    |> Maybe.andThen (\id -> Dict.get id imageSelector.availableImages)
                    |> Maybe.andThen
                        (\image ->
                            case image of
                                Image.Loaded { url } ->
                                    Maybe.map
                                        (\id ->
                                            { category = Image.Upload, url = url }
                                                |> Image.Loaded
                                                |> ImageLoaded id
                                        )
                                        modal.target

                                Image.Empty ->
                                    Nothing
                        )
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
                                                        ( imageSelector.searchQuery
                                                        , Image.Loaded
                                                            { category = Image.Upload
                                                            , url = imageSelector.searchQuery
                                                            }
                                                        )
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
            , files
                |> List.head
                |> Maybe.map (Image.fromFile >> Task.perform UpdateEntry)
                |> Maybe.withDefault Cmd.none
            )

        ImageLoaded index image ->
            ( { model
                | images = Array.set index image model.images
                , modal = { target = Nothing }
              }
            , Cmd.none
            )

        OpenModal target ->
            ( { model | modal = { target = Just target } }, Cmd.none )

        CloseModal ->
            ( { model | modal = { target = Nothing } }, Cmd.none )

        ChangeSearchQuery value ->
            ( alterImageSelector (\s -> { s | searchQuery = value }) model, Cmd.none )

        UpdateEntry ( id, image ) ->
            ( alterImageSelector
                (\s -> { s | availableImages = Dict.insert id image model.imageSelector.availableImages })
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
