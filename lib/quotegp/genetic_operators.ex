defmodule QuoteGP.GeneticOperators do
  def code_tree(0) do
    terminal()
  end

  def code_tree(max_depth) do
    {operator, meta, arity} = Enum.random(operators())
    List.to_tuple([ operator, meta, operands(arity, max_depth - 1) ])
  end

  def operands(0, _) do
    []
  end

  def operands(0, _) do
    []
  end


  def operands(arity, max_depth) do
    [code_tree(rand(max_depth)) | operands(arity - 1, max_depth)]
  end

  def terminal do
    1
  end

  def operators do
    [{:+, [context: Elixir, import: Kernel], 2}, {:-, [context: Elixir, import: Kernel], 2}, {{:., [],
      [
        {:__aliases__, [alias: false], [:QuoteGP, :GeneticOperators]},
        :protected_divide
      ]}, [context: Elixir, import: Kernel], 2}, {:*, [context: Elixir, import: Kernel], 2}]
  end

  def rand(0) do
    0
  end

  def rand(i) do
    :rand.uniform(i)
  end

  def protected_divide(x, 0) do
    0
  end

  def protected_divide(x, 0.0) do
    0
  end

  def protected_divide(x, y) do
    x / y
  end

end
