require 'test_helper'

class TableForOptionsTest < ActiveSupport::IntegrationCase
  
  test "Link with no header (default)" do
    visit root_path
    within('div.object_search div.usefull_table_container div.usefull_table tr.first_row') do
      assert page.has_selector?(:xpath, './/th[1]', :text => ""), "show plain text"
      assert page.has_no_selector?('span'), "show translation missing"
    end
  end
  
  test "Link with custom header label" do
    visit root_path
    within('div.object_search_options div.usefull_table_container div.usefull_table tr.first_row') do
      assert page.has_selector?(:xpath, './/th[1]', :text => "show_custom_label"), "show_cutom_label"
      assert page.has_selector?(:xpath, './/th[2]', :text => "Show I18n"), "localized"
      assert page.has_selector?(:xpath, './/th[3]/span', :text => "Missing Translation"), "missing translation"
    end
  end
  
  test "link with custom text or icon" do
    visit root_path
    within('div.object_search_options div.usefull_table_container div.usefull_table tr.odd') do
      assert page.has_selector?(:xpath, './/td[4]', :text => "Custom Text"), "custom_text_link"
      assert page.has_selector?(:xpath, './/td[5]/a/img'), "custom icon"
    end
  end
  
  test "Column working with collection nil" do
    visit root_path
    within('div.object_search_options_col div.usefull_table_container div.usefull_table') do
      assert page.has_selector?(:xpath, './/tr[4]/td[1]', :text => "without owner"), "wrong row"
      assert page.has_selector?(:xpath, './/tr[4]/td[2]', :text => ""), "collection"
    end
  end
  
  test "Date/Time/DateTime/Currency formats" do
    visit root_path
    within('div.object_search_options_col div.usefull_table_container div.usefull_table') do
      @dt = page.find(:xpath, './/tr[4]/td[3]').text
      @t = page.find(:xpath, './/tr[4]/td[4]').text
      @d = page.find(:xpath, './/tr[4]/td[5]').text
      @c = page.find(:xpath, './/tr[4]/td[6]').text
    end
    assert_match /^\d{2}\/\d{2}\/\d{4}\s\d{2}:\d{2}$/, @dt, "DateTime"
    assert_match /^\d{2}:\d{2}$/, @t, "Time"
    assert_match /^\d{2}\/\d{2}\/\d{4}$/, @d, "Date"
    assert_match /^\d{2},\d{2}\s€$/, @c, "Currency"
  end
  
  test "Column Header type" do
    visit root_path
    within('div.object_search_options_col div.usefull_table_container div.usefull_table tr.first_row') do
      assert page.has_selector?(:xpath, ".//th[1]/a[@class='sort_link']"), ":sort"
      assert page.has_selector?(:xpath, './/th[2]', :text => "User name" ), ":human"
      assert page.has_selector?(:xpath, './/th[3]', :text => ""), ":nil"
      assert page.has_selector?(:xpath, './/th[4]', :text => "Time"), ":plain"
      assert page.has_selector?(:xpath, './/th[5]', :text => "Show I18n"), ":plain localized"
    end
  end
  
  test "Label options" do
    visit root_path
    within('div.object_search_options_col div.usefull_table_container div.usefull_table') do
      @a = page.find(:xpath, './/tr[4]/td[7]').text
      @n = page.find(:xpath, './/tr[4]/td[8]').text
    end
    assert @a == %{["a", 1, 1.2]}
    assert_not_equal  @n.to_i, 0
  end
  
  test "Columns link options" do
    visit root_path
    within('div.object_search_options_col div.usefull_table_container div.usefull_table') do
      click_link("pen")
    end
    puts page.html
    assert page.has_selector?('h', :text => "Show"), "first wrong page"
    assert page.has_selector?('p#id', :text => '3'), "first wrong id"
    
    visit root_path
    within('div.object_search_options_col div.usefull_table_container div.usefull_table') do
      click_link("pippo")
    end
    assert page.has_selector?('h1', :text => "Home Page Test site New"), "second wrong page"
  end
  
end
