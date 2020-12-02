defmodule QuoteGP.Config do
  defstruct population_size: 1000,
            max_program_depth: 10,
            mutation_probability: 0.1,
            mutation_rate: 0.3,
            crossover_rate: 0.3,
            tournament_size: 9
end
