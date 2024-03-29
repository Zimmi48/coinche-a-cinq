module Evergreen.Migrate.V7 exposing (..)

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

import Evergreen.V5.Types
import Evergreen.V7.Types
import Lamdera.Migrations exposing (..)


frontendModel : Evergreen.V5.Types.FrontendModel -> ModelMigration Evergreen.V7.Types.FrontendModel Evergreen.V7.Types.FrontendMsg
frontendModel old =
    ModelUnchanged


backendModel : Evergreen.V5.Types.BackendModel -> ModelMigration Evergreen.V7.Types.BackendModel Evergreen.V7.Types.BackendMsg
backendModel old =
    ModelUnchanged


frontendMsg : Evergreen.V5.Types.FrontendMsg -> MsgMigration Evergreen.V7.Types.FrontendMsg Evergreen.V7.Types.FrontendMsg
frontendMsg old =
    MsgMigrated ( migrate_Types_FrontendMsg old, Cmd.none )


toBackend : Evergreen.V5.Types.ToBackend -> MsgMigration Evergreen.V7.Types.ToBackend Evergreen.V7.Types.BackendMsg
toBackend old =
    MsgMigrated ( migrate_Types_ToBackend old, Cmd.none )


backendMsg : Evergreen.V5.Types.BackendMsg -> MsgMigration Evergreen.V7.Types.BackendMsg Evergreen.V7.Types.BackendMsg
backendMsg old =
    MsgUnchanged


toFrontend : Evergreen.V5.Types.ToFrontend -> MsgMigration Evergreen.V7.Types.ToFrontend Evergreen.V7.Types.FrontendMsg
toFrontend old =
    MsgUnchanged


migrate_Types_Card : Evergreen.V5.Types.Card -> Evergreen.V7.Types.Card
migrate_Types_Card old =
    { suit = old.suit |> migrate_Types_Suit
    , rank = old.rank |> migrate_Types_Rank
    }


migrate_Types_FrontendMsg : Evergreen.V5.Types.FrontendMsg -> Evergreen.V7.Types.FrontendMsg
migrate_Types_FrontendMsg old =
    case old of
        Evergreen.V5.Types.UrlClicked p0 ->
            Evergreen.V7.Types.UrlClicked p0

        Evergreen.V5.Types.UrlChanged p0 ->
            Evergreen.V7.Types.UrlChanged p0

        Evergreen.V5.Types.UpdateName p0 ->
            Evergreen.V7.Types.UpdateName p0

        Evergreen.V5.Types.StartGame ->
            Evergreen.V7.Types.StartGame

        Evergreen.V5.Types.PlayCard p0 ->
            Evergreen.V7.Types.PlayCard (p0 |> migrate_Types_Card)

        Evergreen.V5.Types.GatherCards ->
            Evergreen.V7.Types.GatherCards

        Evergreen.V5.Types.ChangeTrump p0 ->
            Evergreen.V7.Types.ChangeTrump (p0 |> migrate_Types_Suit)

        Evergreen.V5.Types.NoOpFrontendMsg ->
            Evergreen.V7.Types.NoOpFrontendMsg


migrate_Types_Rank : Evergreen.V5.Types.Rank -> Evergreen.V7.Types.Rank
migrate_Types_Rank old =
    case old of
        Evergreen.V5.Types.Ace ->
            Evergreen.V7.Types.Ace

        Evergreen.V5.Types.Five ->
            Evergreen.V7.Types.Five

        Evergreen.V5.Types.Six ->
            Evergreen.V7.Types.Six

        Evergreen.V5.Types.Seven ->
            Evergreen.V7.Types.Seven

        Evergreen.V5.Types.Eight ->
            Evergreen.V7.Types.Eight

        Evergreen.V5.Types.Nine ->
            Evergreen.V7.Types.Nine

        Evergreen.V5.Types.Ten ->
            Evergreen.V7.Types.Ten

        Evergreen.V5.Types.Jack ->
            Evergreen.V7.Types.Jack

        Evergreen.V5.Types.Queen ->
            Evergreen.V7.Types.Queen

        Evergreen.V5.Types.King ->
            Evergreen.V7.Types.King


migrate_Types_Suit : Evergreen.V5.Types.Suit -> Evergreen.V7.Types.Suit
migrate_Types_Suit old =
    case old of
        Evergreen.V5.Types.Clubs ->
            Evergreen.V7.Types.Clubs

        Evergreen.V5.Types.Diamonds ->
            Evergreen.V7.Types.Diamonds

        Evergreen.V5.Types.Hearts ->
            Evergreen.V7.Types.Hearts

        Evergreen.V5.Types.Spades ->
            Evergreen.V7.Types.Spades


migrate_Types_ToBackend : Evergreen.V5.Types.ToBackend -> Evergreen.V7.Types.ToBackend
migrate_Types_ToBackend old =
    case old of
        Evergreen.V5.Types.NoOpToBackend ->
            Evergreen.V7.Types.NoOpToBackend

        Evergreen.V5.Types.JoinGame p0 ->
            Evergreen.V7.Types.JoinGame p0

        Evergreen.V5.Types.Reset ->
            Evergreen.V7.Types.Reset

        Evergreen.V5.Types.Played p0 ->
            Evergreen.V7.Types.Played (p0 |> migrate_Types_Card)

        Evergreen.V5.Types.Gathered ->
            Evergreen.V7.Types.Gathered

        Evergreen.V5.Types.TrumpChanged p0 ->
            Evergreen.V7.Types.TrumpChanged (p0 |> migrate_Types_Suit)

        Evergreen.V5.Types.RestoreName ->
            Evergreen.V7.Types.RestoreName

        Evergreen.V5.Types.RestoreSession ->
            Evergreen.V7.Types.RestoreSession

