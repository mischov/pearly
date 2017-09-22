# Pearly

[![Build Status](https://travis-ci.org/mischov/pearly.svg?branch=master)](https://travis-ci.org/mischov/pearly)
[![Pearly version](https://img.shields.io/hexpm/v/pearly.svg)](https://hex.pm/packages/pearly)

> Pearly Soames wanted gold and silver, but not, in the way of common thieves, for wealth. He wanted them because they shone and were pure. Strange, afflicted, and deformed, he sought a cure in the abstract relation of colors.
> -- <cite>Mark Helprin, *Winter's Tale*</cite>

Pearly is an Elixir library for syntax highlighting using Sublime Text syntax definitions.

```elixir
Pearly.highlight("html", "<h1>Hello, World!</h1>",
  format: :html,
  theme: "Solarized (dark)")
#=> {:ok, "<pre style=\"background-color:#002b36;\">\n<span style=..."}
```

Pearly currently supports formatting output for either HTML pages or the terminal.

See [HexDocs](https://hexdocs.pm/pearly/Pearly.html) for additional documentation.

## Dependencies

Pearly depends on the Rust library [Syntect](https://github.com/trishume/syntect), and you will need to have the Rust compiler [installed](https://www.rust-lang.org/en-US/install.html).

Additionally, one of Syntect's dependencies (onig) requires cmake to be installed.

## Installation

Ensure Rust and cmake are installed, then add Pearly to your `mix.exs`:

```elixir
defp deps do
  [
    {:pearly, "~> 0.1.0"}
  ]
end
```

Finally, run `mix deps.get`.

## Roadmap

  - [x] Highlight for HTML pages (styled `<pre>` tags)
  - [x] Highlight for the terminal (24-bit color ANSI terminal escape sequences)
  - [x] Provide Elixir and EEx syntaxes
  - [ ] Support providing additional syntaxes
  - [ ] Support providing additional themes
  - [ ] Support additional and/or custom formatters

## License

Pearly is licensed under the [MIT License](LICENSE)
