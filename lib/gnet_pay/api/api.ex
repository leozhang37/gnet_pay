defmodule GnetPay.Api do
  alias GnetPay.Utils.Signature
  alias GnetPay.PayParam
  alias GnetPay.RefundParam
  alias GnetPay.Error
  alias GnetPay.Client
  alias GnetPay.HttpClient
  require Logger

  @spec generate_pay_request(Client.t(), PayParam.t()) :: String.t()
  def generate_pay_request(client, %PayParam{} = attrs) do
    sign_string = Signature.sign_pay(attrs, client)

    request_data =
      Map.from_struct(attrs)
      |> Map.merge(%{mer_id: client.mch_id, sign_msg: sign_string})
      |> Enum.map(fn {k, v} -> %{Macro.camelize(Atom.to_string(k)) => v} end)

    path = client.api_host |> URI.merge("api/PayV36") |> to_string()
    %{url: path, param: request_data}
  end

  @spec refund(Client.t(), RefundParam.t()) ::
          {:ok, map} | {:error, Error.t() | HTTPoison.Error.t()}
  def refund(client, %RefundParam{} = attrs, options \\ []) do
    request_data =
      Map.from_struct(attrs)
      |> Map.merge(%{mer_id: client.mch_id})
      |> Enum.map(fn {k, v} ->
        "#{Macro.camelize(Atom.to_string(k))}=#{
          if is_binary(v), do: URI.encode_www_form(v), else: v
        }"
      end)
      |> Enum.join("&")

    sign_string = Signature.sign_refund(attrs, client)

    form_data = request_data <> "&SignMsg=" <> sign_string
    Logger.info("[GnetPay] generate_pay_request: #{form_data}")

    with {:ok, data} <- HttpClient.post(client, "Trans.action", form_data, options) do
      {:ok, data}
    end
  end

  @spec query_pay(Client.t(), String.t(), NaiveDateTime.t()) ::
          {:ok, String.t()} | {:error, Error.t() | HTTPoison.Error.t()}
  def query_pay(client, pay_id, %NaiveDateTime{} = shopping_time) do
    begin_time =
      shopping_time
      |> NaiveDateTime.add(-3600, :second)
      |> NaiveDateTime.truncate(:second)

    end_time =
      shopping_time
      |> NaiveDateTime.add(3600, :second)
      |> NaiveDateTime.truncate(:second)

    query_pay(client, begin_time, end_time, pay_id)
  end

  @spec query_pay(Client.t(), NaiveDateTime.t(), NaiveDateTime.t(), String.t()) ::
          {:ok, String.t()} | {:error, Error.t() | HTTPoison.Error.t()}
  def query_pay(
        client,
        %NaiveDateTime{} = begin_time,
        %NaiveDateTime{} = end_time,
        pay_id,
        options \\ []
      ) do
    form_data =
      "TranType=#{URI.encode_www_form("100")}&JavaCharset=#{URI.encode_www_form("UTF-8")}&Version=#{
        URI.encode_www_form("V60")
      }&UserId=#{URI.encode_www_form(client.user_name)}&Pwd=#{
        URI.encode_www_form(client.password)
      }&MerId=#{URI.encode_www_form(client.mch_id)}&PayStatus=#{URI.encode_www_form("1")}&BeginTime=#{
        URI.encode_www_form(begin_time |> NaiveDateTime.to_string())
      }&EndTime=#{URI.encode_www_form(end_time |> NaiveDateTime.to_string())}"

    form_data =
      if is_nil(pay_id) do
        form_data
      else
        form_data <> "&OrderNo=#{URI.encode_www_form(pay_id)}"
      end

    with {:ok, data} <- HttpClient.post(client, "Trans.action", form_data, options) do
      {:ok, data}
    end
  end

  @spec query_refund(Client.t(), String.t() | Integer.t(), String.t() | Integer.t(), String.t()) ::
          {:ok, String.t()} | {:error, Error.t() | HTTPoison.Error.t()}
  def query_refund(client, pay_id, refund_id, shopping_date, options \\ []) do
    form_data =
      "TranType=#{URI.encode_www_form("101")}&JavaCharset=#{URI.encode_www_form("UTF-8")}&Version=#{
        URI.encode_www_form("V60")
      }&UserId=#{URI.encode_www_form(client.user_name)}&Pwd=#{
        URI.encode_www_form(client.password)
      }&MerId=#{URI.encode_www_form(client.mch_id)}&OrderNo=#{URI.encode_www_form(pay_id)}&RefundNo=#{
        URI.encode_www_form(refund_id)
      }&ShoppingDate=#{URI.encode_www_form(shopping_date)}"

    with {:ok, data} <- HttpClient.post(client, "Trans.action", form_data, options) do
      {:ok, data}
    end
  end
end
