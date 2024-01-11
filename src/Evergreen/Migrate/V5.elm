module Evergreen.Migrate.V5 exposing (..)

{-| This migration file was automatically generated by the lamdera compiler.

It includes:

  - A migration for each of the 6 Lamdera core types that has changed
  - A function named `migrate_ModuleName_TypeName` for each changed/custom type

Expect to see:

  - `Unimplementеd` values as placeholders wherever I was unable to figure out a clear migration path for you
  - `@NOTICE` comments for things you should know about, i.e. new custom type constructors that won't get any
    value mappings from the old type by default

You can edit this file however you wish! It won't be generated again.

See <https://dashboard.lamdera.app/docs/evergreen> for more info.

-}

import Dict
import Evergreen.V4.Types
import Evergreen.V5.Types
import Lamdera.Migrations exposing (..)
import List
import Maybe


frontendModel : Evergreen.V4.Types.FrontendModel -> ModelMigration Evergreen.V5.Types.FrontendModel Evergreen.V5.Types.FrontendMsg
frontendModel old =
    ModelMigrated ( migrate_Types_FrontendModel old, Cmd.none )


backendModel : Evergreen.V4.Types.BackendModel -> ModelMigration Evergreen.V5.Types.BackendModel Evergreen.V5.Types.BackendMsg
backendModel old =
    ModelMigrated ( migrate_Types_BackendModel old, Cmd.none )


frontendMsg : Evergreen.V4.Types.FrontendMsg -> MsgMigration Evergreen.V5.Types.FrontendMsg Evergreen.V5.Types.FrontendMsg
frontendMsg old =
    MsgUnchanged


toBackend : Evergreen.V4.Types.ToBackend -> MsgMigration Evergreen.V5.Types.ToBackend Evergreen.V5.Types.BackendMsg
toBackend old =
    MsgUnchanged


backendMsg : Evergreen.V4.Types.BackendMsg -> MsgMigration Evergreen.V5.Types.BackendMsg Evergreen.V5.Types.BackendMsg
backendMsg old =
    MsgMigrated ( migrate_Types_BackendMsg old, Cmd.none )


toFrontend : Evergreen.V4.Types.ToFrontend -> MsgMigration Evergreen.V5.Types.ToFrontend Evergreen.V5.Types.FrontendMsg
toFrontend old =
    MsgMigrated ( migrate_Types_ToFrontend old, Cmd.none )


migrate_Types_BackendModel : Evergreen.V4.Types.BackendModel -> Evergreen.V5.Types.BackendModel
migrate_Types_BackendModel old =
    { players = old.players
    , game = old.game |> Maybe.map migrate_Types_Game
    }


migrate_Types_FrontendModel : Evergreen.V4.Types.FrontendModel -> Evergreen.V5.Types.FrontendModel
migrate_Types_FrontendModel old =
    { key = old.key
    , name = old.name
    , playing = old.playing
    , hand = old.hand |> List.map migrate_Types_Card
    , played = old.played |> Dict.map (\k -> migrate_Types_Card)
    , playerLeft = old.playerLeft
    , playerRight = old.playerRight
    , playerTopLeft = old.playerTopLeft
    , playerTopRight = old.playerTopRight
    , trump = old.trump |> Maybe.map migrate_Types_Suit
    , scores = Dict.empty
    }


migrate_Types_BackendMsg : Evergreen.V4.Types.BackendMsg -> Evergreen.V5.Types.BackendMsg
migrate_Types_BackendMsg old =
    case old of
        Evergreen.V4.Types.NoOpBackendMsg ->
            Evergreen.V5.Types.NoOpBackendMsg

        Evergreen.V4.Types.NewGame p0 ->
            Evergreen.V5.Types.NewGame (p0 |> migrate_Types_Game)


migrate_Types_Card : Evergreen.V4.Types.Card -> Evergreen.V5.Types.Card
migrate_Types_Card old =
    { suit = old.suit |> migrate_Types_Suit
    , rank = old.rank |> migrate_Types_Rank
    }


migrate_Types_Game : Evergreen.V4.Types.Game -> Evergreen.V5.Types.Game
migrate_Types_Game old =
    { hands = old.hands |> Dict.map (\k -> List.map migrate_Types_Card)
    , gathered = old.gathered |> Dict.map (\k -> List.map migrate_Types_Card)
    , played = old.played |> Dict.map (\k -> migrate_Types_Card)
    , trump = Nothing
    }


migrate_Types_Rank : Evergreen.V4.Types.Rank -> Evergreen.V5.Types.Rank
migrate_Types_Rank old =
    case old of
        Evergreen.V4.Types.Ace ->
            Evergreen.V5.Types.Ace

        Evergreen.V4.Types.Five ->
            Evergreen.V5.Types.Five

        Evergreen.V4.Types.Six ->
            Evergreen.V5.Types.Six

        Evergreen.V4.Types.Seven ->
            Evergreen.V5.Types.Seven

        Evergreen.V4.Types.Eight ->
            Evergreen.V5.Types.Eight

        Evergreen.V4.Types.Nine ->
            Evergreen.V5.Types.Nine

        Evergreen.V4.Types.Ten ->
            Evergreen.V5.Types.Ten

        Evergreen.V4.Types.Jack ->
            Evergreen.V5.Types.Jack

        Evergreen.V4.Types.Queen ->
            Evergreen.V5.Types.Queen

        Evergreen.V4.Types.King ->
            Evergreen.V5.Types.King


migrate_Types_Suit : Evergreen.V4.Types.Suit -> Evergreen.V5.Types.Suit
migrate_Types_Suit old =
    case old of
        Evergreen.V4.Types.Clubs ->
            Evergreen.V5.Types.Clubs

        Evergreen.V4.Types.Diamonds ->
            Evergreen.V5.Types.Diamonds

        Evergreen.V4.Types.Hearts ->
            Evergreen.V5.Types.Hearts

        Evergreen.V4.Types.Spades ->
            Evergreen.V5.Types.Spades


migrate_Types_ToFrontend : Evergreen.V4.Types.ToFrontend -> Evergreen.V5.Types.ToFrontend
migrate_Types_ToFrontend old =
    case old of
        Evergreen.V4.Types.NoOpToFrontend ->
            Evergreen.V5.Types.NoOpToFrontend

        Evergreen.V4.Types.PlayersList p0 ->
            Evergreen.V5.Types.PlayersList p0

        Evergreen.V4.Types.GiveHand p0 ->
            Evergreen.V5.Types.GiveHand (p0 |> List.map migrate_Types_Card)

        Evergreen.V4.Types.PlayedBy p0 p1 ->
            Evergreen.V5.Types.PlayedBy p0 (p1 |> migrate_Types_Card)

        Evergreen.V4.Types.ClearPlayed ->
            Evergreen.V5.Types.ClearPlayed

        Evergreen.V4.Types.NewTrump p0 ->
            Evergreen.V5.Types.NewTrump (p0 |> migrate_Types_Suit)

        Evergreen.V4.Types.RestoredName p0 ->
            Evergreen.V5.Types.RestoredName p0