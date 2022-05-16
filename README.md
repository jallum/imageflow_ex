# ImageflowEx

[![Github Actions Status](https://github.com/jallum/imageflow_ex/workflows/Test%20Suite/badge.svg)](https://github.com/jallum/imageflow_ex/actions)
[![Hex pm](http://img.shields.io/hexpm/v/imageflow.svg?style=flat)](https://hex.pm/packages/imageflow)

[imageflow-github]: https://github.com/imazen/imageflow
[imageflow-json-docs]: https://docs.imageflow.io/json/introduction.html
[my-website]: https://naps62.com

Elixir bindings for [Imageflow][imageflow-github], a safe and blazing fast image workflow library.

## Installation

Add the package to your `mix.exs`:

```elixir
def deps do
  [
    {:imageflow, "~> 0.5.0"}
  ]
end
```

## Usage

There are two main ways of using `imageflow_ex`:

* [`Imageflow`](https://hexdocs.pm/imageflow/Imageflow.html), which is the high-level graph-like API, inspired by [Imageflow.NET](https://github.com/imazen/imageflow-dotnet)

You can easily create processing pipelines to process your images:

```elixir
flow =
  Imageflow.from_file(:in)          # read from a file placeholder
  |> Imageflow.constrain(200, 200)  # constrain image to 200x200
  |> Imageflow.saturation(0.5)      # set saturation to 0.5 (-1..1 range)
  |> Imageflow.to_file(:out)        # specify output file

flow
|> Imageflow.run([in: "input.png", out: "output.png"]) # run the job, defining ":in" as "input.png" and ":out" as "output.png"

flow
|> Imageflow.run([in: "other.png", out: "output.png"]) # run the job, defining ":in" as "other.png" and ":out" as "output.png"
```

## Contributing

Feel free to contribute. Either by opening an issue, a Pull Request, or contacting the
[author](mailto:mpalhas@gmail.com) directly

If you found a bug, please open an issue. You can also open a PR for bugs or new
features. PRs will be reviewed and subject to our style guide and linters.

# About

This project was developed by [Miguel Palhas](https://naps62.com), and is published
under the ISC license.
