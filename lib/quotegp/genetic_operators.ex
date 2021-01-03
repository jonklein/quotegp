defmodule QuoteGP.GeneticOperators do
  def mutation(config, tree, prob) do
    size = QuoteGP.Generation.tree_points(tree) - 1
    mutations = ceil(size * prob)

    0..mutations
    |> Enum.reduce(tree, fn _, j -> mutate_point(config, j) end)
  end

  def mutate_point(config, tree) do
    index = :rand.uniform(QuoteGP.Generation.tree_points(tree)) - 1

    n = :rand.uniform()

    subtree =
      cond do
        n < 0.6 ->
          # subtree mutation
          depth =
            QuoteGP.Generation.tree_depth(QuoteGP.Generation.subtree_with_index(tree, index))

          QuoteGP.Generation.tree(config, :rand.uniform(depth))

        n < 1.0 ->
          # explicit deletion,
          QuoteGP.Generation.tree(config, 0)

        true ->
          # point mutation
          mutation(config, QuoteGP.Generation.subtree_with_index(tree, index))
      end

    QuoteGP.Generation.replace_index(tree, subtree, index)
  end

  def mutation(config, {_, _, args}) when not is_nil(args) do
    {operator, meta, arity} = Enum.random(QuoteGP.Generation.operators(config))

    new_args =
      0..(arity - 1)
      |> Enum.map(&(Enum.at(args, &1) || QuoteGP.Generation.tree(config, 0)))

    {operator, meta, new_args}
  end

  def mutation(config, _) do
    QuoteGP.Generation.tree(config, 0)
  end

  def crossover(a, b) do
    replace_index = :rand.uniform(QuoteGP.Generation.tree_points(a)) - 1
    size = QuoteGP.Generation.tree_depth(QuoteGP.Generation.subtree_with_index(a, replace_index))

    QuoteGP.Generation.replace_index(
      a,
      random_subtree(b, size),
      replace_index
    )
  end

  def random_subtree(b, max_size) do
    QuoteGP.Generation.subtree_with_index(
      b,
      :rand.uniform(QuoteGP.Generation.tree_points(b)) - 1
    )

    #    if QuoteGP.Generation.tree_depth(b) <= max_size do
    #      b
    #    else
    #      random_subtree(
    #        QuoteGP.Generation.subtree_with_index(
    #          b,
    #          :rand.uniform(QuoteGP.Generation.tree_points(b)) - 1
    #        ),
    #        max_size
    #      )
    #    end
  end
end
