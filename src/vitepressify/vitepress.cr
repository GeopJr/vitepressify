module Vitepressify
  # Responsible for the content and locations
  # of the Vitepress project structure.
  class Vitepress
    # Locations of files in Vitepress project.
    STRUCTURE = {
      config:       Path["docs", ".vitepress", "config.js"],
      sidebars:     Path["docs", ".vitepress", "crystal"],
      readme:       Path["docs", "index.md"],
      root:         Path["docs"],
      package_json: Path["package.json"],
      theme:        Path["docs", ".vitepress", "theme"],
    }

    def initialize(name : String, dir : Path)
      @name = name
      @dir = dir
      @splitter = "+++"
    end

    # Creates the project structure folders.
    def create_structure
      STRUCTURE.values.each do |path|
        folder = path
        folder = folder.parent unless folder.extension.empty?
        Dir.mkdir_p(@dir / folder)
      end
    end

    # .vitepress/theme/config.js
    def theme_config
      <<-JS
      import DefaultTheme from 'vitepress/theme'
      import './custom.css'

      export default DefaultTheme
      JS
    end

    # .vitepress/theme/custom.css
    def theme_css
      <<-CSS
      :root {
          --vp-c-brand: #6f42b8;
          --vp-c-brand-light: #7a42d4;
          --vp-c-brand-lighter: #7b36eb;
          --vp-c-brand-dark: #5d33a1;
          --vp-c-brand-darker: #31155e;
      }


      .dark {
          --vp-c-brand: #9c8cb8;
          --vp-c-brand-light: #ae96d4;
          --vp-c-brand-lighter: #b594eb;
          --vp-c-brand-dark: #8574a1;
          --vp-c-brand-darker: #483a5e;
      }
      CSS
    end

    # The name at the sidebar json.
    def sidebar_name
      "#{@name}#{@splitter}#{Vitepressify.config.tag}.json"
    end

    # The import portion of .vitepress/config.js.
    # It imports and parses all the sidebars.
    def sidebar_import
      <<-JS
      import { fileURLToPath } from 'url'
      import { dirname, join, parse } from 'path';
      import { readdirSync, readFileSync } from "fs"
      
      const splitter = "#{@splitter}"
      const sidebar_folder = join(dirname(fileURLToPath(import.meta.url)), "crystal")
      const sidebars = readdirSync(sidebar_folder)
      const sidebars_json = {}
      
      sidebars.forEach(x => {
        let [name, version] = x.split(splitter)
        version = parse(version).name
      
        const raw = readFileSync(join(sidebar_folder, x), { encoding: "utf-8" })
      
        sidebars_json[version] = {
          name,
          json: JSON.parse(raw)
        }
      })
      JS
    end

    # The sidebar and nav portion of .vitepress/config.js.
    # It handles their structure based on the amount of
    # children.
    def sidebar_nav_gen
      <<-JS
      // NOTE: below code creates the sidebar and navbar
      // based on the amount of sidebars and their contents.
      function sidebar() {
        result = {}

        for (const [key, value] of Object.entries(sidebars_json)) {
          result[key] = [
            {
              text: "Docs",
              items: value.json
            }
          ]
        }
      
        return result
      }

      function nav() {
        if (Object.keys(sidebars_json).length === 1) {
          return {
            text: 'Docs',
            link: `${Object.values(sidebars_json)[0].json[0].link}`
          }
        }
      
        result = {
          text: 'Version',
          items: []
        }
      
        for (const [key, value] of Object.entries(sidebars_json)) {
          result.items.push({
            text: `${key}`,
            link: `${value.json[0].link}`
          })
        }
      
        return result
      }
      JS
    end

    # .vitepress/config.js
    def config
      <<-JS
        #{sidebar_import}
        // NOTE: Above code imports all sidebars.

        export default {
          title: '#{@name}',
          // TODO: Change me.
          description: 'My awesome Crystal project!',
          lastUpdated: true,
          ignoreDeadLinks: true,
          themeConfig: {
            nav: [
              nav()
            ],
            sidebar: sidebar()
          }
        }

        #{sidebar_nav_gen}
        JS
    end

    # package.json
    def package_json
      <<-JSON
        {
          "name": "#{@name.downcase}-vitepressify-docs",
          "version": "1.0.0",
          "description": "Docs for #{@name} using VitePress",
          "main": "index.js",
          "devDependencies": {
            "vitepress": "1.0.0-alpha.13",
            "vue": "^3.2.38"
          },
          "scripts": {
            "docs:dev": "vitepress dev docs",
            "docs:build": "vitepress build docs",
            "docs:serve": "vitepress serve docs"
          },
          "pnpm": {
            "peerDependencyRules": {
              "ignoreMissing": [
                "@algolia/client-search"
              ]
            }
          }
        }
        JSON
    end
  end
end
