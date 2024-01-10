module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Lamdera exposing (SessionId)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , name : String
    , playing : Bool
    , hand : List Card
    , played : Dict String Card
    , playerLeft : Maybe String
    , playerRight : Maybe String
    , playerTopLeft : Maybe String
    , playerTopRight : Maybe String
    }


type alias BackendModel =
    { players : List Player
    , game : Maybe Game
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | UpdateName String
    | StartGame
    | NoOpFrontendMsg


type ToBackend
    = NoOpToBackend
    | JoinGame String
    | Reset


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
    | PlayersList (List String)


type alias Player =
    { name : String
    , id : SessionId
    }


type alias Game =
    { hands : Dict SessionId (List Card)
    , gathered : Dict SessionId (List Card)
    , played : Dict SessionId Card
    }


type alias Card =
    { suit : Suit
    , rank : Rank
    }


type Suit
    = Clubs
    | Diamonds
    | Hearts
    | Spades


type Rank
    = Ace
    | Five
    | Six
    | Seven
    | Eight
    | Nine
    | Ten
    | Jack
    | Queen
    | King
