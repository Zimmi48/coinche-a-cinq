module Evergreen.V11.Types exposing (..)

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


type Trump
    = NoTrump
    | SingleTrump Suit
    | AllTrumps


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
    , trump : Trump
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
    , trump : Trump
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
    | ChangeTrump Trump
    | NextRound
    | NoOpFrontendMsg


type ToBackend
    = NoOpToBackend
    | JoinGame String
    | Reset
    | Played Card
    | UndoCardPlayed
    | Gathered
    | TrumpChanged Trump
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
    | NewTrump Trump
    | RestoredName String
    | Scores (Dict.Dict String Int)
