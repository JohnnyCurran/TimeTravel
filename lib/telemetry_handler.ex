defmodule TimeTravel.TelemetryHandler do
  # Available LiveView and LiveComponent Telemetry events
  @live_view_events [
    [:phoenix, :live_view, :mount, :start],
    [:phoenix, :live_view, :mount, :stop],
    [:phoenix, :live_view, :handle_params, :start],
    [:phoenix, :live_view, :handle_params, :stop],
    [:phoenix, :live_view, :handle_event, :start],
    [:phoenix, :live_view, :handle_event, :stop],
  ]

  @live_component_events [
    [:phoenix, :live_component, :handle_event, :start],
    [:phoenix, :live_component, :handle_event, :stop]
  ]

  # Would be cool to have a map of LV/Component => assigns
  # In a hierarchy
  # How would nested LiveComponents work ?

  # Metadata has a "component" and then we can use send_update with a macro-injected update CB?
  # How to get Phoenix ID??
  # LiveView.Channel state has the info I need
  # But then I have to fork live view :|
  # It _seems_ difficult / impossible to get the state info I need out of the Channel
  # Is there something I can do with a before compile callback to ensure
  # my mount/1 LiveComponent call runs before any others?
  def live_view_event_handler(name, measurement, metadata, context) do
    IO.inspect(name, label: "Name")
    IO.inspect(metadata, label: "MT", limit: :infinity, printable_limit: :infinity)
    IO.inspect(metadata.socket, label: "Socket", limit: :infinity, printable_limit: :infinity)

    # IO.inspect metadata.socket.assigns[:id], label: "ID!"

    event_name =
      name
      |> Enum.map(&to_string/1)
      |> Enum.map(&String.replace(&1, "_", " "))
      |> Enum.map_join(" ", &String.capitalize/1)

    # Positive: no negative number keys
    # monotonic: always increasing so the list can be sorted
    time = System.unique_integer([:positive, :monotonic])
    # Time key is cast to a string separately so that "time" stays an integer in the JSON response
    # and makes the retrieval of indices easier
    time_key = to_string(time)
    # Store original assigns in our server
    GenServer.cast(
      TimeTravel.Jumper,
      {:set, metadata.socket.id, time_key, Map.delete(metadata.socket.assigns, :flash)}
    )

    {:ok, clean_assigns} =
      metadata.socket.assigns
      |> safe_assigns()
      |> Jason.encode()

    {:ok, event_args} =
      name
      |> Enum.at(2)
      |> event_args(metadata)
      |> safe_assigns()
      |> Jason.encode()

    # Send clean assigns to be inspected through the socket
    metadata.socket.endpoint.broadcast("lvdbg:#{metadata.socket.id}", "SaveAssigns", %{
      payload: clean_assigns,
      time: time,
      event_name: event_name,
      event_args: event_args,
      socket_id: metadata.socket.id
    })
  end

  defp event_args(:mount, metadata), do: Map.take(metadata, [:params, :session])
  defp event_args(:handle_event, metadata), do: Map.take(metadata, [:params, :uri])
  defp event_args(:handle_params, metadata), do: Map.take(metadata, [:params, :uri])

  # Make assigns JSON serializable
  def safe_assigns(assigns) when is_map(assigns) do
    Enum.reduce(assigns, %{}, fn {k, v}, acc -> Map.put(acc, k, safe_assign(v)) end)
  end

  def safe_assigns(assigns) when is_list(assigns) do
    Enum.map(assigns, &safe_assign/1)
  end

  def safe_assign(%Ecto.Association.NotLoaded{} = v), do: inspect(v)
  def safe_assign(%DateTime{} = v), do: DateTime.to_iso8601(v)
  def safe_assign(%Date{} = v), do: Date.to_iso8601(v)
  def safe_assign(v) when is_function(v), do: inspect(v)
  def safe_assign(v) when is_tuple(v), do: v |> Tuple.to_list() |> safe_assigns()
  def safe_assign(v) when is_pid(v), do: inspect(v)

  def safe_assign(v) when is_binary(v) do
    case String.valid?(v) do
      true -> v
      _ -> inspect(v)
    end
  end

  def safe_assign(v) when is_struct(v) do
    v
    |> Map.delete(:__meta__)
    |> Map.from_struct()
    |> safe_assigns()
  end

  def safe_assign(v) when is_map(v), do: safe_assigns(v)
  def safe_assign(v) when is_list(v), do: safe_assigns(v)
  def safe_assign(v), do: v
end
