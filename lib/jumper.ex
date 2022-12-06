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

  def handle_cast(:reset, _state) do
    {:noreply, %{}}
  end

  def show() do
    GenServer.call(TimeTravel.Jumper, :show_state)
  end
end
