module Image exposing (..)

import Dict exposing (Dict)
import File exposing (File)
import Task exposing (..)


type alias Model =
    { images : Dict Int ImageState }


type alias Image =
    { url : String, name : String }


type ImageState
    = Empty
    | Loaded Image


setImage : File -> Task Never Image
setImage file =
    File.toUrl file
        |> Task.map (\url -> { url = url, name = File.name file })



-- Image Selector


type alias ImageSelector =
    { selectedCategory : ImageCategory
    , searchQuery : String
    , selectedImage : Maybe String
    , availableImages : List ImageOption
    }


type ImageCategory
    = Upload
    | Url


type alias ImageOption =
    { id : String
    , filename : String
    , category : ImageCategory
    , url : String
    }


alterImageSelector : (ImageSelector -> ImageSelector) -> { r | imageSelector : ImageSelector } -> { r | imageSelector : ImageSelector }
alterImageSelector transform model =
    { model | imageSelector = transform model.imageSelector }
