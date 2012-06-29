require 'test_helper'

class UsefullTableTest < ActionView::TestCase
  
  setup do
    @object = Item.all
    @options = {}
    @builder = UsefullTable::TableBuilder.new(@object,nil,@options,self) do |t|
      t.link :name => "MyLink", :url => "/"
      t.show :url => "/"
      t.col :name, :url => "/"
      t.col "user.name"
      t.col :created_at
      t.label [:a,1,2,3], :label => "Label"
      t.label Proc.new {|obj| obj.id*3}, :label => "Label_proc"
      t.status
    end
    @params = @builder.to_param
  end
  
  test "Respond to to_xls" do
    assert Item.new.respond_to?(:to_xls)
  end
  
  test "Builder raise exception if no block or data hash given" do
    assert_raise UsefullTable::MissingBlock do
      UsefullTable::TableBuilder.new(nil, nil, nil, nil,  nil)
    end
  end
  
  test "Builder to_param" do
    @data = @builder.send("_decode_hash", @params[:data])
    @options = @builder.send("_decode_hash", @params[:options])
    assert @options.kind_of?(Hash), "Options"
    assert_equal 5, @data.length, "Data"
  end
  
  test "Builder to_a return array of array" do
    t = UsefullTable::TableBuilder.new(@object, nil, nil , self,  :params => @params)
    @array = t.to_a
    assert @array.present?, "not present"
    assert_equal ["Name", "User name", "Created at", "Label", "Stato"], @array.shift, "title"
    assert_equal ["pc", "pluto", "30/05/2012 12:41", [:a, 1, 2, 3].inspect, "Ok"], @array.shift, "body"
  end
  
  def monitor_tag(obj)
    #fake method to test
    obj.status_flag
  end
  
  
  
  
end
