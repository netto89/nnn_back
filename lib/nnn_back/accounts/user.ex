defmodule NnnBack.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  schema "users" do
    field :username, :string
    field :password_hash, :string

    # Virtual fields:
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end
  
  @doc false
  def sign_up_changeset(user, attrs) do
    user
    # Remove hash, add pw + pw confirmation
    |> cast(attrs, [:username, :password, :password_confirmation])
    # Remove hash, add pw + pw confirmation
    |> validate_required([:username, :password, :password_confirmation])
    # |> validate_length(:password, min: 8) # Check that password length is >= 8
    # Check that password === password_confirmation
    |> validate_confirmation(:password)
    |> unique_constraint(:username)
    # Add put_password_hash to changeset pipeline
    |> put_password_hash
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :password])
    |> validate_required([:name, :password])
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, hashpwsalt(pass))

      _ ->
        changeset
    end
  end
end
