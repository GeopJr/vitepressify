require "option_parser"

# Responsible for parsing the CLI args.
module Vitepressify
  VERSION = {{read_file("#{__DIR__}/../../shard.yml").split("version: ")[1].split("\n")[0]}}

  class CLI
    INSTANCE = CLI.new

    getter args : Array(String) = ARGV

    property index : Path | String = Path[".", "docs", "index.json"]
    property generate : Bool = true
    property tag : String = "main"
    property update : Path = Path.new

    def initialize(args : Array(String) = ARGV)
      @args = args

      parse
    end

    def parse
      OptionParser.parse(@args) do |parser|
        parser.banner = <<-BANNER
        #{"Vitepressify".colorize(:light_green).bold} v#{Vitepressify::VERSION}
        #{"Usage:".colorize(:light_green)}
            vitepressify [arguments]
        #{"Examples:".colorize(:light_green)}
            vitepressify -i ./docs/index.json
            vitepressify -i https://crystal-lang.org/api/1.5.0/ -t 1.5.0
            vitepressify -i https://geopjr.github.io/gettext.cr/index.json -u ./vitepressify-docs

        #{"Arguments:".colorize(:light_green)}
        BANNER

        parser.on("-i INDEX", "--index=INDEX", "index.json location. Can be either a local path or a url (e.g. https://libadwaita.geopjr.dev/docs/). Default: ./docs/index.json") do |input|
          if File.exists?(input)
            @index = Path[input].expand
          else
            downcased_input = input.downcase
            abort "'#{input}' does not exist.".colorize(:red) unless downcased_input.starts_with?(/https?:\/\//)
            input = "#{input}#{input.ends_with?('/') ? nil : '/'}index.json" unless downcased_input.ends_with?("index.json")

            @index = input
          end
        end
        parser.on("-t TAG", "--tag=TAG", "Current release/tag (e.g. 1.0.0). Default: main") do |input|
          @tag = input unless input.nil? || input.empty?
        end
        parser.on("-u FOLDER", "--update=FOLDER", "Instead of generating a new project, it attempts to update the one at FOLDER.") do |input|
          abort "'#{input}' does not exist.".colorize(:red) unless Dir.exists?(input)

          @generate = false
          @update = Path[input].expand
        end
        parser.on("-l", "--license", "Show the LICENSE") do
          puts {{read_file("#{__DIR__}/../../LICENSE")}}
          exit
        end
        parser.on("-h", "--help", "Show this help") do
          puts parser
          exit
        end
        parser.missing_option do |flag|
          STDERR.puts "ERROR: #{flag} requires an argument."
          STDERR.puts parser
          exit(1)
        end
        parser.invalid_option do |flag|
          STDERR.puts "ERROR: #{flag} is not a valid option."
          STDERR.puts parser
          exit(1)
        end
      end
    end
  end

  def self.config
    yield CLI::INSTANCE
  end

  def self.config
    CLI::INSTANCE
  end
end
