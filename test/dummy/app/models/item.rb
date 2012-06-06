class Item < ActiveRecord::Base
  belongs_to :user
  
  def money
    12.3
  end
  
end
