defmodule ExDisposable.Ecto.ChangesetTest do
  use ExUnit.Case, async: true

  import ExDisposable.Ecto.Changeset

  test "adds an error when the email uses a disposable domain" do
    changeset =
      {%{}, %{email: :string}}
      |> Ecto.Changeset.cast(%{email: "person@0-mail.com"}, [:email])
      |> validate_not_disposable_email(:email)

    assert changeset.errors == [email: {"uses a disposable email domain", []}]
  end

  test "supports a custom validation message" do
    changeset =
      {%{}, %{email: :string}}
      |> Ecto.Changeset.cast(%{email: "person@0-mail.com"}, [:email])
      |> validate_not_disposable_email(:email, message: "must not use a disposable inbox")

    assert changeset.errors == [email: {"must not use a disposable inbox", []}]
  end

  test "does not add an error for non-disposable or invalid email addresses" do
    accepted_changeset =
      {%{}, %{email: :string}}
      |> Ecto.Changeset.cast(%{email: "person@example.com"}, [:email])
      |> validate_not_disposable_email(:email)

    invalid_email_changeset =
      {%{}, %{email: :string}}
      |> Ecto.Changeset.cast(%{email: "not-an-email"}, [:email])
      |> validate_not_disposable_email(:email)

    assert accepted_changeset.errors == []
    assert invalid_email_changeset.errors == []
  end
end
