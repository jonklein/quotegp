# QuoteGP - genetic programming with native Elixir code 

A genetic programming system that uses Elixir AST as a program representation and can evolve native Elixir language 
solutions to problems. 

This is currently at a proof-of-concept level of maturity.

## Getting Started & Samples

There are a couple of simple sample problems included in this repo, in the 
`samples` subdirectory.  The problems here are "symbolic regression" curve fitting 
problems, in which the GP system attempts to evolve code which maps a series of 
numerical inputs to the provided outputs.

These samples are "toy" problems - they are intended to be solvable but slightly 
challenging in order to test the GP system and demonstrate how it works.

To run via the command-line, you can use the included escript:

```
mix escript.build
./quotegp ./samples/sample1.json
```

To run via code:

```
# Generate some test data:
test_cases = 8..16 |> Enum.map(fn x -> {x, x * x + 3 * x + 8} end)

# Configure and run:
config = %QuoteGP.Config{}

QuoteGP.Population.build(config)
  |> QuoteGP.Population.run(test_cases)
```

For more advanced usage, configure a GP run with the following options (shown with defaults):

```
%QuoteGP.Config{
    population_size: 1000,
    max_generations: 100,
    max_program_depth: 10,
    mutation_probability: 0.1,
    halt_fitness: 0.0,
    mutation_rate: 0.3,
    crossover_rate: 0.3,
    tournament_size: 9
}
```

- halt_fitness: a fitness at which execution will halt
- max_generations: the maximum number of generations to run if a solution is not found
- population_size: the number of individuals in the evolving population
- max_program_depth: the maximum depth of a program in the population
- mutation_probability: 0.1,
- mutation_rate: 0.3,
- crossover_rate: 0.3, 
- tournament_size: the number of individuals in a "tournament" selection event 

