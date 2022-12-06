# TimeTravel

TimeTravel is a record & replay debugger for Phoenix LiveView applications.

TimeTravel allows you to record the state of your LiveView as you interact with the page and replay the interactions while viewing the state of the socket's assigns at any given point in time.

By attaching to the Telemetry events Phoenix LiveView emits we are able to construct a timeline of events & state to rewind and replay as many times as you like in order to track down bugs in the socket's state.

TimeTravel was inspired by [Elm Reactor](https://elm-lang.org/news/time-travel-made-easy) and the [rr-project](https://rr-project.org/)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `time_travel` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:time_travel, "~> 0.1.0"}
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
  - Make sure you have a socket configuration set up in `lib_your_app_web/endpoint.ex`:
  ```elixir
  socket "/socket", YourAppWeb.UserSocket,
    websocket: true,
    longpoll: false
  ```
4. Create the channel in `app.js` (before you declare the liveSocket):
```js
let socketId = document.querySelector('div[data-phx-main]').getAttribute("id");
let timeTravelSocket = new Socket("/socket")
timeTravelSocket.connect();
let channel = timeTravelSocket.channel('lvdbg:' + socketId);
channel.join()
  .receive("ok", ({messages}) => console.log("catching up", messages) )
  .receive("error", ({reason}) => console.log("failed join", reason) )
  .receive("timeout", () => console.log("Networking issue. Still waiting..."))

channel.on("lv_event", payload => {
  window.dispatchEvent(new CustomEvent('SaveAssigns', {detail: payload}));
});

window.addEventListener('RestoreAssigns', e => {
  channel.push("restore-assigns", {...e.detail, socketId: socketId});
});

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})
```
5. Set your Endpoint and PubSub modules in `config/config.exs`:
```elixir
# config/config.exs
config :time_travel,
  endpoint: MyAppWeb.Endpoint,
  pubsub: MyAppWeb.PubSub
```

6. Attach to the telemetry handlers in the init callback in `lib/your_app_web/telemetry.ex`:
```
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


7. Finally, subscribe to and handle the callbacks on the LiveView you want to debug:
```
# page_live.ex
def mount(params, session, socket) do
  if connected?(socket) do
    Phoenix.PubSub.subscribe(MyAppWeb.PubSub, "time_travel")
  end

  {:ok, socket}
end

def handle_info({:time_travel, _socket_id, nil}, socket) do
  {:noreply, socket}
end

def handle_info({:time_travel, socket_id, assigns}, %{id: id} = socket) when id == socket_id do
  {:noreply, assign(socket, assigns)}
end

def handle_info({:time_travel, _socket_id, _assigns}, params, socket) do
  {:noreply, socket}
end
```

For a full example see the [Time Travel Demo Repo](https://github.com/JohnnyCurran/TimeTravelDemo)
