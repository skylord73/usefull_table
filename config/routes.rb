# CURRENT FILE :: config/routes.rb
Rails.application.routes.draw do
   namespace :usefull_table do
   	 	 #resources :table, :only =>[:create]
   	 	 match "table/create" => "table#create", :via => :post
       match "table/update/:id" => "table#update", :via => :post
  end
end
