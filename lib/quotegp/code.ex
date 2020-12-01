defmodule QuoteGP.Code do
  import Kernel, except: [/: 2]

  @moduledoc """
  Code operations and utilities.
  """

  @doc """
  A utility function to decompose an Elixir expression into a tuple that
  can be used as an operator in our QuoteGP system.

  {function, metadata, arity}
  """
  defmacro operator(ex) do
     {func, meta, args} = ex
     Macro.escape({func, Keyword.merge(meta, quotegp_operator: true), length(args)})
  end

  def evaluate(code, bindings) do
    Code.eval_quoted(code, bindings, functions: [{QuoteGP.Code, [/: 2]}] ++ __ENV__.functions)
  end

  @doc """
  Performs a protected divide - division with a guard for dividing by 0, such
  that n / 0 -> 0
  """
  def _ / 0 do
    0
  end

  def _ /0.0 do
    0
  end

  def x / y do
    Kernel./(x, y)
  end
end
