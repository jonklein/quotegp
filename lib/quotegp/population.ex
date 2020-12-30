defmodule QuoteGP.Population do
  defstruct individuals: [],
            generation: 0,
            config: %QuoteGP.Config{}

  @max_fitness 999_999_999

  @moduledoc """
  A GP population
  """

  import QuoteGP.GeneticOperators

  def build(config = %QuoteGP.Config{}) do
    %QuoteGP.Population{
      config: config,
      individuals:
        Enum.map(1..config.population_size, fn _ ->
          QuoteGP.Generation.code_tree(config)
        end)
    }
  end

  def evaluate(population = %QuoteGP.Population{}, cases) do
    # Chunk up our evaluation to potentially take advantage of multiple cores
    individuals =
      Enum.chunk_every(population.individuals, 8)
      |> Enum.map(&Task.async(fn -> Enum.map(&1, fn i -> {i, fitness(i, cases)} end) end))
      |> Task.await_many()
      |> List.flatten()
      |> Enum.sort(fn {_, f1}, {_, f2} -> f1 < f2 end)

    %{population | individuals: individuals}
  end

  def fitness(individual, cases) do
    # The fitness for an individual is the sum of the squares of the errors
    # (expected output minus actual)
    try do
      cases
      |> Enum.map(fn {input, output} ->
        output - QuoteGP.Code.evaluate(individual, input: input)
      end)
      |> Enum.map(&(&1 * &1))
      |> Enum.sum()
    rescue
      err ->
        IO.puts("Error evaluating #{Macro.to_string(individual)}")
        IO.puts(err)
        @max_fitness
    end
  end

  def generation(population, cases) do
    evaluated = evaluate(population, cases)

    {best, best_fitness} = Enum.at(evaluated.individuals, 0)

    next =
      evaluated.individuals
      |> Enum.map(fn _ -> next_individual(evaluated) end)

    {next, Macro.to_string(best), best_fitness}
  end

  def run(population, cases) do
    run(population, cases, population.config.max_generations)
  end

  def run(population, _, 0) do
    population
  end

  def run(population = %QuoteGP.Population{}, cases, max_generations) do
    {individuals, best, best_fitness} = generation(population, cases)

    IO.puts(
      "=== Generation #{population.generation} best fitness: #{best_fitness} - individual: #{best}"
    )

    next = %{population | individuals: individuals, generation: population.generation + 1}

    if best_fitness > population.config.halt_fitness do
      run(next, cases, max_generations - 1)
    else
      IO.puts("Solution found after #{population.generation} generations")
    end
  end

  def tournament(%QuoteGP.Population{individuals: individuals, config: config}) do
    Enum.take_random(individuals, config.tournament_size)
    |> Enum.sort(fn {_, f1}, {_, f2} -> f1 < f2 end)
    |> Enum.at(0)
    |> elem(0)
  end

  def next_individual(population = %QuoteGP.Population{config: config}) do
    method = :rand.uniform()

    cond do
      method < config.crossover_rate ->
        crossover(tournament(population), tournament(population))

      method < config.mutation_rate + config.crossover_rate ->
        mutation(tournament(population), config.mutation_probability)

      true ->
        tournament(population)
    end
  end
end
