defmodule NnnBackWeb.UserControllerTest do
  use NnnBackWeb.ConnCase

  alias NnnBack.Accounts
  alias NnnBack.Accounts.User

  @sign_up_attrs %{
    password: "some_password",
    password_confirmation: "some_password",
    username: "some username"
  }
  @invalid_sign_up_attrs %{
    password: "some_password",
    password_confirmation: "some_password_wrong",
    username: "some username"
  }

  @create_attrs %{
    password: "some_password",
    username: "some_username"
  }
  @update_attrs %{
    username: "some_updated_username"
  }
  @invalid_create_attrs %{
    password: nil,
    username: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "sign up" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :sign_up), user: @sign_up_attrs)
      assert %{"jwt" => _} = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :sign_up), user: @invalid_sign_up_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "index" do
    test "lists all user when is admin", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert length(json_response(conn, 200)["data"]) == 1
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "username" => "some_username",
               "name" => "some_name",
               "is_admin" => true
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_create_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{
      conn: conn,
      user: %User{id: id} = user
    } do
      conn =
        put(conn, Routes.user_path(conn, :update, user),
          user: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
            "id" => ^id,
            "username" => "some_username"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        put(conn, Routes.user_path(conn, :update, user),
          user: @invalid_create_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end
  end

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
