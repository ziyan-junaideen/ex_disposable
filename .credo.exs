%{
  configs: [
    %{
      name: "default",
      strict: true,
      files: %{
        included: ["mix.exs", "lib/", "test/"],
        excluded: [~r"/_build/", ~r"/deps/"]
      }
    }
  ]
}
