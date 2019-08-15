defmodule GnetPay.PayParam do
  @type t :: %__MODULE__{
          order_no: String.t(),
          order_amount: Float.t(),
          curr_code: String.t(),
          call_back_url: String.t(),
          order_type: String.t(),
          bank_code: String.t(),
          buz_type: String.t(),
          lang_type: String.t(),
          reserved01: String.t(),
          reserved02: String.t(),
          mer_id: String.t()
        }
  defstruct order_no: nil,
            order_amount: nil,
            curr_code: "CNY",
            call_back_url: nil,
            order_type: "B2C",
            bank_code: "88988888",
            buz_type: "01",
            lang_type: "UTF-8",
            reserved01: nil,
            reserved02: nil,
            mer_id: nil
end
