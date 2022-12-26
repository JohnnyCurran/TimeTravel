defmodule TimeTravelTest do
  use ExUnit.Case
  doctest TimeTravel

  alias TimeTravel.Jumper
  alias TimeTravel.TelemetryHandler

  test "Set LiveView assigns when :time_travel message received"

  test "Set assigns in Jumper" do
    assert Jumper.state() == %{}

    keys_and_assigns = ["socket_id", "1", %{mykey: :myvalue}]
    Jumper.set(keys_and_assigns)

    assert Jumper.state() == %{"socket_id" => %{"1" => %{mykey: :myvalue}}}
  end

  test "Get assigns from Jumper" do
    assert Jumper.state() == %{}

    keys_and_assigns = ["socket_id", "1", %{mykey: :myvalue}]
    Jumper.set(keys_and_assigns)

    assert Jumper.state() == %{"socket_id" => %{"1" => %{mykey: :myvalue}}}

    assert Jumper.get("socket_id", "1") == %{mykey: :myvalue}
  end

  test "Clear all Jumper assigns" do
    assert Jumper.state() == %{}

    keys_and_assigns = ["socket_id", "1", %{mykey: :myvalue}]
    Jumper.set(keys_and_assigns)

    assert Jumper.state() == %{"socket_id" => %{"1" => %{mykey: :myvalue}}}

    Jumper.clear()

    assert Jumper.state() == %{}
  end

  test "Broadcast lvdbg message when telemetry event received"

  test "Cast to LiveView processes when channel receives restore-assigns message"

  test "Clear Jumper assigns when channel receives clear-assigns message"

  describe "safe_assigns/1" do
    test "Nested data structures"
    test "pid"
    test "bitstring" do
      {:ok, _} =
        %{
          binary: "Some binary",
          bitstring: <<3::4>>
        }
        |> TelemetryHandler.safe_assigns()
        |> Jason.encode()
    end

    test "binary" do
      {:ok, _} = TelemetryHandler.safe_assigns("I am some binary")
                 |> Jason.encode()
    end

    test "struct"

    test "map" do
      map = %{
        "key" => "value",
        key: :value,
        something: 12345
      }

      {:ok, _} =
        map
        |> TelemetryHandler.safe_assigns()
        |> Jason.encode()
    end

    test "list" do
      {:ok, _} =
        [:some_atom, "some_string", 12345, %{some_key: "some_value"}]
        |> TelemetryHandler.safe_assigns()
        |> Jason.encode()
    end
  end
end
