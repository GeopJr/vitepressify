require "./spec_helper"

def namedtuple_to_args(input) : Array(String)
  args = [] of String
  input.each do |k, v|
    args << "#{k.to_s.size == 1 ? '-' : "--"}#{k}"
    args << v
  end
  args
end

describe Vitepressify::CLI do
  default = Vitepressify::CLI.new

  it "should parse args and return a config" do
    tests = {
      {
        i: "https://geopjr.github.io/gettext.cr/index.json",
      },
      {
        i: "#{__DIR__}/index.json",
        t: "1.0.0",
      },
      {
        i: "https://geopjr.github.io/gettext.cr/",
        u: ".",
      },
    }

    tests.each do |set|
      index = default.index
      tag = default.tag
      generate = default.generate
      update = default.update

      args = namedtuple_to_args(set)

      tmp = Vitepressify::CLI.new(args)

      if (idx = tmp.index).is_a?(Path)
        idx.expand.should eq(Path[set.fetch("i", index)].expand)
      else
        res_idx = set.fetch("i", index)
        res_idx = "#{res_idx}#{res_idx.ends_with?('/') ? nil : '/'}index.json" unless !res_idx.is_a?(String) || res_idx.downcase.ends_with?("index.json")
        tmp.index.should eq(idx)
      end

      tmp.update.expand.should eq(Path[set.fetch("u", update)].expand)
      tmp.tag.should eq(set.fetch("t", tag))
      tmp.generate.should eq(!set.has_key?(:u))
    end
  end

  it "should abort on wrong args" do
    tests = {
      {
        i: "/i/do/not/exist/",
      },
      {
        u: "/neither/do/i/",
      },
    }

    tests.each do |set|
      args = namedtuple_to_args(set)

      expect_raises(Aborted) do
        Vitepressify::CLI.new(args)
      end
    end
  end
end
