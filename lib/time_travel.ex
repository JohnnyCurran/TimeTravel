defmodule TimeTravel do
  @moduledoc """
  Documentation for `TimeTravel`.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def live_view do
    quote do
      @before_compile {TimeTravel, :live_view_before_compile}
    end
  end

  def live_view_before_compile(__env__) do
    quote do
      def handle_cast({:time_travel, _socket_id, nil}, socket) do
        {:noreply, socket}
      end

      def handle_cast({:time_travel, socket_id, assigns}, %{id: id} = socket)
          when id == socket_id do
        {:noreply, assign(socket, assigns)}
      end

      def handle_cast({:time_travel, _socket_id, _assigns}, params, socket) do
        {:noreply, socket}
      end
    end
  end
end
