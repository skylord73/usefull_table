module UsefullTable
  class Engine < Rails::Engine

    initializer 'usefull_table.helper' do |app|
      ActiveSupport.on_load(:action_controller) do
        include UsefullTableHelper
      end
      ActiveSupport.on_load(:action_view) do
        include UsefullTableHelper
      end
      
    end
  end
  
end
