module Backend exposing (..)

import Basics.Extra exposing (flip)
import Html
import Lamdera exposing (ClientId, SessionId)
import Types exposing (..)


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> Sub.none
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { players = []
      , game = Nothing
      }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        NoOpToBackend ->
            ( model, Cmd.none )

        Reset ->
            ( { players = [], game = Nothing }, Cmd.none )

        JoinGame playerName ->
            let
                players =
                    { name = playerName
                    , id = sessionId
                    }
                        :: model.players
            in
            ( { model | players = players }
            , sendToAllPlayers players (PlayersList (List.map .name players))
            )


sendToAllPlayers : List Player -> ToFrontend -> Cmd BackendMsg
sendToAllPlayers players msg =
    players
        |> List.map .id
        |> List.map (flip Lamdera.sendToFrontend msg)
        |> Cmd.batch
