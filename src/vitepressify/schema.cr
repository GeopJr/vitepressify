# The Crystal docs' index.json.
module Vitepressify
  class Location
    include JSON::Serializable

    property url : String?
  end

  class List
    include JSON::Serializable

    property location : Location?
    property full_name : String?
    property name : String
  end

  class Method
    include JSON::Serializable

    property doc : String?
    property location : Location?
    property name : String
    property args_string : String?
  end

  class Constant
    include JSON::Serializable

    property name : String
    property value : String
    property doc : String?
  end

  class Ancestor
    include JSON::Serializable

    property html_id : String
    property full_name : String
  end

  class Program
    include JSON::Serializable

    property html_id : String
    property doc : String?
    property ancestors : Array(Ancestor)?
    property constants : Array(Constant)?
    property constructors : Array(Method)?
    property class_methods : Array(Method)?
    property macros : Array(Method)?
    property instance_methods : Array(Method)?
    property included_modules : Array(List)?
    property extended_modules : Array(List)?
    property locations : Array(Location)?
    property full_name : String
    property kind : String?
    property types : Array(Program)?
  end

  class Index
    include JSON::Serializable

    property repository_name : String
    property program : Program
    property body : String? = File.exists?("./README.md") ? File.read("./README.md") : "My awesome Crystal project!"
  end
end
