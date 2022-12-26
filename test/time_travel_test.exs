defmodule TimeTravelTest do
  use ExUnit.Case
  doctest TimeTravel

  alias TimeTravel.Jumper

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

  test "Clear all Jumper assigns"

  test "Broadcast lvdbg message when telemetry event received"

  test "Cast to LiveView processes when channel receives restore-assigns message"

  test "Clear Jumper assigns when channel receives clear-assigns message"

  describe "safe_assigns/1" do
    test "pid"
    test "binary"
    test "struct"
    test "map"
    test "list"
  end
end
