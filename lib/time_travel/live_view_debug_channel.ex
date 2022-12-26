defmodule TimeTravel.LiveViewDebugChannel do
  use Phoenix.Channel

  alias TimeTravel.Jumper

  require Logger

  def join("lvdbg:" <> liveview_socket_id, _payload, socket) do
    # LV Socket ID can be gotten off of the DOM when we're creating the debug channel
    Logger.info("Joining LV Dbg Channel for socket ID #{liveview_socket_id}")
    {:ok, socket}
  end

  # Want to do a send_update on restore-assigns instead of genserver cast
  # if it's a livecomponent
  def handle_in("restore-assigns", %{"component" => nil} = params, socket) do
    %{"jumperKey" => assigns_key, "socketId" => socket_id, "time" => time_key} = params
    assigns = Jumper.get(assigns_key, time_key)
    Enum.each(live_list(), &GenServer.cast(&1, {:time_travel, socket_id, assigns}))
    {:noreply, socket}
  end

  def handle_in("restore-assigns", %{"component" => component_string} = params, socket) do
    %{
      "jumperKey" => assigns_key,
      "socketId" => socket_id,
      "time" => time_key,
      "componentPid" => component_pid_string
    } = params

    assigns = Jumper.get(assigns_key, time_key)
    module = Module.concat([component_string])

    pid =
      component_pid_string
      |> Base.decode64!()
      |> :erlang.binary_to_term()

    assigns =
      assigns
      |> Map.put(:time_travel, true)

    Phoenix.LiveView.send_update(pid, module, assigns)
    {:noreply, socket}
  end

  def handle_in("clear-assigns", _params, socket) do
    Jumper.clear()
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
      process && process != {} &&
        elem(process, 0) == Phoenix.LiveView.Channel
    end)
    |> Enum.map(&elem(&1, 0))
  end
end
