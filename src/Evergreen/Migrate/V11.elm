module Evergreen.Migrate.V11 exposing (..)

{-| This migration file migrates from V9 to V11, adding support for multiple trumps.

The main changes:

  - trump field changes from Maybe Suit to Trump
  - ChangeTrump/TrumpChanged/NewTrump messages change from Suit to Trump

-}

import Dict
import Evergreen.V11.Types
import Evergreen.V9.Types
import Lamdera.Migrations exposing (..)


frontendModel : Evergreen.V9.Types.FrontendModel -> ModelMigration Evergreen.V11.Types.FrontendModel Evergreen.V11.Types.FrontendMsg
frontendModel old =
    ModelMigrated
        ( { key = old.key
          , name = old.name
          , playing = old.playing
          , hand = old.hand |> List.map migrate_Types_Card
          , played = old.played |> Dict.map (\_ card -> migrate_Types_Card card)
          , playerLeft = old.playerLeft
          , playerRight = old.playerRight
          , playerTopLeft = old.playerTopLeft
          , playerTopRight = old.playerTopRight
          , trump = migrate_Trump old.trump
          , scores = old.scores
          }
        , Cmd.none
        )


backendModel : Evergreen.V9.Types.BackendModel -> ModelMigration Evergreen.V11.Types.BackendModel Evergreen.V11.Types.BackendMsg
backendModel old =
    ModelMigrated
        ( { players = old.players |> List.map migrate_Types_Player
          , game = old.game |> Maybe.map migrate_Types_Game
          }
        , Cmd.none
        )


frontendMsg : Evergreen.V9.Types.FrontendMsg -> MsgMigration Evergreen.V11.Types.FrontendMsg Evergreen.V11.Types.FrontendMsg
frontendMsg old =
    MsgMigrated ( migrate_Types_FrontendMsg old, Cmd.none )


toBackend : Evergreen.V9.Types.ToBackend -> MsgMigration Evergreen.V11.Types.ToBackend Evergreen.V11.Types.BackendMsg
toBackend old =
    MsgMigrated ( migrate_Types_ToBackend old, Cmd.none )


backendMsg : Evergreen.V9.Types.BackendMsg -> MsgMigration Evergreen.V11.Types.BackendMsg Evergreen.V11.Types.BackendMsg
backendMsg old =
    MsgMigrated ( migrate_Types_BackendMsg old, Cmd.none )


toFrontend : Evergreen.V9.Types.ToFrontend -> MsgMigration Evergreen.V11.Types.ToFrontend Evergreen.V11.Types.FrontendMsg
toFrontend old =
    MsgMigrated ( migrate_Types_ToFrontend old, Cmd.none )


migrate_Trump : Maybe Evergreen.V9.Types.Suit -> Evergreen.V11.Types.Trump
migrate_Trump maybeSuit =
    case maybeSuit of
        Nothing ->
            Evergreen.V11.Types.NoTrump

        Just suit ->
            Evergreen.V11.Types.SingleTrump (migrate_Types_Suit suit)


migrate_Types_Card : Evergreen.V9.Types.Card -> Evergreen.V11.Types.Card
migrate_Types_Card old =
    { suit = old.suit |> migrate_Types_Suit
    , rank = old.rank |> migrate_Types_Rank
    }


migrate_Types_Player : Evergreen.V9.Types.Player -> Evergreen.V11.Types.Player
migrate_Types_Player old =
    { name = old.name
    , id = old.id
    }


migrate_Types_Game : Evergreen.V9.Types.Game -> Evergreen.V11.Types.Game
migrate_Types_Game old =
    { hands = old.hands |> Dict.map (\_ cards -> cards |> List.map migrate_Types_Card)
    , gathered = old.gathered |> Dict.map (\_ cards -> cards |> List.map migrate_Types_Card)
    , played = old.played |> Dict.map (\_ card -> migrate_Types_Card card)
    , trump = migrate_Trump old.trump
    }


migrate_Types_FrontendMsg : Evergreen.V9.Types.FrontendMsg -> Evergreen.V11.Types.FrontendMsg
migrate_Types_FrontendMsg old =
    case old of
        Evergreen.V9.Types.UrlClicked p0 ->
            Evergreen.V11.Types.UrlClicked p0

        Evergreen.V9.Types.UrlChanged p0 ->
            Evergreen.V11.Types.UrlChanged p0

        Evergreen.V9.Types.UpdateName p0 ->
            Evergreen.V11.Types.UpdateName p0

        Evergreen.V9.Types.StartGame ->
            Evergreen.V11.Types.StartGame

        Evergreen.V9.Types.PlayCard p0 ->
            Evergreen.V11.Types.PlayCard (p0 |> migrate_Types_Card)

        Evergreen.V9.Types.UndoCard ->
            Evergreen.V11.Types.UndoCard

        Evergreen.V9.Types.GatherCards ->
            Evergreen.V11.Types.GatherCards

        Evergreen.V9.Types.ChangeTrump p0 ->
            Evergreen.V11.Types.ChangeTrump (Evergreen.V11.Types.SingleTrump (p0 |> migrate_Types_Suit))

        Evergreen.V9.Types.NextRound ->
            Evergreen.V11.Types.NextRound

        Evergreen.V9.Types.NoOpFrontendMsg ->
            Evergreen.V11.Types.NoOpFrontendMsg


migrate_Types_BackendMsg : Evergreen.V9.Types.BackendMsg -> Evergreen.V11.Types.BackendMsg
migrate_Types_BackendMsg old =
    case old of
        Evergreen.V9.Types.NoOpBackendMsg ->
            Evergreen.V11.Types.NoOpBackendMsg

        Evergreen.V9.Types.NewGame p0 ->
            Evergreen.V11.Types.NewGame (p0 |> migrate_Types_Game)


migrate_Types_Rank : Evergreen.V9.Types.Rank -> Evergreen.V11.Types.Rank
migrate_Types_Rank old =
    case old of
        Evergreen.V9.Types.Ace ->
            Evergreen.V11.Types.Ace

        Evergreen.V9.Types.Five ->
            Evergreen.V11.Types.Five

        Evergreen.V9.Types.Six ->
            Evergreen.V11.Types.Six

        Evergreen.V9.Types.Seven ->
            Evergreen.V11.Types.Seven

        Evergreen.V9.Types.Eight ->
            Evergreen.V11.Types.Eight

        Evergreen.V9.Types.Nine ->
            Evergreen.V11.Types.Nine

        Evergreen.V9.Types.Ten ->
            Evergreen.V11.Types.Ten

        Evergreen.V9.Types.Jack ->
            Evergreen.V11.Types.Jack

        Evergreen.V9.Types.Queen ->
            Evergreen.V11.Types.Queen

        Evergreen.V9.Types.King ->
            Evergreen.V11.Types.King


migrate_Types_Suit : Evergreen.V9.Types.Suit -> Evergreen.V11.Types.Suit
migrate_Types_Suit old =
    case old of
        Evergreen.V9.Types.Clubs ->
            Evergreen.V11.Types.Clubs

        Evergreen.V9.Types.Diamonds ->
            Evergreen.V11.Types.Diamonds

        Evergreen.V9.Types.Hearts ->
            Evergreen.V11.Types.Hearts

        Evergreen.V9.Types.Spades ->
            Evergreen.V11.Types.Spades


migrate_Types_ToBackend : Evergreen.V9.Types.ToBackend -> Evergreen.V11.Types.ToBackend
migrate_Types_ToBackend old =
    case old of
        Evergreen.V9.Types.NoOpToBackend ->
            Evergreen.V11.Types.NoOpToBackend

        Evergreen.V9.Types.JoinGame p0 ->
            Evergreen.V11.Types.JoinGame p0

        Evergreen.V9.Types.Reset ->
            Evergreen.V11.Types.Reset

        Evergreen.V9.Types.Played p0 ->
            Evergreen.V11.Types.Played (p0 |> migrate_Types_Card)

        Evergreen.V9.Types.UndoCardPlayed ->
            Evergreen.V11.Types.UndoCardPlayed

        Evergreen.V9.Types.Gathered ->
            Evergreen.V11.Types.Gathered

        Evergreen.V9.Types.TrumpChanged p0 ->
            Evergreen.V11.Types.TrumpChanged (Evergreen.V11.Types.SingleTrump (p0 |> migrate_Types_Suit))

        Evergreen.V9.Types.RestoreName ->
            Evergreen.V11.Types.RestoreName

        Evergreen.V9.Types.RestoreSession ->
            Evergreen.V11.Types.RestoreSession

        Evergreen.V9.Types.NextRoundRequested ->
            Evergreen.V11.Types.NextRoundRequested


migrate_Types_ToFrontend : Evergreen.V9.Types.ToFrontend -> Evergreen.V11.Types.ToFrontend
migrate_Types_ToFrontend old =
    case old of
        Evergreen.V9.Types.NoOpToFrontend ->
            Evergreen.V11.Types.NoOpToFrontend

        Evergreen.V9.Types.PlayersList p0 ->
            Evergreen.V11.Types.PlayersList p0

        Evergreen.V9.Types.GiveHand p0 ->
            Evergreen.V11.Types.GiveHand (p0 |> List.map migrate_Types_Card)

        Evergreen.V9.Types.PlayedBy p0 p1 ->
            Evergreen.V11.Types.PlayedBy p0 (p1 |> migrate_Types_Card)

        Evergreen.V9.Types.UndoBy p0 p1 ->
            Evergreen.V11.Types.UndoBy p0 (p1 |> migrate_Types_Card)

        Evergreen.V9.Types.ClearPlayed ->
            Evergreen.V11.Types.ClearPlayed

        Evergreen.V9.Types.NewTrump p0 ->
            Evergreen.V11.Types.NewTrump (Evergreen.V11.Types.SingleTrump (p0 |> migrate_Types_Suit))

        Evergreen.V9.Types.RestoredName p0 ->
            Evergreen.V11.Types.RestoredName p0

        Evergreen.V9.Types.Scores p0 ->
            Evergreen.V11.Types.Scores p0
