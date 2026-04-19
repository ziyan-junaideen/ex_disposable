defmodule ExDisposableTest do
  use ExUnit.Case
  doctest ExDisposable

  test "greets the world" do
    assert ExDisposable.hello() == :world
  end
end
