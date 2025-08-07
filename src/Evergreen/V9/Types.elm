module Evergreen.V9.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Lamdera
import Url


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


type alias Card =
    { suit : Suit
    , rank : Rank
    }


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , name : String
    , playing : Bool
    , hand : List Card
    , played : Dict.Dict String Card
    , playerLeft : Maybe String
    , playerRight : Maybe String
    , playerTopLeft : Maybe String
    , playerTopRight : Maybe String
    , trump : Maybe Suit
    , scores : Dict.Dict String Int
    }


type alias Player =
    { name : String
    , id : Lamdera.SessionId
    }


type alias Game =
    { hands : Dict.Dict Lamdera.SessionId (List Card)
    , gathered : Dict.Dict Lamdera.SessionId (List Card)
    , played : Dict.Dict Lamdera.SessionId Card
    , trump : Maybe Suit
    }


type alias BackendModel =
    { players : List Player
    , game : Maybe Game
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | UpdateName String
    | StartGame
    | PlayCard Card
    | UndoCard
    | GatherCards
    | ChangeTrump Suit
    | NextRound
    | NoOpFrontendMsg


type ToBackend
    = NoOpToBackend
    | JoinGame String
    | Reset
    | Played Card
    | UndoCardPlayed
    | Gathered
    | TrumpChanged Suit
    | RestoreName
    | RestoreSession
    | NextRoundRequested


type BackendMsg
    = NoOpBackendMsg
    | NewGame Game


type ToFrontend
    = NoOpToFrontend
    | PlayersList (List String)
    | GiveHand (List Card)
    | PlayedBy String Card
    | UndoBy String Card
    | ClearPlayed
    | NewTrump Suit
    | RestoredName String
    | Scores (Dict.Dict String Int)
