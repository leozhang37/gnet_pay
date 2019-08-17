defmodule GnetPay.HttpClient do
  alias GnetPay.JSON
  alias GnetPay.Error
  require Logger
  require JSON

  def post(client, path, attrs, options) do
    path = client.api_host |> URI.merge(path) |> to_string()
    Logger.debug("url: #{path}")

    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"},
      {"Accept", "text/html"},
      {"Accept-Charset", "UTF-8"},
      {"cache-control", "no-cache"}
    ]

    Logger.info("[HTTPoison] request body: #{attrs}")

    with {:ok, response} <- HTTPoison.post(path, attrs, headers, options),
         {:ok, response_data} <- process_response(response),
         {:ok, data} <- process_result_field(response_data) do
      Logger.info("#{inspect(data)}")
      {:ok, data}
    end
  end

  defp process_refund_response(response) do
    {:ok, GnetPay.Utils.Query.decode(response)}
  end

  defp process_query_response(response) do
    {:ok, response}
  end

  defp process_response(%HTTPoison.Response{status_code: 200, body: body}) do
    if Regex.match?(~r/Code=/, body) do
      process_refund_response(body)
    else
      process_query_response(body)
    end
  end

  defp process_response(%HTTPoison.Response{status_code: 201, body: body}) do
    {:error, %Error{reason: body, type: :unprocessable_entity}}
  end

  defp process_response(%HTTPoison.Response{status_code: 404, body: _body}) do
    {:error, %Error{reason: "The endpoint is not found", type: :not_found}}
  end

  defp process_response(%HTTPoison.Response{status_code: 502, body: _body}) do
    {:error, %Error{reason: "银联网关错误502", type: :unknown_response}}
  end

  defp process_response(%HTTPoison.Response{body: body} = response) do
    Logger.debug("#{inspect(response)}")
    {:error, %Error{reason: body, type: :unknown_response}}
  end

  defp process_result_field(%{"Code" => "0000"} = data) do
    {:ok, data}
  end

  defp process_result_field(%{"Code" => err_code, "Message" => err_info}) do
    {:error, %Error{reason: "Code: #{err_code}, msg: #{err_info}", type: :failed_result}}
  end

  defp process_result_field(data) when is_binary(data) do
    {:ok, data}
  end
end
