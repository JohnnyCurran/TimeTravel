defmodule TimeTravelTest do
  use ExUnit.Case
  doctest TimeTravel

  test "greets the world" do
    assert TimeTravel.hello() == :world
  end
end
