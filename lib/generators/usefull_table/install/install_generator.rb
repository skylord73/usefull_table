require 'rails/generators'
module UsefullTable
  class InstallGenerator < Rails::Generators::Base
    desc "Install generator for UsefullTable gem"
    source_root File.expand_path("../templates", __FILE__)
    
    def copy_config
      directory "config"
    end
    
    def copy_public
      directory "public"
    end
    
    #~ def copy_icons
      #~ icons = ["acts_as_monitor_green.png", "acts_as_monitor_red.png", "acts_as_monitor_yellow.png", "acts_as_monitor_loading.gif"]
      #~ icons.each do |icon| 
        #~ destination = "public/images/" + icon
        #~ copy_file icon, destination
      #~ end
    #~ end
      
    #~ def copy_locales
      #~ file = "acts_as_monitor.it.yml"
      #~ destination = "config/locales/" + file
      #~ copy_file file, destination
    #~ end
    
    #~ def copy_javascripts
      #~ copy_file "acts_as_monitor_javascript.js", "public/javascripts/acts_as_monitor_javascript.js"
    #~ end

    #~ def copy_stylesheet
      #~ copy_file "acts_as_monitor.css", "public/stylesheets/acts_as_monitor.css"
    #~ end


    #~ def print_usage
      #~ usage = <<-START
      #~ Add acts_as_monitor to model to monitor
      #~ Add a private method warn_*? and error_*? to define warning and error status
      #~ Use monitor_tag(model_instance) in your view
      #~ START
      #~ puts(usage)
    #~ end
  end      
end
