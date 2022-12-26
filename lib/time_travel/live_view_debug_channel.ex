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
    IO.inspect(assigns, label: "Assigns!")
    Enum.each(live_list(), &GenServer.cast(&1, {:time_travel, socket_id, assigns}))
    {:noreply, socket}
  end

  def handle_in("clear-assigns", _params, socket) do
    TimeTravel.Jumper.clear()
    {:noreply, socket}
  end

  # Returns a list of current LiveView pids
  defp live_list do
    Process.list()
    |> Enum.map(
      &{
        &1,
        Process.info(&1, [:dictionary])
        |> hd()
        |> elem(1)
        |> Keyword.get(:"$initial_call", {})
      }
    )
    |> Enum.filter(fn {_, process} ->
      process != nil && process != {} &&
        elem(process, 0) == Phoenix.LiveView.Channel
    end)
    |> Enum.map(&elem(&1, 0))
  end
end
