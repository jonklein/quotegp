defmodule QuoteGP do
  @moduledoc """
  Documentation for `Quotegp`.
  """

  def start_link() do
    :world |> IO.inspect
  end

  @doc """
  Hello world.

  ## Examples

      iex> QuoteGP.hello()
      :world

  """
  def hello do
    :world |> IO.inspect
  end

  defmacro test do
    quote do: 1 + 1
  end
end
