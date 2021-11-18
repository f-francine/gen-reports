defmodule GenReport do
  @moduledoc """
  Generates a report, grouped by all_hours, hours_per_month and hours_per_year a given employee had worked.

  The report will be generated following this model:
    %{
      "all_hours" => %{
        "Amy" => 13_797,
        "Jake" => 13_264
      },
      "hours_per_month" => %{
        "Amy" => %{
          "april" => 1161,
          "may" => 1149,
        },
        "Jake" => %{
          "april" => 1160,
          "may" => 1150,
        }
      },
      "hours_per_year" => %{
        "Amy" => %{
          "2016" => 2699,
          "2017" => 2684
        },
        "Jake" => %{
          "2016" => 2698,
          "2017" => 2685
        }
      }
    }
  """

  alias GenReport.CSVParser

  @parsed_month %{
    "1" => "january",
    "2" => "februery",
    "3" => "march",
    "4" => "april",
    "5" => "may",
    "6" => "june",
    "7" => "jully",
    "8" => "august",
    "9" => "september",
    "10" => "october",
    "11" => "november",
    "12" => "december"
  }

  def execute(file_names) when is_list(file_names) do
    file_names
    |> Task.async_stream(&execute/1)
  end

  @doc """
  Generates a report for a given csv file.
  """
  @spec execute(file_name :: String.t()) :: map()
  def execute(file_name) do
    file_name
    |> CSVParser.execute()
    |> build_response()
  end

  def execute(), do: {:error, :no_file_was_given}

  defp build_response(line) do
    %{
      "all_hours" => total_hours(line),
      "hours_per_month" => hours_per_month(line),
      "hours_per_year" => hours_per_year(line)
    }
  end

  defp total_hours(line) do
    Enum.reduce(line, %{}, fn [name, hours_per_day, _day, _month, _year], acc ->
      sum_values(acc, name, hours_per_day)
    end)
  end

  defp hours_per_month(line) do
    Enum.reduce(line, %{}, fn [name, hours_per_day, _day, month, _year], acc ->
      sum_values_nested(acc, name, @parsed_month[month], hours_per_day)
    end)
  end

  defp hours_per_year(line) do
    Enum.reduce(line, %{}, fn [name, hours_per_day, _day, _month, year], acc ->
      sum_values_nested(acc, name, year, hours_per_day)
    end)
  end

  defp sum_values(map, key, value) do
    if Map.has_key?(map, key) do
      Map.put(map, key, map[key] + value)
    else
      Map.put(map, key, value)
    end
  end

  defp sum_values_nested(map, key1, key2, value) do
    with {:step1, true} <- {:step1, Map.has_key?(map, key1)},
         {:step2, true} <- {:step2, Map.has_key?(map[key1], key2)} do
      put_in(map, [key1, key2], map[key1][key2] + value)
    else
      {:step1, false} ->
        Map.put(map, key1, %{key2 => value})

      {:step2, false} ->
        put_in(map, [key1, key2], value)
    end
  end

  defp merge_response(%{"all_hours" => all_hours}, acc, :all_hours) do
    Enum.merge(all_hours, acc, fn _key, value1, value2 -> value1 + value2 end)
  end

  defp merge_response(%{"hours_per_month" => all_hours}, acc, :hours_per_month) do
    Enum.merge(all_hours, acc, fn _key, value1, value2 -> value1 + value2 end)
  end

  defp merge_response(%{"hours_per_year" => all_hours}, acc, :hours_per_year) do
    Enum.merge(all_hours, acc, fn _key, value1, value2 -> value1 + value2 end)
  end

  defp merge_all(all_hours, hours_per_month, hours_per_year) do
    all_hours
    |> Map.merge(hours_per_month)
    |> Map.merge(hours_per_year)
  end
end
