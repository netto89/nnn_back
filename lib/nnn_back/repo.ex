defmodule NnnBack.Repo do
  use Ecto.Repo,
    otp_app: :nnn_back,
    adapter: Ecto.Adapters.Postgres
end
