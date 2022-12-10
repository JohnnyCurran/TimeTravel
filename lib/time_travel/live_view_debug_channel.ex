defmodule TimeTravel.LiveViewDebugChannel do
  use Phoenix.Channel

  require Logger

  def join("lvdbg:" <> liveview_socket_id, _payload, socket) do
    # LV Socket ID can be gotten off of the DOM when we're creating the debug channel
    Logger.info("Joining LV Dbg Channel for socket ID #{liveview_socket_id}")
    {:ok, socket}
  end

  def handle_in("restore-assigns", params, socket) do
    %{"jumperKey" => assigns_key, "socketId" => socket_id, "time" => time_key} = params
    assigns = GenServer.call(TimeTravel.Jumper, {:get, assigns_key, time_key})
    pubsub = Application.get_env(:time_travel, :pubsub)
    Phoenix.PubSub.broadcast(pubsub, "time_travel", {:time_travel, socket_id, assigns})
    {:noreply, socket}
  end
end
