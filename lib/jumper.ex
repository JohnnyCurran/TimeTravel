defmodule TimeTravel.Jumper do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:get, socket_id, key}, _from, state) do
    {:reply, get_in(state, [socket_id, key]), state}
  end

  def handle_call(:show_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:set, socket_id, key, assigns}, state) do
    {:noreply, put_in(state, [Access.key(socket_id, %{}), Access.key(key, %{})], assigns)}
  end

  def handle_cast({:set, keys_and_assigns}, state) when is_list(keys_and_assigns) do
    assigns = List.last(keys_and_assigns)
    keys =
      keys_and_assigns
      |> Enum.drop(-1)
      |> Enum.map(&Access.key(&1, %{}))
    {:noreply, put_in(state, keys, assigns) |> IO.inspect()}
  end

  def handle_cast(:clear, _state) do
    {:noreply, %{}}
  end

  def show do
    GenServer.call(TimeTravel.Jumper, :show_state)
  end

  def clear do
    GenServer.cast(TimeTravel.Jumper, :clear)
  end
end
