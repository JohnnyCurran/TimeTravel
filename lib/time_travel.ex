defmodule TimeTravel do
  @moduledoc """
  Documentation for `TimeTravel`.
  """
  def endpoint do
    case Application.fetch_env(:time_travel, :endpoint) do
      :error ->
        raise """
        Unable to retrieve :endpoint from config. Make sure you have specified "config :time_travel, :endpoint, YourAppWeb.Endpoint" inside of config/config.exs
        """

      {:ok, endpoint} ->
        endpoint
    end
  end

  defmacro __using__(_) do
    quote do
      @before_compile TimeTravel
    end
  end

  defmacro __before_compile__(_env) do
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
