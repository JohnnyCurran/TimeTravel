defmodule TimeTravel do
  @moduledoc """
  Documentation for `TimeTravel`.
  """
  defmacro __using__(_) do
    quote do
      @before_compile TimeTravel
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def handle_info({:time_travel, _socket_id, nil}, socket) do
        {:noreply, socket}
      end

      def handle_info({:time_travel, socket_id, assigns}, %{id: id} = socket) when id == socket_id do
        {:noreply, assign(socket, assigns)}
      end

      def handle_info({:time_travel, _socket_id, _assigns}, params, socket) do
        {:noreply, socket}
      end
    end
  end
end
