module Frontend exposing (..)

import Basics.Extra exposing (flip)
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Element exposing (..)
import Element.Background as Background
import Lamdera
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
      , hand = []
      , played = Dict.empty
      , playerTopLeft = Nothing
      , playerTopRight = Nothing
      , playerLeft = Nothing
      , playerRight = Nothing
      }
    , Cmd.none
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

        NoOpFrontendMsg ->
            ( model, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )


view : Model -> Browser.Document FrontendMsg
view model =
    { title = ""
    , body =
        -- Elm UI based view
        [ layout
            [ -- dracula dark background
              width fill
            , height fill
            , Background.color (rgb255 40 42 54)
            ]
            -- a column with a first line with two cards in the middle
            -- a second line with two cards on the side
            -- a third line with a card in the middle
            -- a fourth line with a maximum of 8 cards
            (column
                [ width fill
                , height fill
                , spacing 10
                , padding 10
                ]
                [ row
                    [ -- cards centered towards the middle
                      height fill
                    , spacing 100
                    , centerX
                    ]
                    [ model.playerTopLeft |> Maybe.andThen (flip Dict.get model.played) |> viewCard
                    , model.playerTopRight |> Maybe.andThen (flip Dict.get model.played) |> viewCard
                    ]
                , row
                    [ -- cards on the sides
                      height fill
                    , spacing 400
                    , centerX
                    ]
                    [ model.playerLeft |> Maybe.andThen (flip Dict.get model.played) |> viewCard
                    , model.playerRight |> Maybe.andThen (flip Dict.get model.played) |> viewCard
                    ]
                , row
                    [ -- card in the middle
                      centerX
                    ]
                    [ Dict.get model.name model.played |> viewCard
                    ]
                , row
                    [ -- maximum of 8 cards
                      height fill
                    , spacing 70
                    , centerX
                    ]
                    (model.hand |> complete_list 8 |> List.map viewCard)
                ]
            )
        ]
    }


complete_list : Int -> List a -> List (Maybe a)
complete_list n list =
    case list of
        [] ->
            List.repeat n Nothing

        head :: tail ->
            Just head :: complete_list (n - 1) tail


viewCard : Maybe Card -> Element FrontendMsg
viewCard card =
    column
        [ width (px 100)
        , height (px 150)
        , spacing 10
        , padding 10
        -- white background
        , Background.color (rgb255 255 255 255)
        ]
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
