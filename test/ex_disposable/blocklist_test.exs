defmodule ExDisposable.BlocklistTest do
  use ExUnit.Case, async: true

  test "returns true for an exact disposable domain" do
    assert ExDisposable.Blocklist.disposable_domain?("0-mail.com")
  end

  test "returns true for a subdomain of a disposable domain" do
    assert ExDisposable.Blocklist.disposable_domain?("subdomain.0-mail.com")
  end

  test "returns false for a non-disposable domain" do
    refute ExDisposable.Blocklist.disposable_domain?("example.com")
  end

  test "returns false for invalid domains" do
    refute ExDisposable.Blocklist.disposable_domain?("bad domain")
    refute ExDisposable.Blocklist.disposable_domain?("double..dot.example")
    refute ExDisposable.Blocklist.disposable_domain?(nil)
  end
end
