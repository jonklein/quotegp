defmodule QuoteGP.CLI do
  def main([]) do
    IO.puts("Usage: #{:escript.script_name} config.json")
  end

  def main([file]) do
    data = Jason.decode!(File.read!(file), keys: :atoms)

    QuoteGP.Population.build(config(data.config))
    |> QuoteGP.Population.run(test_cases(data.test_cases))
  end

  defp config(json) do
    Map.merge(%QuoteGP.Config{}, json)
  end

  defp test_cases(json) do
    Enum.map(json, fn [x, y] -> {x,y} end)
  end
end