Delayed requests in Elm:

Kudos to [ilias](https://elmlang.slack.com/team/ilias) and his solution:

```elm
sendDelayedRequest : (WebData String -> msg) -> Cmd msg
sendDelayedRequest tagger =
    Process.sleep (200 * Time.millisecond)
        |> Task.andThen (\_ -> Http.toTask request)
        |> RemoteData.fromTask
        |> Task.perform tagger
```

or even better:

```elm
sendDelayedRequest : Time.Time -> Http.Request a -> (WebData a -> msg) -> Cmd msg
sendDelayedRequest delay request tagger =
    Process.sleep delay
        |> Task.andThen (\_ -> Http.toTask request)
        |> RemoteData.fromTask
        |> Task.perform tagger
```
