port module Theme exposing
    ( Model
    , StoredTheme(..)
    , Theme(..)
    , apply
    , fromFlags
    , resolve
    , storeValue
    , subscriptions
    , toString
    , toggle
    )

import Json.Decode as Decode


type Theme
    = Light
    | Dark


type StoredTheme
    = Auto
    | Explicit Theme


type alias Model =
    Flags


type alias Flags =
    { systemTheme : Theme
    , storedTheme : Maybe StoredTheme
    }



-- Ports


port applyTheme : { resolved : String, store : String } -> Cmd msg


port systemThemeChanged : (String -> msg) -> Sub msg


port storedThemeChanged : (Maybe String -> msg) -> Sub msg



-- Flags


fromFlags : Decode.Value -> Flags
fromFlags value =
    value
        |> Decode.decodeValue flagsDecoder
        |> Result.withDefault { systemTheme = Light, storedTheme = Nothing }


flagsDecoder : Decode.Decoder Flags
flagsDecoder =
    Decode.map2 Flags
        (Decode.field "systemTheme" Decode.string
            |> Decode.map fromString
            |> Decode.map (Maybe.withDefault Light)
        )
        (Decode.field "storedTheme" Decode.string
            |> Decode.maybe
            |> Decode.map (Maybe.andThen fromStoredString)
        )



-- Subscriptions


subscriptions :
    { onSystemThemeChanged : Theme -> msg
    , onStoredThemeChanged : Maybe StoredTheme -> msg
    }
    -> Sub msg
subscriptions { onSystemThemeChanged, onStoredThemeChanged } =
    Sub.batch
        [ systemThemeChanged
            (\s -> onSystemThemeChanged (fromString s |> Maybe.withDefault Light))
        , storedThemeChanged
            (\ms -> onStoredThemeChanged (ms |> Maybe.andThen fromStoredString))
        ]



-- Utils


{-| Resolve a StoredTheme to a concrete Theme given the current system theme.
-}
resolve : Theme -> StoredTheme -> Theme
resolve systemTheme stored =
    case stored of
        Explicit t ->
            t

        Auto ->
            systemTheme


{-| The raw string to write into localStorage.
-}
storeValue : Theme -> StoredTheme -> String
storeValue systemTheme stored =
    case stored of
        Auto ->
            "auto"

        Explicit t ->
            if t == systemTheme then
                "auto"

            else
                toString t


{-| Build an `applyTheme` port command
-}
apply : Theme -> StoredTheme -> Cmd msg
apply systemTheme stored =
    applyTheme
        { resolved = toString (resolve systemTheme stored)
        , store = storeValue systemTheme stored
        }



-- Conversions


toString : Theme -> String
toString theme =
    case theme of
        Light ->
            "light"

        Dark ->
            "dark"


fromString : String -> Maybe Theme
fromString s =
    case s of
        "light" ->
            Just Light

        "dark" ->
            Just Dark

        _ ->
            Nothing


fromStoredString : String -> Maybe StoredTheme
fromStoredString s =
    case s of
        "auto" ->
            Just Auto

        "light" ->
            Just (Explicit Light)

        "dark" ->
            Just (Explicit Dark)

        _ ->
            Nothing


toggle : Model -> StoredTheme
toggle theme =
    case theme.storedTheme of
        Just (Explicit t) ->
            Explicit
                (if t == Light then
                    Dark

                 else
                    Light
                )

        Just Auto ->
            case theme.systemTheme of
                Light ->
                    Explicit Dark

                Dark ->
                    Explicit Light

        Nothing ->
            case theme.systemTheme of
                Light ->
                    Explicit Dark

                Dark ->
                    Explicit Light
