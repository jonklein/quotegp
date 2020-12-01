defmodule QuoteGP.GeneticOperators do
  def mutation(tree = {operator, meta, args}, prob) do
    case :rand.uniform() < prob do
      true -> QuoteGP.Generation.code_tree(QuoteGP.Generation.tree_depth(tree))
      false -> {operator, meta, arguments(args, prob)}
    end
  end

  def mutation(terminal, prob) do
    case :rand.uniform() < prob do
      true -> QuoteGP.Generation.code_tree(0)
      false -> terminal
    end
  end

  defp arguments(args, prob) when is_list(args) do
    Enum.map(args, fn a -> mutation(a, prob) end)
  end

  defp arguments(args, _) do
    args
  end

  def crossover(a, b) do
    subtree =
      QuoteGP.Generation.subtree_with_index(b, :rand.uniform(QuoteGP.Generation.tree_points(b)) - 1)

    QuoteGP.Generation.replace_index(a, subtree, :rand.uniform(QuoteGP.Generation.tree_points(a)) - 1)
  end
end
