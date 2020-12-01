defmodule QuoteGP.Population do
  @max_fitness 999999999

  @moduledoc """
  Code operations and utilities.
  """

  import QuoteGP.GeneticOperators

  def build(n, max_depth \\ 10)

  def build(0, _) do
    []
  end

  def build(n, max_depth) do
    [QuoteGP.Generation.code_tree(max_depth) | build(n - 1)]
  end

  def evaluate([], _) do
    []
  end

  def evaluate([individual | rest], cases) do
    [{individual, fitness(individual, cases)} | evaluate(rest, cases)]
  end

  def fitness(individual, cases) do
    try do
      cases
      |> Enum.map(fn {input, output} -> output - elem(QuoteGP.Code.evaluate(individual, [input: input]), 0) end)
      |> Enum.map(&(&1 * &1))
      |> Enum.sum

    rescue err ->
      IO.inspect("Error evaluating #{Macro.to_string(individual)}")
      IO.inspect(err)
      @max_fitness
    end
  end

  def generation(population, cases) do
    evaluated = evaluate(population, cases)
                |> Enum.sort(fn {_, f1}, {_, f2} -> f1 < f2 end)

    next = (1..length(population))
      |> Enum.map(fn _ -> next_individual(evaluated) end)

    { best, best_fitness } = Enum.at(evaluated, 0)

    { next, Macro.to_string(best), best_fitness }
  end

  def run(population, cases, max_generations, halt_fitness \\ 0.0)

  def run(population, _, 0, _) do
    population
  end

  def run(population, cases, max_generations, halt_fitness) do
    { next, best, best_fitness } = generation(population, cases)

    IO.inspect("=== Best fitness: #{best_fitness} - individual: #{best}")

    if best_fitness > halt_fitness do
      run(next, cases, max_generations - 1, halt_fitness)
    else
      next
    end
  end

  def tournament(individuals, n \\ 9) do
    Enum.take_random(individuals, n)
    |> Enum.sort(fn {_, f1}, {_, f2} -> f1 < f2 end)
    |> Enum.at(0)
    |> elem(0)
  end

  def next_individual(evaluated_population) do
    method = :rand.uniform()

    cond do
      method < 0.2 -> crossover(tournament(evaluated_population), tournament(evaluated_population))
      method < 0.9 -> mutation(tournament(evaluated_population), 0.1)
      true -> tournament(evaluated_population)
    end
  end
end
