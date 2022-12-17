defmodule TimeTravel do
  @moduledoc """
  Documentation for `TimeTravel`.
  """
  defmacro __using__(_) do
    quote do
      @before_compile {TimeTravel, :live_view}
    end
  end

  def live_view(__env__) do
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
