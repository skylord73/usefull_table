module UsefullTableHelper
  #=UsefullTable
  #table_for generate a full-optionals table, with excel export, columns ordering, links, inline edit and monitoring (ActsAsMonitor gem)
  #but don't worry because of a rich set of defaults makes it very simple to use.
  #
  #==Setup
  #Add this line to your application's Gemfile:
  # gem 'usefull_table'
  #
  #then execute
  #  $ bundle install
  #
  #or install it yourself as:
  # $ sudo gem install usefull_table
  #
  #copy icons, javascript and stylesheets:
  # $ rails g usefull_table:install
  #
  #==Usage table_for
  #Write few lines in your controller
  # app/controllers/home_controller.rb
  # def index
  #   @search = Item.search(params[:search])
  #   ...
  #   respond_to do |format|
  #     format.html { @items = @search.paginate(:page => params[:page]) }
  #   end
  #   ...
  # end
  #
  #and in your view
  # app/views/home/my_view.html.erb
  # <%= table_for @items, @search, options = {} do |t| %>
  #   <% t.show :url => Proc.new { |item| item_path(item)} %>
  #   <% t.edit :url => Proc.new { |item| edit_item_path(item)}%>
  #   <% t.destroy :url => Proc.new { |item| item_path(item)}, :link_options => {:method => delete, :confirm => "are you sure?"} %>
  #   <% t.download :url => Proc.new { |item| download_item_path(item)} %>
  #   <% t.col :name %>
  #   <% t.col "user.name" %>
  #   <% t.status %>
  # <% end %>
  #
  #==Options
  #default values in *bold*
  #
  #===Paginator
  # options[:paginator][:visible] = *true* | false  _note_: false if @items not present
  # options[:paginator][:class] = *"usefull_table_paginator"*
  #    
  #===Container
  # options[:html] =  *{:class => "usefull_table_container"}*
  #
  #===Excel
  # options[:export][:visible] = *true* | false
  # options[:export][:filter] = *true* | false   _note:_ false if @search not present
  # options[:export][:human] = *true* | false
  # options[:export][:worksheet] = *object.class.name.gsub(/::/,"#")*  _note:_ class name with namespace separator #
  # options[:export][:url] = custom url
  #===Table
  # options[:table][:div_html] =  *{:class => "usefull_table"}*
  # options[:table][:header_html] = *{:class => "first_row"}*
  # options[:table][:header_type] = *:sort*   _note:_ :human if @search not present (no sorting possible)
  #                                               :plain    bare column name from ActiveRecord
  #                                               :human  column name humanized by ActiveRecord
  #                                               :nil      no column name
  #    
  #==Localization
  #Uses standard ActiveRecord localization to render tables and columns names
  # it:
  #   activerecord:
  #     attributes:
  #       item:
  #        name: Name
  #        type: Type
  #       user:
  #        name: Name
  #    models:
  #      item:
  #        one: Item
  #        other: Items
  #      user:
  #        one: User
  #        other: Users
  #  
  # #config/usefull_table.it.yml
  # it:
  #   usefull_table:
  #     submit_excel: Excel
  #     header_error: Errore
  #     body_error: Errore
  #   
  #   icons:
  #     show: "usefull_table_show.png"
  #     edit: "usefull_table_edit.png"
  #     destroy: "usefull_table_destroy.png"
  #     download: "usefull_table_download.png" 
  #
  def table_for(obj, *args, &block)
    #Rails::logger.info("table_for START args=#{args.inspect}")
    unless obj.blank?
      search = args.shift if args[0].kind_of?(MetaSearch::Builder)
      #Rails::logger.info("table_for START(1) search=#{search.inspect}")
      options = args.extract_options!
      raise UsefullTable::MissingBlock unless block_given?
      
      if obj.kind_of?(MetaSearch::Builder)
        search = obj
        object = obj.relation
        search_attributes = search.search_attributes
      else
        object = obj
      end
                 
      builder = UsefullTable::TableBuilder.new(object, search, options, self,  &block)
      options = builder.options
      
      out = ""
      out << monitor_tag_js if options[:monitor][:visible] == true
      out << stylesheet_link_tag('usefull_table.css')
      out << content_tag(:div, options[:html]) do
        ext = ''
        ext << usefull_table_export_for(object,search,builder, options[:export])
        ext << usefull_table_paginator_for(object, options[:paginator])
        ext << usefull_table_for(builder, object, search, options[:table])
        ext << usefull_table_paginator_for(object, options[:paginator])
        ext.html_safe
      end
      out.html_safe
    end
  end
  
  #Instantiate builder with data info and render arrays for every line
  #
  #==Usage
  #If you can use params to clone an existing table (builder.to_param) and return an array of Arrays
  # $ array = export_for(@object, @params)
  #
  #You can build a new table passing a block (see  ::table_for
  def export_for(object, params = nil, &block)
    unless object.blank?
      builder = UsefullTable::TableBuilder.new(object, nil, nil, self,  :params => params, &block)
      builder.to_a
    else
      []
    end
  end
  
  #Draw inline edit field
  def inline_field(object, id, method, value, id_relation, tag_options = {}, in_place_editor_options = {})
    Rails::logger.info("table_for#inline_field : oject=#{object.inspect}, method=#{method.inspect}, id=#{id.inspect}")
    tag_options = { :tag => "span",
                          :id => "#{object.name.underscore.gsub("/","_")}_#{method}_#{id}_#{id_relation}_in_place_editor",
                          :class => "in_place_editor_field"}
    id_relation = id if id_relation.nil?
    in_place_editor_options[:url] = url_for({:action => "update", :controller=>"usefull_table/table", :id => id_relation})
    in_place_editor_options[:parameters] = { :class_name => object.name.underscore, :attribute_name => method}
    tag = content_tag(tag_options.delete(:tag), h(value),tag_options)
    return tag + in_place_editor(tag_options[:id], in_place_editor_options)
  end
  
  private 
  
  #==Paginator
  #Add pagination to Table
  #===Parameters
  # :paginator => {
  #   :visible => true | false                      #Default: true
  #   :class => ""usefull_table_paginator"
  #}
  def usefull_table_paginator_for(object, options = {})
    if options[:visible] == true
      #Rails::logger.info("table_for#paginator_tag : enter object=#{object.inspect}, options=#{options.inspect}")
      content_tag :div, :class => options[:class] do
        content_tag(:div, page_entries_info(object), :class => 'page_info') +
        will_paginate(object, :container => false)
      end 
    else
      ""
    end
  end
  
  #==Export
  #Export table content to excel file
  #
  #Send to controller the following parameters to rebuild the table in excel format
  #*  Search filters
  #*  Columns (@data)
  #*  Values (evenif calculated locally)
  #===Parameters
  # :excel => {
  #   :visible => true | false       #default: true
  #   :columns => :all                 #Export all model columns, if not present exports only table columns
  #   :url => "documents_path"   #Url to controller returning xls file
  #   :human => true | false       #default: true , Humanize column names
  #   :filter => true | false       #default: true,  export filtered data
  #
  def usefull_table_export_for(object,search,builder,options)
    if options[:visible] == true
      if options[:search] == true
        @params = {}
        @params[:search] = search.search_attributes unless search.blank?
        @params[:class_name] = object.first.class.name
        @params[:params] = builder.to_param
        @params[:paths] = view_paths.map {|path| "#{path.to_path}/#{controller_name}/#{action_name}.xlsx.maker"}
        #Rails::logger.info("table_for#excel_tag @path=#{self.controller_name}, action=#{action_name}, path=#{view_paths.first.to_path}\n\n")
        content_tag(:div, :class => options[:class]) do 
          form_tag( options[:url] , :method => :post) do
            hidden_field_tag("usefull_table", @params.to_json) + 
            submit_tag(I18n.t(:submit_excel, :scope => :usefull_table))
          end
        end
      else
        content_tag(:div, :class => options[:class]) do 
          form_tag( options[:url], :method => :get ) do
            submit_tag(I18n.t(:submit_excel, :scope => :usefull_table))
          end
        end
      end
    else
      #If "" the next div magically disappear...
      "&nbsp"
    end
  end
  
  #==Table
  #Draw Table
  #===Parameters
  # :table => {
  #   :div_html =>  {:class => "usefull_table"}       #HTML options of <div> container
  #   :header_html] =>  {:class => "first_row"}     #HTML options of Headers <tr>
  #   :html =>  {}                                              #HTML options of <table>
  # }
  def usefull_table_for(builder, object, search, options = {})
    #Rails::logger.info("TableHelper#usefull_table_for ")
    content_tag(:div, options[:div_html]) do
      content_tag(:table, options[:html]) do
          builder.render_header + 
          builder.render_body
      end
    end
  end
  
  #Return the first valid path af an xlsx.maker
  #if nil default is used.
  def select_path(paths, extension)
    Rails::logger.info("select_path @path=#{paths.inspect}\n\n")
    paths.delete_if {|path| !File.exists?(path)}
    Rails::logger.info("select_path(dopo) @path=#{paths.inspect}\n\n")
    paths.blank? ? nil : paths.first
  end
  
  # Makes an HTML element specified by the DOM ID +field_id+ become an in-place
  # editor of a property.
  #
  # A form is automatically created and displayed when the user clicks the element,
  # something like this:
  # <form id="myElement-in-place-edit-form" target="specified url">
  # <input name="value" text="The content of myElement"/>
  # <input type="submit" value="ok"/>
  # <a onclick="javascript to cancel the editing">cancel</a>
  # </form>
  #
  # The form is serialized and sent to the server using an AJAX call, the action on
  # the server should process the value and return the updated value in the body of
  # the reponse. The element will automatically be updated with the changed value
  # (as returned from the server).
  #
  # Required +options+ are:
  # <tt>:url</tt>:: Specifies the url where the updated value should
  # be sent after the user presses "ok".
  #
  # Addtional +options+ are:
  # <tt>:rows</tt>:: Number of rows (more than 1 will use a TEXTAREA)
  # <tt>:cols</tt>:: Number of characters the text input should span (works for both INPUT and TEXTAREA)
  # <tt>:size</tt>:: Synonym for :cols when using a single line text input.
  # <tt>:cancel_text</tt>:: The text on the cancel link. (default: "cancel")
  # <tt>:save_text</tt>:: The text on the save link. (default: "ok")
  # <tt>:loading_text</tt>:: The text to display while the data is being loaded from the server (default: "Loading...")
  # <tt>:saving_text</tt>:: The text to display when submitting to the server (default: "Saving...")
  # <tt>:external_control</tt>:: The id of an external control used to enter edit mode.
  # <tt>:load_text_url</tt>:: URL where initial value of editor (content) is retrieved.
  # <tt>:options</tt>:: Pass through options to the AJAX call (see prototype's Ajax.Updater)
  # <tt>:parameters</tt>:: Pass through post
  # <tt>:with</tt>:: JavaScript snippet that should return what is to be sent
  # in the AJAX call, +form+ is an implicit parameter
  # <tt>:script</tt>:: Instructs the in-place editor to evaluate the remote JavaScript response (default: false)
  # <tt>:click_to_edit_text</tt>::The text shown during mouseover the editable text (default: "Click to edit")
  def in_place_editor(field_id, options = {})
    function = "new Ajax.InPlaceEditor("
    function << "'#{field_id}', "
    function << "'#{url_for(options[:url])}'"

    js_options = {}

    if protect_against_forgery?
      options[:with] ||= "Form.serialize(form)"
      options[:with] += " + '&authenticity_token=' + encodeURIComponent('#{form_authenticity_token}')"
      options[:parameters].each_pair {|k,v| options[:with] += " + '&#{k.to_s}=' + encodeURIComponent('#{v.to_s}')"} if options[:parameters]
    end
    
    

    js_options['cancelText'] = %('#{options[:cancel_text]}') if options[:cancel_text]
    js_options['okText'] = %('#{options[:save_text]}') if options[:save_text]
    js_options['loadingText'] = %('#{options[:loading_text]}') if options[:loading_text]
    js_options['savingText'] = %('#{options[:saving_text]}') if options[:saving_text]
    js_options['rows'] = options[:rows] if options[:rows]
    js_options['cols'] = options[:cols] if options[:cols]
    js_options['size'] = options[:size] if options[:size]
    js_options['externalControl'] = "'#{options[:external_control]}'" if options[:external_control]
    js_options['loadTextURL'] = "'#{url_for(options[:load_text_url])}'" if options[:load_text_url]
    js_options['ajaxOptions'] = options[:options] if options[:options]
    js_options['htmlResponse'] = !options[:script] if options[:script]
    js_options['callback'] = "function(form) { return #{options[:with]} }" if options[:with]
    js_options['clickToEditText'] = %('#{options[:click_to_edit_text]}') if options[:click_to_edit_text]
    js_options['textBetweenControls'] = %('#{options[:text_between_controls]}') if options[:text_between_controls]
    js_options['onComplete'] = %('#{options[:on_complete]}') if options[:on_complete]
    js_options['onFailure'] = %('#{options[:on_failure]}') if options[:on_failure]
    function << (', ' + options_for_javascript(js_options)) unless js_options.empty?
    
    function << ')'

    javascript_tag(function)
  end
  
  
  
   
end
