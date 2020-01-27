defmodule NnnBackWeb.UserController do
  use NnnBackWeb, :controller

  alias NnnBack.Accounts
  alias NnnBack.Accounts.User
  alias NnnBack.Guardian

  action_fallback NnnBackWeb.FallbackController

  def sign_in(conn, %{"username" => username, "password" => password}) do
    case Accounts.token_sign_in(username, password) do
      {:ok, user, token} ->
        conn |> render("jwt.json", jwt: token, user: user)
      _ ->
        {:error, :unauthorized}
    end
  end

  def sign_up(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.sign_up(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      render(conn, "jwt.json", jwt: token, user: user)
    end
  end

  def my_user(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    conn |> render("user.json", user: user)
  end
  
  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
