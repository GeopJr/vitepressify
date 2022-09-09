require "spec"
require "../src/vitepressify"

HTTP::Client.get("https://geopjr.github.io/gettext.cr/index.json") do |response|
  File.write("#{__DIR__}/index.json", response.body_io.gets)
end

class Aborted < Exception
end

def abort(message = nil, status = 1)
  raise Aborted.new(message.to_s)
end
