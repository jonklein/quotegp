defmodule QuoteGP.Config do
  defstruct population_size: 1000,
            max_generations: 100,
            max_program_depth: 15,
            mutation_probability: 0.4,
            halt_fitness: 0.0,
            mutation_rate: 0.3,
            crossover_rate: 0.5,
            random_rate: 0.1,
            random_constant_range: 10,
            tournament_size: 9,
            operators: [
              "n + n",
              "n - n",
              "n * n",
              "n / n"
            ]
end
