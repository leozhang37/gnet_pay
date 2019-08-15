defmodule GnetPay.RefundParam do
  @type t :: %__MODULE__{
          tran_type: String.t(),
          pay_amount: Float.t(),
          java_charSet: String.t(),
          version: String.t(),
          refund_no: String.t(),
          order_no: String.t(),
          shopping_date: String.t(),
          refund_amount: Float.t(),
          reserved: String.t(),
          mer_id: String.t()
        }
  defstruct tran_type: nil,
            java_charSet: "UTF-8",
            version: "V36",
            refund_no: nil,
            mer_id: nil,
            order_no: nil,
            shopping_date: nil,
            pay_amount: nil,
            refund_amount: nil,
            reserved: nil
end
