defmodule Cuid2ExTest do
  require Logger
  use ExUnit.Case

  test "create/0 generates valid CUID2 strings" do
    id = Cuid2Ex.create()
    assert Cuid2Ex.cuid?(id)
    # default length
    assert String.length(id) == 24
    Logger.debug("Created CUID2: #{id}")
  end

  test "init/1 with custom length generates correct length IDs" do
    custom_length = 32
    generator = Cuid2Ex.init(length: custom_length)
    id = generator.()

    assert Cuid2Ex.cuid?(id)
    assert String.length(id) == custom_length
  end

  test "cuid?/2 validates CUID2 strings correctly" do
    # Valid cases
    assert Cuid2Ex.cuid?("k0xpkry4lx8tl3qh8vry0f6m")
    assert Cuid2Ex.cuid?("abc123", min_length: 2, max_length: 32)

    # Invalid cases
    # invalid character
    refute Cuid2Ex.cuid?("!")
    # too short
    refute Cuid2Ex.cuid?("a")
    # too long
    refute Cuid2Ex.cuid?("a" <> String.duplicate("0", 33))
    # non-string input
    refute Cuid2Ex.cuid?(123)
  end
end
