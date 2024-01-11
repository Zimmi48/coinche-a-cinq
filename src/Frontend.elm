module Frontend exposing (..)

import Basics.Extra exposing (flip)
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input
import Lamdera
import List.Extra as List
import Types exposing (..)
import Url


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \m -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { key = key
      , name = ""
      , playing = False
      , hand = []
      , played = Dict.empty
      , playerTopLeft = Nothing
      , playerTopRight = Nothing
      , playerLeft = Nothing
      , playerRight = Nothing
      , trump = Nothing
      , scores = Dict.empty
      }
    , if url.path == "/reset" then
        Cmd.batch
            [ Lamdera.sendToBackend Reset
            , Nav.pushUrl key "/"
            ]

      else
        Lamdera.sendToBackend RestoreName
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            ( model, Cmd.none )

        UpdateName name ->
            ( { model | name = name }
            , Cmd.none
            )

        StartGame ->
            ( { model | playing = True }
            , Lamdera.sendToBackend (JoinGame model.name)
            )

        PlayCard card ->
            case model.played |> Dict.get model.name of
                Just _ ->
                    ( model, Cmd.none )

                Nothing ->
                    ( { model
                        | played = Dict.insert model.name card model.played
                        , hand =
                            model.hand
                                |> List.filter ((/=) card)
                                |> sortHand model.trump
                      }
                    , Lamdera.sendToBackend (Played card)
                    )

        GatherCards ->
            ( { model | played = Dict.empty }
            , Lamdera.sendToBackend Gathered
            )

        ChangeTrump trump ->
            ( { model
                | trump = Just trump
                , hand = sortHand (Just trump) model.hand
              }
            , Lamdera.sendToBackend (TrumpChanged trump)
            )

        NoOpFrontendMsg ->
            ( model, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )

        PlayersList players ->
            let
                playerIndex =
                    List.elemIndex model.name players
            in
            ( { model
                | playerRight =
                    playerIndex
                        |> Maybe.andThen
                            ((+) 1
                                >> modBy 5
                                >> flip List.getAt players
                            )
                , playerTopRight =
                    playerIndex
                        |> Maybe.andThen
                            ((+) 2
                                >> modBy 5
                                >> flip List.getAt players
                            )
                , playerTopLeft =
                    playerIndex
                        |> Maybe.andThen
                            ((+) 3
                                >> modBy 5
                                >> flip List.getAt players
                            )
                , playerLeft =
                    playerIndex
                        |> Maybe.andThen
                            ((+) 4
                                >> modBy 5
                                >> flip List.getAt players
                            )
              }
            , Cmd.none
            )

        GiveHand hand ->
            ( { model | hand = sortHand model.trump hand }
            , Cmd.none
            )

        PlayedBy name card ->
            ( { model | played = Dict.insert name card model.played }
            , Cmd.none
            )

        ClearPlayed ->
            ( { model | played = Dict.empty }
            , Cmd.none
            )

        NewTrump trump ->
            ( { model
                | trump = Just trump
                , hand = sortHand (Just trump) model.hand
              }
            , Cmd.none
            )

        RestoredName name ->
            ( { model | name = name, playing = True }
            , Lamdera.sendToBackend RestoreSession
            )

        Scores scores ->
            ( { model | scores = scores }
            , Cmd.none
            )


sortHand : Maybe Suit -> List Card -> List Card
sortHand trump hand =
    let
        -- separate the hand in four lists
        hearts =
            hand
                |> List.filter ((==) Hearts << .suit)
                |> sortRank (trump == Just Hearts)

        spades =
            hand
                |> List.filter ((==) Spades << .suit)
                |> sortRank (trump == Just Spades)

        diamonds =
            hand
                |> List.filter ((==) Diamonds << .suit)
                |> sortRank (trump == Just Diamonds)

        clubs =
            hand
                |> List.filter ((==) Clubs << .suit)
                |> sortRank (trump == Just Clubs)
    in
    case ( hearts, diamonds ) of
        ( [], _ ) ->
            -- use diamonds to separate spades and clubs
            spades ++ diamonds ++ clubs

        ( _, [] ) ->
            -- use hearts to separate spades and clubs
            spades ++ hearts ++ clubs

        _ ->
            case spades of
                [] ->
                    -- use clubs to separate hearts and diamonds
                    hearts ++ clubs ++ diamonds

                _ ->
                    -- use spades to separate hearts and diamonds
                    hearts ++ spades ++ diamonds ++ clubs


sortRank : Bool -> List Card -> List Card
sortRank isTrump cards =
    List.sortBy (.rank >> rankOrder isTrump >> negate) cards


view : Model -> Browser.Document FrontendMsg
view model =
    { title = "Coinche à cinq"
    , body =
        -- Elm UI based view
        [ layout
            [ width fill
            , height fill
            , padding 20
            , dracula
            ]
            (if model.playing then
                viewGame model

             else
                viewLobby model
            )
        ]
    }


dracula =
    -- dark background
    Background.color (rgb255 40 42 54)


dracula2 =
    -- clearer background
    Background.color (rgb255 68 71 90)


dracula3 =
    -- even clearer background
    Background.color (rgb255 92 99 112)


white =
    -- white background
    Background.color (rgb255 255 255 255)


viewLobby : Model -> Element FrontendMsg
viewLobby model =
    -- a form to enter a name and a play button
    column
        [ padding 20
        , spacing 20
        , dracula2
        ]
        [ Input.text [ dracula3 ]
            { onChange = UpdateName
            , text = model.name
            , placeholder = Nothing
            , label =
                "Enter your name"
                    |> text
                    |> Input.labelLeft []
            }
        , Input.button
            [ centerX
            , Border.rounded 5
            , Border.width 1
            , Border.solid
            , Border.color (rgb255 0 0 0)
            , padding 10
            , dracula3
            ]
            { onPress = Just StartGame
            , label = text "Play"
            }
        ]


viewGame : Model -> Element FrontendMsg
viewGame model =
    -- a column with a first line with two cards in the middle
    -- a second line with two cards on the side
    -- a third line with a card in the middle
    -- a fourth line with a maximum of 8 cards
    column
        [ width fill
        , height fill
        , spacing 10
        , padding 10
        ]
        [ row
            [ -- selector for the trump
              height fill
            , spacing 100
            , centerX
            ]
            [ text "Trump"
            , -- one button per suit
              chooseTrumpButton model.trump Clubs
            , chooseTrumpButton model.trump Diamonds
            , chooseTrumpButton model.trump Hearts
            , chooseTrumpButton model.trump Spades
            ]
        , row
            [ -- cards centered towards the middle
              height fill
            , spacing 100
            , centerX
            ]
            [ viewCardWithName (model.playerTopLeft |> Maybe.andThen (flip Dict.get model.played)) (model.playerTopLeft |> Maybe.andThen (flip Dict.get model.scores)) model.playerTopLeft
            , viewCardWithName (model.playerTopRight |> Maybe.andThen (flip Dict.get model.played)) (model.playerTopRight |> Maybe.andThen (flip Dict.get model.scores)) model.playerTopRight
            ]
        , row
            [ -- cards on the sides
              height fill
            , spacing 400
            , centerX
            ]
            [ viewCardWithName (model.playerLeft |> Maybe.andThen (flip Dict.get model.played)) (model.playerLeft |> Maybe.andThen (flip Dict.get model.scores)) model.playerLeft
            , viewCardWithName (model.playerRight |> Maybe.andThen (flip Dict.get model.played)) (model.playerRight |> Maybe.andThen (flip Dict.get model.scores)) model.playerRight
            ]
        , row
            [ -- card in the middle
              centerX
            ]
            [ viewCardWithName (Dict.get model.name model.played) (Dict.get model.name model.scores) (Just model.name)
            ]
        , row
            [ -- gather button
              centerX
            ]
            [ if allPlayersHavePlayed model then
                Input.button
                    (baseButtonAttributes ++ [ dracula3 ])
                    { onPress = Just GatherCards
                    , label = text "Gather"
                    }

              else
                none
            ]
        , row
            [ -- maximum of 8 cards
              height fill
            , spacing 70
            , centerX
            ]
            (model.hand |> complete_list 8 |> List.map (viewCard dracula))
        ]


chooseTrumpButton : Maybe Suit -> Suit -> Element FrontendMsg
chooseTrumpButton trump suit =
    Input.button
        (baseButtonAttributes
            ++ [ if trump == Just suit then
                    dracula3

                 else
                    dracula2
               ]
        )
        { onPress = Just (ChangeTrump suit)
        , label = text (suitToString suit)
        }


allPlayersHavePlayed : Model -> Bool
allPlayersHavePlayed model =
    Dict.size model.played == 5


complete_list : Int -> List a -> List (Maybe a)
complete_list n list =
    case list of
        [] ->
            List.repeat n Nothing

        head :: tail ->
            Just head :: complete_list (n - 1) tail


viewCardWithName : Maybe Card -> Maybe Int -> Maybe String -> Element FrontendMsg
viewCardWithName card score name =
    column
        [ width (px 120)
        , height (px 200)
        , spacing 10
        , padding 10
        , dracula2
        ]
        [ viewCard dracula2 card
        , el [ centerX ]
            (text
                (Maybe.withDefault "" name
                    ++ Maybe.withDefault ""
                        (score
                            |> Maybe.map (\s -> " (" ++ String.fromInt s ++ ")")
                        )
                )
            )
        ]


viewCard default card =
    column
        ([ width (px 100)
         , height (px 150)
         , spacing 10
         , padding 10
         , Maybe.map (\_ -> white) card |> Maybe.withDefault default
         , Font.color
            (case card |> Maybe.map .suit of
                Just Diamonds ->
                    rgb255 255 0 0

                Just Hearts ->
                    rgb255 255 0 0

                _ ->
                    rgb255 0 0 0
            )
         ]
            ++ (card
                    |> Maybe.map
                        (\concreteCard ->
                            [ onClick (PlayCard concreteCard)
                            ]
                        )
                    |> Maybe.withDefault []
               )
        )
        [ text (card |> Maybe.map (.suit >> suitToString) |> Maybe.withDefault "")
        , text (card |> Maybe.map (.rank >> rankToString) |> Maybe.withDefault "")
        ]


suitToString : Suit -> String
suitToString suit =
    case suit of
        Clubs ->
            "♣"

        Diamonds ->
            "♦"

        Hearts ->
            "♥"

        Spades ->
            "♠"


rankToString : Rank -> String
rankToString rank =
    case rank of
        Ace ->
            "A"

        Five ->
            "5"

        Six ->
            "6"

        Seven ->
            "7"

        Eight ->
            "8"

        Nine ->
            "9"

        Ten ->
            "10"

        Jack ->
            "J"

        Queen ->
            "Q"

        King ->
            "K"


baseButtonAttributes =
    [ centerX
    , Border.rounded 5
    , Border.width 1
    , Border.solid
    , Border.color (rgb255 0 0 0)
    , padding 10
    ]
