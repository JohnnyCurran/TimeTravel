defmodule TimeTravel.LiveView do
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

defmodule TimeTravel.LiveComponent do
  defmacro __before_compile__(_env) do
    quote do
      def update({:time_travel, :get}, socket) do
        send(self(), {:time_travel, :component_get, socket.assigns})
      end
    end
  end
end

defmodule TimeTravel do
  @moduledoc """
  Macro callbacks for LiveViews and LiveComponents
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def live_view do
    quote do
      @before_compile TimeTravel.LiveView #{TimeTravel, :live_view_before_compile}
    end
  end

  def live_component do
    quote do
      @before_compile TimeTravel.LiveComponent #{TimeTravel, :live_component_before_compile}
    end
  end
end
