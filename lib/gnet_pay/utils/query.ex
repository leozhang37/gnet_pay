defmodule GnetPay.Utils.Query do
  def decode(query, initial \\ %{})

  def decode("", initial) do
    initial
  end

  def decode(query, initial) do
    parts = :binary.split(query, "&", [:global])

    Enum.reduce(Enum.reverse(parts), initial, &decode_www_pair(&1, &2))
  end

  defp decode_www_pair("", acc) do
    acc
  end

  defp decode_www_pair(binary, acc) do
    current =
      case :binary.split(binary, "=") do
        [key, value] ->
          {key, value}

        [key] ->
          {key, nil}
      end

    decode_pair(current, acc)
  end

  def decode_pair({key, value}, acc) do
    if key != "" and :binary.last(key) == ?] do
      # Remove trailing ]
      subkey = :binary.part(key, 0, byte_size(key) - 1)

      # Split the first [ then we will split on remaining ][.
      #
      #     users[address][street #=> [ "users", "address][street" ]
      #
      assign_split(:binary.split(subkey, "["), value, acc, :binary.compile_pattern("]["))
    else
      assign_map(acc, key, value)
    end
  end

  defp assign_split(["", rest], value, acc, pattern) do
    parts = :binary.split(rest, pattern)

    case acc do
      [_ | _] -> [assign_split(parts, value, :none, pattern) | acc]
      :none -> [assign_split(parts, value, :none, pattern)]
      _ -> acc
    end
  end

  defp assign_split([key, rest], value, acc, pattern) do
    parts = :binary.split(rest, pattern)

    case acc do
      %{^key => current} ->
        Map.put(acc, key, assign_split(parts, value, current, pattern))

      %{} ->
        Map.put(acc, key, assign_split(parts, value, :none, pattern))

      _ ->
        %{key => assign_split(parts, value, :none, pattern)}
    end
  end

  defp assign_split([""], nil, acc, _pattern) do
    case acc do
      [_ | _] -> acc
      _ -> []
    end
  end

  defp assign_split([""], value, acc, _pattern) do
    case acc do
      [_ | _] -> [value | acc]
      :none -> [value]
      _ -> acc
    end
  end

  defp assign_split([key], value, acc, _pattern) do
    assign_map(acc, key, value)
  end

  defp assign_map(acc, key, value) do
    case acc do
      %{^key => _} -> acc
      %{} -> Map.put(acc, key, value)
      _ -> %{key => value}
    end
  end
end
