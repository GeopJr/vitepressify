# Responsible for generating the sidebar recursively.
module Vitepressify
  class Sidebar
    alias VitepressifySidebarFlat = NamedTuple(text: String, link: String, items: Array(VitepressifySidebarFlat))
    alias VitepressifySidebar = NamedTuple(text: String, link: String) | NamedTuple(text: String, link: String, collapsible: Bool, collapsed: Bool, items: Array(VitepressifySidebar))

    getter sidebar : String

    def initialize(index : Hash(String, String), collapsed : Bool = false, collapsible : Bool = false)
      @collapsed = collapsible ? collapsed : false
      @collapsible = collapsible
      @sidebar = generate_sidebar(index)
    end

    private def generate_sidebar(index : Hash(String, String)) : String
      sidebar = Hash(String, VitepressifySidebarFlat).new
      index.keys.sort { |a, b| b.count('/') <=> a.count('/') }.each do |k|
        path = Path.posix("/", k)

        sidebar[path.to_s] = {
          text:  path.basename,
          link:  path.to_s,
          items: [] of VitepressifySidebarFlat,
        }
      end

      sidebar.each do |k, v|
        path = Path.posix(k)

        if sidebar.has_key?(path.parent.to_s)
          sidebar[path.parent.to_s][:items] << v
          sidebar.reject!(k)
        end
      end

      # wtf
      JSON.parse(clear_sidebar(sidebar).to_json).as_h.values.to_json
    end

    private def clear_sidebar(items : Hash(String, VitepressifySidebarFlat)) : Hash(String, VitepressifySidebar)
      items_mini = Hash(String, VitepressifySidebar).new

      items.each do |k, v|
        items_mini[k] = clear_sidebar(v)
      end

      items_mini
    end

    private def clear_sidebar(items : VitepressifySidebarFlat) : VitepressifySidebar
      text = items[:text]
      link = items[:link]
      if text == "toplevel"
        text = "Top Level Namespace"
        link = "#{Path[link].parent}/"
      elsif text.downcase == "index"
        link = "#{Path[link].parent}/_index"
      end

      if items[:items].size == 0
        {
          text: text,
          link: link,
        }
      else
        {
          text:        text,
          link:        link,
          collapsible: @collapsible,
          collapsed:   @collapsed,
          items:       items[:items].map { |v1| clear_sidebar(v1) },
        }
      end
    end
  end
end
