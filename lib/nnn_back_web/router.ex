defmodule NnnBackWeb.Router do
  use NnnBackWeb, :router

  alias NnnBack.Guardian

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :secure do
    plug Guardian.AuthPipeline
  end

  scope "/api/v1", NnnBackWeb do
    pipe_through :api

    post "/sign_up", UserController, :sign_up
    post "/sign_in", UserController, :sign_in
  end


  scope "/api/v1", NnnBackWeb do
    pipe_through [:api, :secure]

    get "/my_user", UserController, :my_user
  end
end
