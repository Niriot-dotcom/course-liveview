defmodule ParserTest do
  use ExUnit.Case
  doctest Servy.Parser

  alias Servy.Parser

  test "parse a list of header fields into a map" do
    header_lines = ["A: a", "B: b"]
    headers = Parser.parse_headers(header_lines)
    assert headers == %{"A" => "a", "B" => "b"}
    refute headers == %{"A" => "a"}
  end
end
