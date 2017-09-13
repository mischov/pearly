defmodule Pearly do
  @moduledoc """
  > Pearly Soames wanted gold and silver, but not, in the way of common
  > thieves, for wealth. He wanted them because they shone and were pure.
  > Strange, afflicted, and deformed, he sought a cure in the abstract
  > relation of colors.
  > -- <cite>Mark Helprin, *Winter's Tale*</cite>

  Pearly is an Elixir library for syntax highlighting using Sublime Text
  syntax definitions.

  ```elixir
  Pearly.highlight("html", "<h1>Hello, World!</h1>",
    format: :html,
    theme: "Solarized (dark)")
  #=> {:ok, "<pre style=\"background-color:#002b36;\">\\n<span style=..."}
  ```

  Pearly currently supports formatting output for either HTML pages or the
  terminal.

  ## Dependencies

  Pearly depends on the Rust library
  [Syntect](https://github.com/trishume/syntect), and you will need to have
  the Rust compiler [installed](https://www.rust-lang.org/en-US/install.html).

  Additionally, one of Syntect's dependencies (Onig) requires cmake to be
  installed.
  """

  @type lang :: String.t
  @type source :: String.t
  @type format :: :html | :terminal
  @type opt :: {:format, format} | {:theme, String.t}
  @type error :: {:error, String.t}

  @doc """
  Returns a string of `source` highlighted according to `lang`, where `lang`
  may be a language extension or name. The `:format` and `:theme` of the
  output may optionally be provided, defaulting to `:html` and
  `"Solarized (dark)"` respectively.

  If `lang` is unknown, returns `source` unmodified.

  ## Options

    * `:format` - Specifies the format of output. Currently supports either
      `:html` or `:terminal`. Defaults to `:html`.
    * `:theme` - Specifies which them is used when highlighting. Defaults to
       `"Solarized (dark)"` and currently supports:
         * `"Solarized (light)"`
         * `"Solarized (dark)"`
         * `"base16-ocean.light"`
         * `"base16-ocean.dark"`
         * `"base16-mocha.dark"`
         * `"base16-eighties.dark"`
         * `"InspiredGitHub"`

  ## Examples

      iex> Pearly.highlight("html", "<br>", format: :terminal)
      {:ok, "\\e[48;2;0;43;54m\\e[38;2;88;110;117m<\\e[48;2;0;43;54m\\e[38;2;38;139;210mbr\\e[48;2;0;43;54m\\e[38;2;88;110;117m>"}
  """
  @spec highlight(lang, source, [opt]) :: {:ok, String.t} | error
  def highlight(lang, source, opts \\ []) do
    theme = Keyword.get(opts, :theme, "Solarized (dark)")
    format = Keyword.get(opts, :format, :html)
    Pearly.Native.highlight(format, lang, theme, source)
    receive do
      {:pearly_nif_result, :ok, result} ->
        {:ok, result}
      {:pearly_nif_result, :error, err} ->
        {:error, err}
    end
  end
end
