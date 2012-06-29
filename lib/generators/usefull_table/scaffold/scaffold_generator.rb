require 'rails/generators'
module UsefullTable
  class ScaffoldGenerator < Rails::Generators::Base
    desc "Install generator for UsefullTable gem"
    source_root File.expand_path("../templates", __FILE__)
    
    def copy_templates
      directory "lib"
    end
    
  end      
end
