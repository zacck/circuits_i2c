defmodule Circuits.I2C.MixProject do
  use Mix.Project

  @version "0.3.5"
  @source_url "https://github.com/elixir-circuits/circuits_i2c"

  {:ok, system_version} = Version.parse(System.version())
  @elixir_version {system_version.major, system_version.minor, system_version.patch}

  def project do
    [
      app: :circuits_i2c,
      version: @version,
      elixir: "~> 1.4",
      description: description(),
      package: package(),
      source_url: @source_url,
      compilers: [:elixir_make | Mix.compilers()],
      make_targets: ["all"],
      make_clean: ["clean"],
      docs: docs(),
      aliases: [docs: ["docs", &copy_images/1], format: [&format_c/1, "format"]],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      dialyzer: [
        flags: [:unmatched_returns, :error_handling, :race_conditions, :underspecs]
      ],
      deps: deps(@elixir_version)
    ]
  end

  def application, do: []

  defp description do
    "Use I2C in Elixir"
  end

  defp package do
    %{
      files: [
        "lib",
        "src/*.[ch]",
        "src/linux/i2c-dev.h",
        "mix.exs",
        "README.md",
        "PORTING.md",
        "LICENSE",
        "CHANGELOG.md",
        "Makefile"
      ],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    }
  end

  defp deps(elixir_version) when elixir_version >= {1, 7, 0} do
    [
      {:ex_doc, "~> 0.11", only: :docs, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: :dev, runtime: false}
      | deps()
    ]
  end

  defp deps(_), do: deps()

  defp deps() do
    [
      {:elixir_make, "~> 0.6", runtime: false}
    ]
  end

  defp docs do
    [
      extras: ["README.md", "PORTING.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

  # Copy the images referenced by docs, since ex_doc doesn't do this.
  defp copy_images(_) do
    File.cp_r("assets", "doc/assets")
  end

  defp format_c([]) do
    case System.find_executable("astyle") do
      nil ->
        Mix.Shell.IO.info("Install astyle to format C code.")

      astyle ->
        System.cmd(astyle, ["-n", "src/*.c"], into: IO.stream(:stdio, :line))
    end
  end

  defp format_c(_args), do: true
end
