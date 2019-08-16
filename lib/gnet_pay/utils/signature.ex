defmodule GnetPay.Utils.Signature do
  @moduledoc """
  Module to sign data
  """
  require Logger
  alias GnetPay.Client
  alias GnetPay.PayParam
  alias GnetPay.RefundParam

  @doc """
  Generate the signature of data with API key

  ## Example

  ```elixir
  iex> GnetPay.Utils.Signature.sign_pay(%PayParam{}, client)
  ...> "02696FC7E3E19F852A0335F2F007DD3E"
  ```
  """
  @spec sign_pay(PayParam.t(), Client.t()) :: String.t()
  def sign_pay(
        %PayParam{} = data,
        %Client{} = client
      ) do
    msg =
      "#{client.mch_id}#{data.order_no}#{data.order_amount}#{data.curr_code}#{data.order_type}#{
        data.call_back_url
      }#{data.bank_code}#{data.lang_type}#{data.buz_type}#{data.reserved01}#{data.reserved02}"

    Logger.info("to sign string: #{msg}")
    generate_sign_string(msg, client)
  end

  @spec sign_refund(RefundParam.t(), Client.t()) :: String.t()
  def sign_refund(%RefundParam{} = data, client) do
    msg =
      Map.from_struct(data)
      |> Map.merge(%{mer_id: client.mch_id})
      |> Enum.map(fn {k, v} -> "#{Macro.camelize(k)}=#{v}" end)
      |> Enum.join("&")

    Logger.info("to sign refund string: #{msg}")
    generate_sign_string(msg, client, true)
  end

  @spec sign(String.t(), Client.t()) :: String.t()
  def sign(data, client) when is_binary(data) do
    generate_sign_string(data, client)
  end

  defp generate_sign_string(data, client, is_refund \\ false) do
    encode_pkey = :crypto.hash(:md5, client.p_key) |> Base.encode16(case: :lower)
    Logger.info("encode_pkey: #{encode_pkey}")

    encode_msg = if is_refund == true, do: data <> "&" <> encode_pkey, else: data <> encode_pkey

    Logger.info("encode_msg: #{encode_msg}")
    :crypto.hash(:md5, encode_msg) |> Base.encode16(case: :lower)
  end
end
