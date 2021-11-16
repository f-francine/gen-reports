defmodule GenReport.CSVParser do
  @moduledoc """
  Parses a CSV file, transforming each line of the file into a list.
  """

@doc """
Paerses a given csv file into a list.
"""
  @spec execute(file_name :: String.t()) :: Stream.t()
  def execute(file_name) do
    "reports/#{file_name}"
    |> File.stream!()
    |> Stream.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.trim()
    |> String.split(",")
    |> List.update_at(1, &String.to_integer/1)
  end
end
