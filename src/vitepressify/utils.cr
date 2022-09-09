# Contains helper methods.
module Vitepressify::Utils
  extend self

  # Vitepress containers.
  enum Container
    INFO
    TIP
    WARNING
    DANGER
  end

  # Crystal docs admonitions => vitepress containers.
  Admonitions = {
    note: Container::INFO,

    experimental: Container::TIP,
    optimize:     Container::TIP,

    fixme:   Container::WARNING,
    warning: Container::WARNING,
    todo:    Container::WARNING,

    bug:        Container::DANGER,
    deprecated: Container::DANGER,
  }

  # All Crystal docs admonitions.
  Admonitions_keywords = Admonitions.keys.map { |x| x.to_s.upcase }

  # Regex that matches admonitions and their content.
  Admonition_regex = /(#{Admonitions_keywords.join('|')}):? ?(.+)/

  # Regex that matches just the admonitions.
  Admonitions_keywords_regex = /(#{Admonitions_keywords.join('|')}):?/

  # All langs shiki allows (else it crashes).
  Allowed_codeblocks = {
    "abap",
    "actionscript-3",
    "ada",
    "apache",
    "apex",
    "apl",
    "applescript",
    "asm",
    "astro",
    "awk",
    "ballerina",
    "bat",
    "batch",
    "berry",
    "be",
    "bibtex",
    "bicep",
    "blade",
    "c",
    "cadence",
    "cdc",
    "clarity",
    "clojure",
    "clj",
    "cmake",
    "cobol",
    "codeql",
    "ql",
    "coffee",
    "cpp",
    "crystal",
    "csharp",
    "c#",
    "css",
    "cue",
    "d",
    "dart",
    "diff",
    "docker",
    "dream-maker",
    "elixir",
    "elm",
    "erb",
    "erlang",
    "erl",
    "fish",
    "fsharp",
    "f#",
    "gherkin",
    "git-commit",
    "git-rebase",
    "glsl",
    "gnuplot",
    "go",
    "graphql",
    "groovy",
    "hack",
    "haml",
    "handlebars",
    "hbs",
    "haskell",
    "hs",
    "hcl",
    "hlsl",
    "html",
    "ini",
    "java",
    "javascript",
    "js",
    "jinja-html",
    "json",
    "jsonc",
    "jsonnet",
    "jssm",
    "fsl",
    "jsx",
    "julia",
    "kotlin",
    "latex",
    "less",
    "liquid",
    "lisp",
    "logo",
    "lua",
    "make",
    "makefile",
    "markdown",
    "md",
    "marko",
    "matlab",
    "mdx",
    "mermaid",
    "nginx",
    "nim",
    "nix",
    "objective-c",
    "objc",
    "objective-cpp",
    "ocaml",
    "pascal",
    "perl",
    "php",
    "plsql",
    "postcss",
    "powershell",
    "ps",
    "ps1",
    "prisma",
    "prolog",
    "pug",
    "jade",
    "puppet",
    "purescript",
    "python",
    "py",
    "r",
    "raku",
    "perl6",
    "razor",
    "rel",
    "riscv",
    "rst",
    "ruby",
    "rb",
    "rust",
    "rs",
    "sas",
    "sass",
    "scala",
    "scheme",
    "scss",
    "shaderlab",
    "shader",
    "shellscript'",
    "shell",
    "bash",
    "sh",
    "zsh",
    "smalltalk",
    "solidity",
    "sparql",
    "sql",
    "ssh-config",
    "stata",
    "stylus",
    "styl",
    "svelte",
    "swift",
    "system-verilog",
    "tasl",
    "tcl",
    "tex",
    "toml",
    "tsx",
    "turtle",
    "twig",
    "typescript",
    "ts",
    "vb",
    "cmd",
    "verilog",
    "vhdl",
    "viml",
    "vim",
    "vimscript",
    "vue-html",
    "vue",
    "wasm",
    "wenyan",
    "文言",
    "xml",
    "xsl",
    "yaml",
    "zenscript",
  }

  Allowed_codeblocks_regex = /^```(#{Allowed_codeblocks.join('|')})({.+})?$/i

  # Function that transforms Crystal Doc Admonitions
  # to VitePress blocks.
  # Also ``` => ```crystal,
  # ](// => ](https://
  # It does so by looping through all lines and skipping
  # inside multiline admonitions while also keeping track
  # of multiple admonitions in a row. It's goal is to
  # wrap both inline and multiline admonitions while
  # avoiding creating nested ones.
  def viteify(content : String) : String
    clean_content = [] of String

    skip = -1
    content = content.gsub("](//", "](https://")
    lines = content.lines
    in_code_block = false
    lines.each_with_index do |line, i|
      next if i <= skip

      result = line
      if line.starts_with?(Admonitions_keywords_regex)
        tmp = [result]
        skip = i
        next_line = lines[skip + 1]?
        while !next_line.nil? && next_line != "" && !next_line.starts_with?(Admonitions_keywords_regex)
          tmp << next_line
          skip = skip + 1
          next_line = lines[skip + 1]?
        end

        result = tmp.join(' ').gsub(Admonition_regex) do |_, x|
          admonition = x[1]
          message = x[2]

          <<-MD
          ::: #{Admonitions[admonition.downcase].to_s.downcase} #{admonition}
          #{message}
          :::
          MD
        end
      elsif line.starts_with?("```")
        codeless = line == "```"

        unless in_code_block
          if codeless
            result = line + "crystal"
          else
            result = Allowed_codeblocks_regex.matches?(line) ? line : "```"
          end
        end
        in_code_block = !in_code_block
      end

      clean_content << result
    end

    clean_content.join('\n')
  end
end
