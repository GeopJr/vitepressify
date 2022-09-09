require "http/client"

# Responsible for parsing Crystal docs' index.json
# and return its pages and sidebar.
module Vitepressify
  class Docs
    getter index : Vitepressify::Index
    getter vitepress : Hash(String, String) = Hash(String, String).new
    getter sidebar : String = ""

    def initialize(path : Path)
      path = path / "index.json" if File.exists?(path / "index.json")
      abort "'#{path}' does not exist.".colorize(:red) unless File.exists?(path)

      @index = File.open(path) do |file|
        Vitepressify::Index.from_json(file)
      end

      generator = Vitepressify::Generator.new(self)
      @vitepress = generator.index
      @sidebar = generator.sidebar
    end

    def initialize(url : String)
      @index = HTTP::Client.get(url) do |response|
        abort "'#{url}' reutrned #{response.status_code}.".colorize(:red) unless response.status_code == 200

        Vitepressify::Index.from_json(response.body_io)
      end

      generator = Vitepressify::Generator.new(self)
      @vitepress = generator.index
      @sidebar = generator.sidebar
    end

    def name : String
      @index.repository_name
    end

    # e.g. /Crystal/String => /main/String
    def to_vite_version(path : String) : String
      path.sub(name, Vitepressify.config.tag)
    end
  end
end
