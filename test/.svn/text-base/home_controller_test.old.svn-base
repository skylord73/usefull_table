require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  test "paginator: 2 paginator div present" do
    get :index
    assert_select "div.items_search" do
      assert_select "div.usefull_table_paginator", :count => 2 do
        assert_select "div.page_info"
      end
    end
    assert_select "div.items" do
      assert_select "div.usefull_table_paginator", :count => 2 do
        assert_select "div.page_info"
      end
    end
  end
  
  test "paginator not present" do
    get :index
    assert_select "div.search" do
      assert_select "div.usefull_table_paginator", :count => 0
    end
  end
  
  test "Excel present if :excel => {:visible => true} or not defined" do
    get :index
    assert_select "div.search" do
      assert_select "div.usefull_table_excel", :count => 1
    end
    assert_select "div.items" do
      assert_select "div.usefull_table_excel", :count => 1
    end
  end
  
  test "Excel not present if :excel => {:visible => false}" do
    get :index
    assert_select "div.items_search" do
      assert_select "div.usefull_table_excel", :count => 0
    end
  end
  
  test "Search present: header_type => :sort " do
    get :index
    assert_select "div.items_search"  do
      assert_select "a.sort_link", :count => 2
    end
    assert_select "div.search"  do
      assert_select "a.sort_link", :count => 2
    end
  end
  
  test "Search missing: header_type => :human" do
    get :index
    assert_select "div.items"  do
      assert_select "a.sort_link", :count => 0
    end
  end
  
  
  
end
