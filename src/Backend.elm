module Backend exposing (..)

import Basics.Extra exposing (flip)
import Dict
import Dict.Extra as Dict
import Lamdera exposing (ClientId, SessionId)
import List.Extra as List
import Random
import Random.List
import Tuple exposing (second)
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

        NewGame game ->
            ( { model | game = Just game }
            , model.players
                |> List.map .id
                |> List.filterMap
                    (\playerId ->
                        Dict.get playerId game.hands
                            |> Maybe.map
                                (GiveHand >> Lamdera.sendToFrontend playerId)
                    )
                |> Cmd.batch
            )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        NoOpToBackend ->
            ( model, Cmd.none )

        Reset ->
            ( { players = [], game = Nothing }, Cmd.none )

        JoinGame playerName ->
            case model.game of
                Just _ ->
                    ( model, Cmd.none )

                Nothing ->
                    let
                        players =
                            { name = playerName
                            , id = sessionId
                            }
                                :: model.players

                        shuffleCards =
                            case players of
                                [ player1, player2, player3, player4, player5 ] ->
                                    initialGame player1 player2 player3 player4 player5
                                        |> Random.generate NewGame

                                _ ->
                                    Cmd.none
                    in
                    ( { model | players = players }
                    , Cmd.batch
                        [ shuffleCards
                        , players
                            |> List.map .name
                            |> PlayersList
                            |> sendToAllPlayers players
                        ]
                    )

        Played card ->
            case model.game of
                Nothing ->
                    ( model, Cmd.none )

                Just game ->
                    case
                        ( Dict.get sessionId game.hands
                        , List.find (.id >> (==) sessionId) model.players
                        )
                    of
                        ( Just hand, Just player ) ->
                            let
                                newHand =
                                    List.remove card hand

                                newGame =
                                    { game
                                        | played =
                                            Dict.insert sessionId card game.played
                                        , hands = Dict.insert sessionId newHand game.hands
                                    }
                            in
                            ( { model | game = Just newGame }
                            , sendToAllPlayers model.players (PlayedBy player.name card)
                            )

                        _ ->
                            ( model, Cmd.none )

        Gathered ->
            case model.game of
                Nothing ->
                    ( model, Cmd.none )

                Just game ->
                    let
                        newlyGathered =
                            Dict.toList game.played
                                |> List.map Tuple.second

                        gathered =
                            Dict.update sessionId (\cards -> Just (newlyGathered ++ Maybe.withDefault [] cards)) game.gathered
                    in
                    ( { model
                        | game =
                            Just
                                { game
                                    | played = Dict.empty
                                    , gathered = gathered
                                }
                      }
                    , [ sendToAllPlayers model.players ClearPlayed
                      , if Dict.any (\_ -> List.isEmpty) game.hands then
                            -- compute score
                            let
                                scoresDict =
                                    Dict.map
                                        (\_ ->
                                            List.map (cardValue game.trump)
                                                >> List.sum
                                        )
                                        gathered

                                scores =
                                    model.players
                                        |> List.filterMap
                                            (\player ->
                                                Dict.get player.id scoresDict
                                                    |> Maybe.map
                                                        (\score ->
                                                            ( player.name
                                                            , score
                                                            )
                                                        )
                                            )
                                        |> Dict.fromList
                            in
                            sendToAllPlayers model.players (Scores scores)

                        else
                            Cmd.none
                      ]
                        |> Cmd.batch
                    )

        TrumpChanged newTrump ->
            case model.game of
                Nothing ->
                    ( model, Cmd.none )

                Just game ->
                    ( { model | game = Just { game | trump = Just newTrump } }
                    , sendToAllPlayers model.players (NewTrump newTrump)
                    )

        RestoreName ->
            case List.find (.id >> (==) sessionId) model.players of
                Just player ->
                    ( model
                    , Lamdera.sendToFrontend sessionId (RestoredName player.name)
                    )

                Nothing ->
                    ( model, Cmd.none )

        RestoreSession ->
            case model.game of
                Nothing ->
                    ( model
                    , model.players
                        |> List.map .name
                        |> PlayersList
                        |> Lamdera.sendToFrontend sessionId
                    )

                Just game ->
                    ( model
                    , Cmd.batch
                        ((model.players
                            |> List.map .name
                            |> PlayersList
                            |> Lamdera.sendToFrontend sessionId
                         )
                            :: (Dict.get sessionId game.hands
                                    |> Maybe.map (\hand -> [ Lamdera.sendToFrontend sessionId (GiveHand hand) ])
                                    |> Maybe.withDefault []
                               )
                            ++ (game.played
                                    |> Dict.toList
                                    |> List.filterMap
                                        (\( playerId, card ) ->
                                            List.find (.id >> (==) playerId) model.players
                                                |> Maybe.map
                                                    (\player ->
                                                        Lamdera.sendToFrontend sessionId (PlayedBy player.name card)
                                                    )
                                        )
                               )
                        )
                    )


sendToAllPlayers : List Player -> ToFrontend -> Cmd BackendMsg
sendToAllPlayers players msg =
    players
        |> List.map .id
        |> List.map (flip Lamdera.sendToFrontend msg)
        |> Cmd.batch


listOfAllRanks : List Rank
listOfAllRanks =
    [ Ace, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King ]


listOfAllSuits : List Suit
listOfAllSuits =
    [ Clubs, Diamonds, Hearts, Spades ]


listOfAllCards : List Card
listOfAllCards =
    List.concatMap (\suit -> List.map (\rank -> { suit = suit, rank = rank }) listOfAllRanks) listOfAllSuits


initialGame player1 player2 player3 player4 player5 =
    listOfAllCards
        |> Random.List.choices 8
        -- 8 cards per player
        |> Random.andThen
            (\( hand1, deck1 ) ->
                deck1
                    |> Random.List.choices 8
                    |> Random.andThen
                        (\( hand2, deck2 ) ->
                            deck2
                                |> Random.List.choices 8
                                |> Random.andThen
                                    (\( hand3, deck3 ) ->
                                        deck3
                                            |> Random.List.choices 8
                                            |> Random.andThen
                                                (\( hand4, deck4 ) ->
                                                    deck4
                                                        |> Random.List.choices 8
                                                        |> Random.map
                                                            (\( hand5, _ ) ->
                                                                { hands =
                                                                    Dict.fromList
                                                                        [ ( player1.id, hand1 )
                                                                        , ( player2.id, hand2 )
                                                                        , ( player3.id, hand3 )
                                                                        , ( player4.id, hand4 )
                                                                        , ( player5.id, hand5 )
                                                                        ]
                                                                , gathered = Dict.empty
                                                                , played = Dict.empty
                                                                , trump = Nothing
                                                                }
                                                            )
                                                )
                                    )
                        )
            )
