require "json"
require "colorize"
require "./vitepressify/*"

{% skip_file if @top_level.has_constant? "Spec" %}

# Responsible for handling the scripted events based
# on the config.

module Vitepressify
  DOCS = Vitepressify::Docs.new(Vitepressify.config.index)

  if Vitepressify.config.generate
    puts "Generating vitepress structure...".colorize(:light_magenta)

    output_folder = File.tempname(prefix: "vitepress", suffix: nil, dir: ".")
    output_path = Path[output_folder]

    vitepress = Vitepressify::Vitepress.new(DOCS.name, output_path)
    vitepress.create_structure

    # Generate the Vitepress project.
    File.write(output_path / Vitepressify::Vitepress::STRUCTURE[:package_json], vitepress.package_json)
    File.write(output_path / Vitepressify::Vitepress::STRUCTURE[:config], vitepress.config)
    File.write(output_path / Vitepressify::Vitepress::STRUCTURE[:readme], "---\ntitle: 'Home'\n---\n\n#{DOCS.index.body}")
    File.write(output_path / Vitepressify::Vitepress::STRUCTURE[:theme] / "index.js", vitepress.theme_config)
    File.write(output_path / Vitepressify::Vitepress::STRUCTURE[:theme] / "custom.css", vitepress.theme_css)

    puts "Done.".colorize(:green)
  else
    puts "Updating vitepress project...".colorize(:light_magenta)

    output_path = Vitepressify.config.update
    abort "'#{output_path}' doesn't seem to be a Vitepressify project.".colorize(:red) unless Dir.exists?(output_path / Vitepressify::Vitepress::STRUCTURE[:root]) && Dir.exists?(output_path / Vitepressify::Vitepress::STRUCTURE[:sidebars]) && File.exists?(output_path / Vitepressify::Vitepress::STRUCTURE[:config])

    vitepress = Vitepressify::Vitepress.new(DOCS.name, output_path)
    vitepress.create_structure

    puts "Done.".colorize(:green)
  end

  puts "Generating vitepress sidebar...".colorize(:light_magenta)
  File.write(output_path / Vitepressify::Vitepress::STRUCTURE[:sidebars] / vitepress.sidebar_name, DOCS.sidebar)
  puts "Done.".colorize(:green)

  puts "Generating vitepress pages...".colorize(:light_magenta)
  DOCS.vitepress.each do |k, v|
    name = k
    if name.ends_with?("toplevel")
      name = "#{Path[name].parent}/index"
    elsif name.downcase.ends_with?("index")
      name = "#{Path[name].parent}/_index"
    end

    filename = output_path / Vitepressify::Vitepress::STRUCTURE[:root] / "#{name}.md"
    Dir.mkdir_p(filename.parent)
    File.write(filename, v)
  end
  puts "Done.".colorize(:green)

  puts "Project #{Vitepressify.config.generate ? "generated" : "updated"} under '#{output_path}'.".colorize(:green).bold
  puts "You can now build it by running:".colorize(:yellow).bold
  puts "- cd '#{output_path}'"
  puts "- npm i"
  puts "- npm run docs:build"
end
