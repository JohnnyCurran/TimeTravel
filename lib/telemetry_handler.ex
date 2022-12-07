defmodule TimeTravel.TelemetryHandler do
  def live_view_event_handler(name, measurement, metadata, context) do
    event_name =
      name
      |> Enum.map(&to_string/1)
      |> Enum.map(&String.replace(&1, "_", " "))
      |> Enum.map_join(" ", &String.capitalize/1)

    {:ok, clean_assigns} =
      metadata.socket.assigns
      |> safe_assigns()
      |> Jason.encode()

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

    endpoint = Application.get_env(:time_travel, :endpoint)

    # Send clean assigns to be inspected through the socket
    endpoint.broadcast("lvdbg:#{metadata.socket.id}", "lv_event", %{
      payload: clean_assigns,
      time: time,
      name: event_name
    })
  end

  # Make assigns JSON serializable
  def safe_assigns(assigns) do
    Enum.reduce(assigns, %{}, fn
      {_key, %Ecto.Association.NotLoaded{}}, acc ->
        acc

      {key, %DateTime{} = v}, acc ->
        Map.put(acc, key, DateTime.to_iso8601(v))

      {key, %Date{} = v}, acc ->
        Map.put(acc, key, Date.to_iso8601(v))

      {key, value}, acc when is_struct(value) ->
        clean_struct =
          value
          |> Map.delete(:__meta__)
          |> Map.from_struct()

        Map.put(acc, key, safe_assigns(clean_struct))

      {key, value}, acc when is_function(value) ->
        Map.put(acc, key, inspect(value))

      {key, value}, acc when is_map(value) ->
        Map.put(acc, key, safe_assigns(value))

      {key, value}, acc when is_list(value) ->
        Map.put(acc, key, Enum.map(value, &safe_assign/1))

      {key, value}, acc when is_tuple(value) ->
        Map.put(acc, key, safe_assigns(Tuple.to_list(value)))

      {_key, value}, acc when is_pid(value) ->
        acc

      {key, value}, acc ->
        Map.put(acc, key, value)

      %DateTime{} = v, _acc ->
        DateTime.to_iso8601(v)

      %Date{} = v, _acc ->
        Date.to_iso8601(v)

      v, _acc when is_struct(v) ->
        v |> Map.delete(:__meta__) |> Map.from_struct() |> safe_assigns()

      v, _acc when is_function(v) ->
        inspect(v)

      v, _acc when is_map(v) ->
        safe_assigns(v)

      v, _acc when is_tuple(v) ->
        v |> Tuple.to_list() |> safe_assigns()

      v, acc when is_pid(v) ->
        acc

      v, _acc ->
        IO.inspect(v, label: "Got the blank handler")
        v
    end)
  end

  # This is for when we have a list of something
  def safe_assign(%DateTime{} = v), do: DateTime.to_iso8601(v)
  def safe_assign(%Date{} = v), do: Date.to_iso8601(v)
  def safe_assign(v) when is_function(v), do: inspect(v)
  def safe_assign(v) when is_map(v), do: safe_assigns(v)
  def safe_assign(v) when is_tuple(v), do: v |> Tuple.to_list() |> safe_assigns()
  def safe_assign(v) when is_pid(v), do: inspect(v)

  def safe_assign(v) when is_struct(v) do
    v
    |> Map.delete(:__meta__)
    |> Map.from_struct()
  end

  def safe_assign(v), do: v
end
