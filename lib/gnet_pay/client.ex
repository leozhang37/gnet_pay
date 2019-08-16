defmodule GnetPay.Client do
  @moduledoc """
   API Client
  """
  alias GnetPay.Client

  @enforce_keys [:p_key, :mch_id, :user_name, :password]
  defstruct api_host: "https://www.gnetpg.com/GneteMerchantAPI/",
            mch_id: nil,
            p_key: nil,
            user_name: nil,
            password: nil,
            is_prod: true,
            openid: ""

  @type t :: %Client{
          api_host: String.t(),
          mch_id: String.t(),
          p_key: String.t(),
          user_name: String.t(),
          password: String.t(),
          is_prod: Boolean.t(),
          openid: String.t()
        }

  @spec new(Enum.t()) :: {:ok, Client.t()} | {:error, binary()}
  def new(opts) do
    attrs = Enum.into(opts, %{})

    with :ok <- validate_opts(attrs),
         client = struct(Client, attrs) do
      {:ok, client}
    end
  end

  @enforce_keys
  |> Enum.each(fn key ->
    defp unquote(:"validate_#{key}")(%{unquote(key) => value}) when not is_nil(value) do
      :ok
    end

    defp unquote(:"validate_#{key}")(_) do
      {:error, "please set `#{unquote(key)}`"}
    end
  end)

  defp validate_opts(attrs) when is_map(attrs) do
    with :ok <- validate_mch_id(attrs),
         :ok <- validate_p_key(attrs),
         :ok <- validate_user_name(attrs),
         :ok <- validate_password(attrs) do
      :ok
    end
  end
end
