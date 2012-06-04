class Item < ActiveRecord::Base
  belongs_to :user
  
  self.per_page = 2
  
end
