defmodule ExDisposableTest do
  use ExUnit.Case
  doctest ExDisposable

  test "returns true for a blocked domain" do
    assert ExDisposable.disposable?("person@0-mail.com")
  end

  test "normalizes email input before checking the blocklist" do
    assert ExDisposable.disposable?(" PERSON@0-MAIL.COM ")
  end

  test "treats subdomains of blocked domains as disposable" do
    assert ExDisposable.disposable?("person@subdomain.0-mail.com")
  end

  test "returns false for a non-disposable email address" do
    refute ExDisposable.disposable?("person@example.com")
  end

  test "returns false for invalid input" do
    refute ExDisposable.disposable?("not-an-email")
    refute ExDisposable.disposable?(nil)
  end
end
