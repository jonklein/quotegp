defmodule QuoteGP.Generation do
  require QuoteGP.Code
  import QuoteGP.Code

  def code_tree(%QuoteGP.Config{max_program_depth: max_depth}) do
    tree(max_depth)
  end

  def tree(max_depth) when max_depth <= 1 do
    terminal()
  end

  def tree(max_depth) do
    {operator, meta, arity} = Enum.random(operators())

    List.to_tuple([operator, meta, Enum.map(1..arity, fn _ -> tree(rand(max_depth) - 1) end)])
  end

  @doc """
  The depth of the code tree, counting all operators.
  """
  def tree_depth({_, _, args}) when is_list(args) do
    1 + Enum.max(Enum.map(args, fn a -> tree_depth(a) end))
  end

  def tree_depth(_) do
    1
  end

  @doc """
  The number of "points" or nodes (operators and terminals) in the code tree
  """
  def tree_points({_, _, args}) when is_list(args) do
    1 + Enum.sum(Enum.map(args, fn a -> tree_points(a) end))
  end

  def tree_points(_) do
    1
  end

  def replace_index([first], subtree, idx) do
    [replace_index(first, subtree, idx)]
  end

  def replace_index([first | rest], subtree, idx) do
    [replace_index(first, subtree, idx) | replace_index(rest, subtree, idx - tree_points(first))]
  end

  def replace_index(_, subtree, 0) do
    subtree
  end

  def replace_index({op, meta, args}, subtree, idx) when is_list(args) do
    {op, meta, replace_index(args, subtree, idx - 1)}
  end

  def replace_index(tree, _, _) do
    tree
  end

  def subtree_with_index([first | rest], idx) do
    subtree_with_index(first, idx) || subtree_with_index(rest, idx - tree_points(first))
  end

  def subtree_with_index([], _) do
    nil
  end

  def subtree_with_index(tree, 0) do
    tree
  end

  def subtree_with_index({_, _, args}, idx) do
    subtree_with_index(args, idx - 1)
  end

  def subtree_with_index(_, _) do
    nil
  end

  def terminal do
    if(:rand.uniform() < 0.1, do: Code.string_to_quoted!("input"), else: :rand.uniform(20) - 10)
  end

  @doc """
  Defines the basic operators that the GP can use.

  We use the operator macro here to generate an AST chunk for a given expression.
  Arguments to the expression function are replaced by terminals, so are just
  placeholders in this usafe.
  """
  def operators do
    [
      operator(n + n),
      operator(n - n),
      operator(n * n),
      operator(n / n)
    ]
  end


  defp rand(i) do
    :rand.uniform(i + 1) - 1
  end
end
