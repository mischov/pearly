defmodule PearlyTest do
  use ExUnit.Case
  doctest Pearly

  test "highlight YAML as HTML" do
    source = File.read!("test/data/yaml_unhighlighted.yaml")
    expected = {:ok, File.read!("test/data/yaml_highlighted.html")}
    assert Pearly.highlight("yaml", source, theme: "InspiredGitHub") == expected
  end

  @unhighlighted_elixir """
defmodule HighlightingTest do
  @moduledoc "A module for testing highlighting"

  def test(), do: [1, 2, 3]
end
"""

  test "highlight Elixir for the terminal" do
    source = @unhighlighted_elixir
    expected = {:ok, File.read!("test/data/elixir_highlighted.txt")}
    assert Pearly.highlight("elixir", source, format: :terminal) == expected
  end

  test "highlight no lang as plain text" do
    source = @unhighlighted_elixir
    expected = {:ok, File.read!("test/data/no_lang_highlighted.txt")}
    assert Pearly.highlight("txt", source, format: :terminal) == expected
    assert Pearly.highlight(nil, source, format: :terminal) == expected
    assert Pearly.highlight("", source, format: :terminal) == expected
  end
end
