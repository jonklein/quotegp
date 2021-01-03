defmodule QuoteGPTest do
  use ExUnit.Case
  doctest QuoteGP

  def config do
    %QuoteGP.Config{}
  end

  test "generates code" do
    assert QuoteGP.Generation.tree(config()) !== nil
  end

  test "mutates code" do
    assert QuoteGP.GeneticOperators.mutation(
             config(),
             QuoteGP.Generation.tree(config()),
             0.1
           ) !== nil
  end

  test "crosses over code" do
    assert QuoteGP.GeneticOperators.crossover(
             QuoteGP.Generation.tree(config()),
             QuoteGP.Generation.tree(config())
           ) !== nil
  end

  test "runs code with proper binding" do
    assert Code.eval_quoted(QuoteGP.Generation.tree(config()), input: 10) !== nil
  end

  test "calculates code depth" do
    code = quote do: (1 + 2 + 3) * 4
    assert QuoteGP.Generation.tree_depth(code) == 4

    code = quote do: 1 + 2 + 3 * 4
    assert QuoteGP.Generation.tree_depth(code) == 3
  end

  test "calculates code points" do
    code = quote do: (1 + 2 + 3) * 4
    assert QuoteGP.Generation.tree_points(code) == 7

    code = quote do: 1 + 2 + 3 * 4
    assert QuoteGP.Generation.tree_points(code) == 7
  end

  test "finds subtrees" do
    code = quote do: 1 + 2 + 3 * 4

    assert QuoteGP.Generation.subtree_with_index(code, 6) == 4

    code = quote do: 1 + 2 + 3 * 4
    assert {:*, _, [3, 4]} = QuoteGP.Generation.subtree_with_index(code, 4)
  end

  test "replaces subtrees" do
    code = quote do: 1 + 2 + 3 * 4
    assert QuoteGP.Generation.replace_index(code, quote(do: 4 * 4), 1) == quote(do: 4 * 4 + 3 * 4)

    assert QuoteGP.Generation.replace_index([1, 2], 100, 1) == quote(do: [1, 100])

    code = quote do: 1 + 2
    assert QuoteGP.Generation.replace_index(code, 100, 2) == quote(do: 1 + 100)
    assert QuoteGP.Generation.replace_index(code, 100, 3) == quote(do: 1 + 2)

    code = quote do: 1 + 2 + 3 * 4
    assert QuoteGP.Generation.replace_index(code, 100, 6) == quote(do: 1 + 2 + 3 * 100)
    assert QuoteGP.Generation.replace_index(code, 22, 0) == quote(do: 22)
    assert QuoteGP.Generation.replace_index(code, quote(do: 4 * 4), 1) == quote(do: 4 * 4 + 3 * 4)
  end

  test "builds and runs a population" do
    QuoteGP.Population.build(%QuoteGP.Config{})
    |> QuoteGP.Population.evaluate([{1, 2}, {2, 4}])
  end

  test "tournament select" do
    population = QuoteGP.Population.build(%QuoteGP.Config{})

    assert "c" ==
             QuoteGP.Population.tournament(
               population.config,
               [{"a", 1.0}, {"b", 2.0}, {"c", 0.1}]
             )
  end

  test "runs a generation" do
    cases = 8..16 |> Enum.map(fn x -> {x, x * x + 3 * x + 8} end)

    QuoteGP.Population.build(%QuoteGP.Config{max_generations: 3})
    |> QuoteGP.Population.run(cases)
  end
end
