<p align="center">
  <img height="256" alt="vitepressify, a green rectangle behind a black rectangle that has the markdown logo on top in white" src="./logo.svg">
</p>
<h1 align="center">vitepressify</h1>
<h4 align="center">Convert Crystal docs into VitePress</h4>
<p align="center">
  <br />
    <a href="https://github.com/GeopJr/vitepressify/blob/main/CODE_OF_CONDUCT.md"><img src="https://img.shields.io/badge/Contributor%20Covenant-v2.1-000000.svg?style=for-the-badge&labelColor=389d70" alt="Code Of Conduct" /></a>
    <a href="https://github.com/GeopJr/vitepressify/blob/main/LICENSE"><img src="https://img.shields.io/badge/LICENSE-BSD--2--Clause-000000.svg?style=for-the-badge&labelColor=389d70" alt="BSD-2-Clause" /></a>
    <a href="https://github.com/GeopJr/vitepressify/actions"><img src="https://img.shields.io/github/workflow/status/GeopJr/vitepressify/Specs%20&%20Lint/main?labelColor=389d70&style=for-the-badge" alt="ci action status" /></a>
</p>

## What is vitepressify?

Crystal docs are awesome, but sometimes you need more control over them.

vitepressify generates a VitePress project with pages from your local or remote Crystal docs.

- It automatically generates markdown pages and sidebars.
- It provides a table of contents.
- It can update an already made project with more versions or other shards.
- It automatically handles loading sidebars and cases where navbar has 1 vs more items, without the need to overwrite any configs.
- It comes with a purple accent.

<p align="center">
    <img width="1024" src="https://i.imgur.com/XsauHgY.png" alt="Screenshot of VitePress docs of Crystal-lang api docs. Screenshot is split diagonally showcasing both dark and light themes." />
</p>

## Installation

### Pre-built

You can download one of the statically-linked pre-built binaries from the [releases page](https://github.com/GeopJr/vitepressify/releases/latest).

They are built & published by our lovely [actions](https://github.com/GeopJr/vitepressify/actions/workflows/release.yml).

### Building

#### Dependencies

- `crystal` - `1.5.0`

#### Manually

`$ shards build --production --no-debug --release`

## Usage

```
Vitepressify v1.0.0
Usage:
    vitepressify [arguments]
Examples:
    vitepressify -i ./docs/index.json
    vitepressify -i https://crystal-lang.org/api/1.5.0/ -t 1.5.0
    vitepressify -i https://geopjr.github.io/gettext.cr/index.json -u ./vitepressify-docs

Arguments:
    -i INDEX, --index=INDEX          index.json location. Can be either a local path or a url (e.g. https://libadwaita.geopjr.dev/docs/). Default: ./docs/index.json
    -t TAG, --tag=TAG                Current release/tag (e.g. 1.0.0). Default: main
    -u FOLDER, --update=FOLDER       Instead of generating a new project, it attempts to update the one at FOLDER.
    -l, --license                    Show the LICENSE
    -h, --help                       Show this help
```

## Example

If you wanted for example to build a VitePress project using the Crystal API docs from 1.4.0 to 1.5.1, all you have to do is:

- Generate the initial project, using the link to the 1.5.1 docs with the tag of `1.5.1`.

```bash
$ vitepressify -i https://crystal-lang.org/api/1.5.1/ -t 1.5.1
```

This will generate the project in a random named folder, for example `vitepress-ujqywe`.

- Now we just tell `vitepressify` to update that folder with the other versions:

```bash
$ vitepressify -i https://crystal-lang.org/api/1.5.0/ -t 1.5.0 -u ./vitepress-ujqywe/

$ vitepressify -i https://crystal-lang.org/api/1.4.1/ -t 1.4.1 -u ./vitepress-ujqywe/

$ vitepressify -i https://crystal-lang.org/api/1.4.0/ -t 1.4.0 -u ./vitepress-ujqywe/
```

- And we are done!

## Contributing

1. Read the [Code of Conduct](./CODE_OF_CONDUCT.md)
2. Fork it (<https://github.com/GeopJr/vitepressify/fork>)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

## Sponsors

<p align="center">

[![GeopJr Sponsors](https://cdn.jsdelivr.net/gh/GeopJr/GeopJr@main/sponsors.svg)](https://github.com/sponsors/GeopJr)

</p>
