defmodule GnetPay.RevertParam do
  @type t :: %__MODULE__{
          tran_type: String.t(),
          java_charset: String.t(),
          version: String.t(),
		  mer_id: String.t(),  
          order_no: String.t(),
          shopping_date: String.t(),
          reserved: String.t()
          
        }
  defstruct tran_type: "32",
            java_charset: "UTF-8",
            version: "V36",
            mer_id: nil,
            order_no: nil,
            shopping_date: nil,
            reserved: nil
end
