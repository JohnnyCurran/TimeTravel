# TimeTravel

TimeTravel is a record & replay debugger for Phoenix LiveView applications.

TimeTravel allows you to record the state of your LiveView as you interact with the page and replay the interactions while viewing the state of the socket's assigns at any given point in time.

By attaching to the Telemetry events Phoenix LiveView emits we are able to construct a timeline of events & state to rewind and replay as many times as you like in order to track down bugs in the socket's state.

TimeTravel was inspired by [Elm Reactor](https://elm-lang.org/news/time-travel-made-easy) and the [rr-project](https://rr-project.org/)

## Demo

See the [Time Travel Demo Repo](https://github.com/JohnnyCurran/TimeTravelDemo) for a working example

See a short example video here:

https://user-images.githubusercontent.com/18315178/206929183-2ce45dca-665a-4a3e-bb36-d0862dc0d4c3.mov

## Installation

The package can be installed by adding `time_travel` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:time_travel, "~> 0.2"}
  ]
end
```

### Steps
1. Download and install the [Chrome Extension](https://github.com/JohnnyCurran/LiveViewTimeTravelExtension)

2. Add `:time_travel` as an Elixir dependency in `mix.exs` (see above)

3. (If you have already set up Phoenix Channels) Add the `lvdbg` channel specification in `your_app_web/channels/user_socket.ex`:
```elixir
## Channels
channel "lvdbg:*", TimeTravel.LiveViewDebugChannel
```
  - If you have not set up a Phoenix socket, run `mix phx.gen.socket User`
  - Make sure you have a socket configuration set up in `lib/your_app_web/endpoint.ex`:
  ```elixir
  socket "/socket", YourAppWeb.UserSocket,
    websocket: true,
    longpoll: false
  ```

4. Import time travel and declare the socket in `app.js` (before you declare the liveSocket):
```js
import {Socket} from "phoenix"
import {TimeTravel} from "time_travel"
let timeTravel = new TimeTravel(Socket);

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})
```

5. Configure TimeTravel to use your Endpoint `config/config.exs`:
```elixir
# config/config.exs
config :time_travel, endpoint: MyAppWeb.Endpoint
```

6. Attach to the telemetry handlers in the init callback in `lib/your_app_web/telemetry.ex`:
```elixir
# telemetry.ex
# init callback
:ok =
  :telemetry.attach_many(
    "live-view-handler",
    [
      [:phoenix, :live_view, :mount, :stop],
      [:phoenix, :live_view, :handle_event, :stop],
      [:phoenix, :live_view, :handle_params, :stop]
    ],
    &TimeTravel.TelemetryHandler.live_view_event_handler/4,
    %{}
  )
```

7. Finally, `use TimeTravel` in the `live_view` definition in `my_app_web.ex`:
```elixir
def live_view do
  quote do
    use Phoenix.LiveView,
      layout: {TimeTravelDemoWeb.LayoutView, "live.html"}

    # Import TimeTravel handle_cast callbacks for each LiveView
    use TimeTravel

    # ...
  end
end
```

For a full example see the [Time Travel Demo Repo](https://github.com/JohnnyCurran/TimeTravelDemo)

## Usage
1. With the LiveView open, Right click > Inspect
2. Press the arrows >> for more options and select LiveView DevTools
3. Interact with your LiveView (LiveComponents not supported at this time)
4. Drag the slider back and forth to replace the socket assigns

### Notes
- If you run out of chrome storage, press the "Clear Storage" button (The Extension & Library is memory-heavy at this time)
