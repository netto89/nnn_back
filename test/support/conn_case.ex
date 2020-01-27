defmodule NnnBackWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use NnnBackWeb.ConnCase, async: true`, although
  this option is not recommendded for other databases.
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox
  alias NnnBack.Accounts
  alias NnnBack.Guardian
  alias NnnBack.Repo
  alias Phoenix.ConnTest
  alias Plug.Conn

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      alias NnnBackWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint NnnBackWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(NnnBack.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(NnnBack.Repo, {:shared, self()})
    end

    if tags[:authenticated] do
      {:ok, user} =
        Accounts.create_user(%{
          username: "user",
          password: "password"
        })

      {:ok, token, _claims} = Guardian.encode_and_sign(user)

      conn =
        ConnTest.build_conn()
        |> Conn.put_req_header("authorization", "Bearer #{token}")

      {:ok, conn: conn}
    else
      {:ok, conn: ConnTest.build_conn()}
    end
  end
end
