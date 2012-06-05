require 'test_helper'

class NavigationTest < ActiveSupport::IntegrationCase
    
  test "Check table(@object, @search) makes right div" do
    visit root_path
    #assert page.has_css?('div.object_search div.usefull_table_container'), "Container out"
    within('div.object_search') do
      within('div.usefull_table_container') do
        assert page.has_selector?('div.usefull_table_paginator', :count => 2), "Paginators"
        assert page.has_selector?('div.usefull_table_excel'), "Excel"
        assert page.has_selector?('div.usefull_table'), "Table"
      end
    end
  end
    
  test "Check table(@object) makes right div" do
    visit root_path
    #assert page.has_css?('div.object_search div.usefull_table_container'), "Container out"
    within('div.object') do
      within('div.usefull_table_container') do
        assert page.has_selector?('div.usefull_table_paginator', :count => 2), "Paginators"
        assert page.has_selector?('div.usefull_table_excel'), "Excel"
        assert page.has_selector?('div.usefull_table'), "Table"
      end
    end
  end
  
  test "Check table(@search) makes right div" do
    visit root_path
    #assert page.has_css?('div.object_search div.usefull_table_container'), "Container out"
    within('div.search') do
      within('div.usefull_table_container') do
        assert page.has_no_selector?('div.usefull_table_paginator', :count => 2), "Paginators"
        assert page.has_selector?('div.usefull_table_excel'), "Excel"
        assert page.has_selector?('div.usefull_table'), "Table"
      end
    end
  end
  
  test "Check table(@empty) makes no div" do
    visit root_path
    #assert page.has_css?('div.object_search div.usefull_table_container'), "Container out"
    within('div.empty') do
        assert page.has_no_selector?('div'), "Too much divs"
    end
  end
  
  test "sort_link is present only if @search is passed" do
    within('div.search') do
      within('div.usefull_table_container') do
        within('div.usefull_table') do
          assert page.has_selector?('a.sort_link', :count => 2), "search"
        end
      end
    end
    
    within('div.object_search') do
      within('div.usefull_table_container') do
        within('div.usefull_table') do
          assert page.has_selector?('a.sort_link', :count => 2), "object_search"
        end
      end
    end
    
    within('div.object') do
      within('div.usefull_table_container') do
        within('div.usefull_table') do
          assert page.has_no_selector?('a.sort_link'), "object"
        end
      end
    end
  end
  
  
end
