defmodule NtucPriceIsRight.Repo do
  use Ecto.Repo,
    otp_app: :ntuc_price_is_right,
    adapter: Ecto.Adapters.SQLite3
end
