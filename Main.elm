module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import Process
import RemoteData exposing (..)
import Task
import Time


type alias Model =
    { response : WebData String
    , counter : Int
    , running : Bool
    }


type Msg
    = Toggle
    | Response (WebData String)


init : ( Model, Cmd Msg )
init =
    ( { response = NotAsked
      , counter = 0
      , running = False
      }
    , Cmd.none
    )


request : Http.Request String
request =
    Http.getString "https://jsonplaceholder.typicode.com/users"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Toggle ->
            let
                cmd =
                    if model.running then
                        Cmd.none
                    else
                        Cmd.map Response (RemoteData.sendRequest request)
            in
                ( { model | running = not model.running }, cmd )

        Response response ->
            case response of
                Success _ ->
                    let
                        cmd =
                            if model.running then
                                Process.sleep (1 * Time.second)
                                    |> Task.andThen (\_ -> request |> Http.toTask)
                                    |> RemoteData.fromTask
                                    |> Task.perform (Response)
                            else
                                Cmd.none
                    in
                        ( { model | response = response, counter = model.counter + 1 }, cmd )

                _ ->
                    ( { model | response = response }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ text <| toString <| model
        , button [ onClick Toggle ]
            [ if model.running then
                text "Stop"
              else
                text "Start"
            ]
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }
