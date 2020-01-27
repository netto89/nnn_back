defmodule NnnBack.Guardian.AuthPipeline do
  @moduledoc """
    Verify users
  """
  use Guardian.Plug.Pipeline,
    otp_app: :nnn_back,
    module: NnnBack.Guardian,
    error_handler: NnnBack.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
