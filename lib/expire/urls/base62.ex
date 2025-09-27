defmodule Expire.Urls.Base62 do
  @chars ~c"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  def encode(int) when is_integer(int) and int >= 0 do
    do_encode(int, [])
    |> to_string()
  end

  defp do_encode(0, []), do: "0"
  defp do_encode(0, acc), do: acc

  defp do_encode(int, acc) do
    rem = rem(int, 62)
    do_encode(div(int, 62), [Enum.at(@chars, rem) | acc])
  end
end
