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
    , trump : Maybe Suit
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
    | PlayCard Card
    | GatherCards
    | ChangeTrump Suit
    | NoOpFrontendMsg


type ToBackend
    = NoOpToBackend
    | JoinGame String
    | Reset
    | Played Card
    | Gathered
    | TrumpChanged Suit
    | RestoreName
    | RestoreSession


type BackendMsg
    = NoOpBackendMsg
    | NewGame Game


type ToFrontend
    = NoOpToFrontend
    | PlayersList (List String)
    | GiveHand (List Card)
    | PlayedBy String Card
    | ClearPlayed
    | NewTrump Suit
    | RestoredName String


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


rankValue : Bool -> Rank -> Int
rankValue isTrump rank =
    case rank of
        Ace ->
            11

        Ten ->
            10

        Five ->
            5

        King ->
            4

        Queen ->
            3

        Jack ->
            if isTrump then
                20

            else
                2

        Nine ->
            if isTrump then
                14

            else
                0

        _ ->
            0


rankOrder : Bool -> Rank -> Int
rankOrder isTrump rank =
    case rank of
        Eight ->
            -1

        Seven ->
            -2

        Six ->
            -3

        _ ->
            rankValue isTrump rank
