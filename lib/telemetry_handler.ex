defmodule TimeTravel.TelemetryHandler do
  def live_view_event_handler(name, measurement, metadata, context, endpoint) do
    event_name =
      name
      |> Enum.map(&to_string/1)
      |> Enum.map(&String.replace(&1, "_", " "))
      |> Enum.map_join(" ", &String.capitalize/1)

    {:ok, clean_assigns} =
      metadata.socket.assigns
      |> Utils.safe_assigns()
      |> Jason.encode()

    # IO.inspect metadata.socket, label: "SOCK!"

    # AllegroWeb.Endpoint.broadcast("lvdbg", "lv_event", %{payload: clean_assigns})
    #
    # Positive: no negative number keys
    # monotonic: always increasing so the list can be sorted
    time = System.unique_integer([:positive, :monotonic])
    # Time key is cast to a string separately so that "time" stays an integer in the JSON response
    # and makes the retrieval of indices easier
    time_key = to_string(time)
    # Store original assigns in our server
    GenServer.cast(
      TimeTravel.Jumper,
      {:set, metadata.socket.id, time_key, metadata.socket.assigns}
    )

    # Send clean assigns to be inspected through the socket
    endpoint.broadcast("lvdbg:#{metadata.socket.id}", "lv_event", %{
      payload: clean_assigns,
      time: time,
      name: event_name
    })
  end
end
