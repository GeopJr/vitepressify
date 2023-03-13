# Responsible for generating an index of the pages
# and the sidebar.
module Vitepressify
  class Generator
    getter index : Hash(String, String)
    getter sidebar : String

    def initialize(parser : Docs)
      @parser = parser
      toplevel = generate_index(parser.index.program)

      file_index = Hash(String, String).new
      file_index[toplevel[:path]] = toplevel[:content] if toplevel[:content].count('#') > 1
      file_index.merge!(get_types(parser.index.program))

      @index = file_index
      @sidebar = Vitepressify::Sidebar.new(@index).sidebar
    end

    # Recursively get everything.
    def get_types(parent : Program) : Hash(String, String)
      file_index = Hash(String, String).new
      unless (types = parent.types).nil?
        types.each do |type|
          tmp = get_types(type)
          file_index.merge!(tmp)

          idx = generate_index(type)
          file_index[idx[:path]] = idx[:content]
        end
      end
      file_index
    end

    private def generate_index(parent : Program) : NamedTuple(path: String, content: String)
      file_path = @parser.to_vite_version(parent.html_id)

      overview = parent.doc
      overview = Vitepressify::Utils.viteify(overview) unless overview.nil?
      ancestors = get_ancestors(parent.ancestors)
      constants = get_constants(parent.constants)
      class_methods = get_methods(parent.class_methods, "def", "Class Methods")
      macros = get_methods(parent.macros, "macro", "Macros")
      instance = get_methods(parent.instance_methods, "def", "Instance Methods")
      included_modules = get_list(parent.included_modules, "Included Modules")
      extended_modules = get_list(parent.extended_modules, "Extended Modules")
      constructors = get_methods(parent.constructors, "def", "Constructors")

      location = parent.locations.try &.[0]?.try &.url
      title = location ? "[#{parent.full_name}](#{location})" : parent.full_name
      title = "#{parent.kind} #{title}" unless parent.kind.nil?

      page = <<-MD
        ---
        title: "#{parent.full_name}"
        ---

        ::: v-pre
        # #{title}
        #{ancestors}
      
        #{overview}
        ::: details Table of Contents
        [[toc]]
        :::
        #{included_modules}
        #{extended_modules}
        #{constants}
        #{constructors}
        #{class_methods}
        #{instance}
        #{macros}
        :::
        MD

      {path: file_path, content: page}
    end

    # Generates `Vitepressify::List` Docs.
    private def get_list(obj : Array(List)?, title : String) : String?
      return if obj.nil?

      children = [] of String
      obj.each do |ans|
        location = ans.location.try &.url
        name = ans.full_name
        name = ans.name if name.nil?

        children << (location ? "[#{name}](#{location})" : "`#{name}`")
      end

      return if children.size == 0

      <<-MD
      
        # #{title}
      
        #{children.join(", ")}
      
        MD
    end

    # Generates `Vitepressify::Constant` Docs.
    private def get_constants(obj : Array(Constant)?) : String?
      return if obj.nil?

      result = ["## Constants"]

      obj.each do |ans|
        doc = ans.doc
        doc = Vitepressify::Utils.viteify(doc) unless doc.nil?
        result << <<-MD
          ### #{ans.name}
          
          ```crystal
          #{ans.value}
          ```
      
          #{doc}
          MD
      end

      "\n#{result.join("\n\n")}\n"
    end

    # Generates `Vitepressify::Method` Docs.
    # *prefix* is used as a prefix for the titles e.g. "def #{method}"
    # *title* is used as the section title e.g. "Class Methods"
    private def get_methods(obj : Array(Method)?, prefix : String, title : String) : String?
      return if obj.nil?

      result = ["## #{title}"]

      obj.each do |ans|
        doc = ans.doc
        doc = Vitepressify::Utils.viteify(doc) unless doc.nil?

        location = ans.location.try &.url
        args = ans.args_string ? "`#{ans.args_string}`" : nil
        name = location ? "[#{ans.name}](#{location})#{args}" : "#{ans.name}#{args}"

        result << <<-MD
          
            ### #{prefix} #{name}
        
            #{doc}
      
            MD
      end

      result.join("\n\n")
    end

    # Generates `Vitepressify::Ancestor` Docs.
    private def get_ancestors(obj : Array(Ancestor)?) : String?
      return if obj.nil? || obj.size == 0

      ancestors = obj.map { |x| "`#{x.full_name}`" }.join(" < ")

      <<-MD
        #{ancestors}
        MD
    end
  end
end
