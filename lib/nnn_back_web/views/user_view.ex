defmodule NnnBackWeb.UserView do
  use NnnBackWeb, :view
  alias NnnBackWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      username: user.username,
      password: user.password}
  end

  def render("jwt.json", %{jwt: jwt, user: user}) do
    %{jwt: jwt, username: user.username}
  end
end
