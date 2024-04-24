defmodule Recurse do
  def loopy([head | tail]) do
    IO.puts("Head: #{head} Tail: #{inspect(tail)}")
    loopy(tail)
  end

  def loopy([]), do: IO.puts("Done!")

  def sum([head | tail], accumulator) do
    sum(tail, accumulator + head)
  end

  def sum([], accumulator), do: accumulator

  def triple([head | tail], list) do
    # slow with "++" but works
    triple(tail, list ++ [head * 3])
    # triple(tail, [list | [head * 3]])
  end

  def triple([], list), do: list

  # def triple([head | tail]) do
  #   [head * 3 | triple(tail)]
  # end
  # def triple([]), do: []

  def my_map([head | tail], fn_for_each) do
    [fn_for_each.(head) | my_map(tail, fn_for_each)]
  end

  def my_map([], _fn_for_each), do: []
end

# nums = [1, 2, 3, 4, 5]

# Recurse.loopy(nums)
# Recurse.sum(nums, 0) |> IO.inspect(label: "sum total")
# Recurse.triple(nums, []) |> IO.inspect(label: "triple")
# Recurse.triple(nums) |> IO.inspect(label: "triple")
# Recurse.my_map(nums, &(&1 * 4)) |> IO.inspect(label: "my map")
