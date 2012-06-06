module UsefullTableHelper
  #=UsefullTable
  #table_for generate a full-optionals table, with excel export, columns ordering, links, inline edit and monitoring (ActsAsMonitor gem)
  #but don't warry because of a rich set of defaults, make its use very simple
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
  # options[:excel][:visible] = *true* | false
  # options[:excel][:filter] = *true* | false   _note:_ false if @search not present
  # options[:excel][:human] = *true* | false
  # options[:excel][:worksheet] = *object.class.name.gsub(/::/,"#")*  _note:_ class name with namespace separator #
  #
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
      raise CustomErrors::TableBuilders::BlockMissing unless block_given?
      
      if obj.kind_of?(MetaSearch::Builder)
        search = obj
        object = obj.relation
      else
        object = obj
      end
      #Rails::logger.info("table_for START options=#{options.inspect}")
      
      #Paginator
      options[:paginator] ||= {}
      options[:paginator][:visible] = true if options[:paginator][:visible].nil?
      options[:paginator][:visible] = false if !object.respond_to? :total_pages
      options[:paginator][:class] = "usefull_table_paginator"
      
      #Container
      options[:html] ||= {:class => "usefull_table_container"}
      
      #Excel
      options[:excel] ||= {}
      options[:excel][:visible] = true if options[:excel][:visible].nil?
      options[:excel][:filter] ||= false if search.nil?
      options[:excel][:human] = true if options[:excel][:human].nil?
      options[:excel][:worksheet] ||= object.first.class.name.gsub(/::/,"#")
      
      #Table
      options[:table] ||= {}
      options[:table][:div_html] ||=  {:class => "usefull_table"}
      options[:table][:header_html] ||= {:class => "first_row"}
      #Ususally column_type is  :sort, but is search is not present I cannot render a sort_link...
      options[:table][:header_type] = :human if search.nil?
      
      #Monitor
      options[:monitor] ||= {}
      options[:monitor][:visible] = object.first.respond_to?(:status_flag) ? true : false
            
      Rails::logger.info("table_for POST options=#{options.inspect}")
            
      t = TableBuilder.new(object, search, options, self,  &block)
      
      out = ""
      out << monitor_tag_js if options[:monitor][:visible] == true
      out << stylesheet_link_tag('usefull_table.css')
      out << content_tag(:div, options[:html]) do
        ext = ''
        ext << usefull_table_paginator_for(object, options[:paginator])
        ext << usefull_table_excel_for(t, object, search, options[:excel])
        ext << usefull_table_for(t, object, search, options[:table])
        ext << usefull_table_paginator_for(object, options[:paginator])
        ext.html_safe
      end
      out.html_safe
    end
  end
  
  #Crea un bottone per spedire un xls params[:xls]
  #[index.html.erb]
  # xls_tag (array, utility_phone_queue_show_stat_path(@phone_queue_id, :format => "xls"))
  #
  #Si accoppia con l'helper da controller:
  #[phone_queues_controller.rb]
  # ...
  # send_xls(params[:xls][:dati])
  #
  def xls_tag(dati, url, method = :get)
    if dati.kind_of?(Array)
      form_tag( url , :method => method) do
        concat hidden_field_tag("xls[data]", dati.to_json)
        concat submit_tag(t(:xls, :scope => :table))
      end
    end
  end
  
  
  #Da utilizzarsi nei controller per l'esportazione del file excel
  # respond_to do |format|
  #   format.xls { send_xls(@search) }
  # end
  #
  #==Options
  #*  :file_name permette di specificare un file name diverso 
  #*  :redirect spcifica un percorso alternativo 
  #*  params[:xls] viene passato a to_xls
  #
  #==Localization
  # magazzino:
  #   <nome_controller>:
  #     file_xls: "%{data}_bolle.xls"
  #     no_xls: "Nessuna bolla da esportare!"
  #
  def send_xls(search, *args)
    options = args.extract_options!
    options[:redirect] ||= "index"
    options[:file_xls] ||= t("file_xls", :data => loc(Time.now.to_date, :format => :file) + "_" + user_session.magazzino, :default => "webgatec") + ".xls"
  
    search = search.relation if search.respond_to?(:relation)
    search = ActiveSupport::JSON.decode(search) if search.kind_of?(String)
    
    if search.respond_to?(:to_xls)
      send_data search.to_xls(params[:xls]), :filename => options[:file_xls] 
    else
      flash[:alert] = t("no_xls")
      redirect_to :html => options[:redirect]
    end
  end
  
  #Builder as the name suggest builds rows and columns
  #
  #
  #==@data
  #@data array contains columns data in the form:
  #[ {column1}, {column2} ...]
  #where {column} is an hash with the following options:
  #*  {
  #*    :nome => column name (ActiveRecord) int the form :column or "collection.column"
  #*    :type => :column | :link
  #*    :label =>  "wath you want" | column name if not specified
  #*    :header_type => :sort | :plain | :human | :nil
  #*    :body_type => :value (column value) | :plain (wathever you write as column name)
  class TableBuilder #:doc:
    DATE = [:date, :datetime]
    LINK = [:show, :edit, :destroy, :download, :link]

    #Initialize Builder with the following parameters:
    # @data = [ {column}, .. ]        see #col description
    # @object => ActiveRecod instance (paginated)
    # @search => MetaSearch instance
    # @template => View Contest
    # @options => options
    def initialize(object, search, options, template, &block)
      @data = Array.new
      @object = object
      @options = options
      @search = search
      @template = template
      yield(self)
    end

    #Render table Header
    def render_header
      @template.content_tag(:tr, @options[:table][:header_html]) do
        @data.each do |element|
          element[:header_type] = :human if @options[:table][:header_type] == :human && element[:header_type] == :sort
          @template.concat @template.content_tag(:th, header(element))
        end
      end
    end
    
    #Render column Header
    def header(attribute)
      case attribute[:header_type]
        when :sort then
          value = nestize(attribute)
          @template.sort_link(@search, value)
        when :plain then
          localize(attribute[:label])
        when :human then
          #UserSession.log("TableHelper#h: object.first.class.human_attribute_name(#{attribute[:label]})")
          @object.first.class.human_attribute_name(attribute[:label].to_s.gsub(/\./,"_"))
        when :nil then
          ""
        else
          I18n.t(:Header_error, :scope => :usefull_table, :default => "Header Error")
      end
    end
    
    #Render table row
    def render_body
      out = ""
      @object.each do |obj|
        out <<@template.content_tag(:tr, :class => @template.cycle("even","odd")) do
          @data.each do |element| 
            @template.concat @template.content_tag(:td, body(obj,element)) 
          end
        end
      end
      out.html_safe
    end
    
    #Render column body
    def body(obj, attribute)
      #Rails::logger.info("TableBuilder#body")
      case attribute[:type]
        when :link then
          attribute_link(obj, attribute)
        when :column then
          a = typeize(obj, attribute) unless attribute[:body_type] == :plain
          #Rails::logger.info("TableBuilder#body a=#{a.inspect}, attribute=#{attribute.inspect}")
          case attribute[:body_type]
            when :value
              a
            when :link
              url = attribute[:url].kind_of?(Proc) ? attribute[:url].call(obj) : attribute[:url] 
              @template.link_to(a, url)
            when :flag
              @template.monitor_tag obj 
            when :plain
              if attribute[:body].kind_of?(Proc)
                attribute[:body].call(obj)
              else
                attribute[:body].kind_of?(String) ? attribute[:body] : attribute[:body].inspect
              end
          end
      else
        I18n.t(:body_error, :scope => :usefull_table, :default => "Body Error")
      end
    end
    
    #Render excel fields
    def render_excel
      out = ""
      @data.each { |d| out << @template.hidden_field_tag('xls[only][]', d[:name]) if d[:type] == :column } unless @options[:excel][:columns] == :all
      @search.search_attributes.each_pair {|k,v| out << @template.hidden_field_tag("search[#{k}]", v) } unless  @options[:excel][:filter] == false
      out << @template.hidden_field_tag("xls[human]", false) if @options[:excel][:human] == false
      out << @template.hidden_field_tag("xls[worksheet]", @options[:excel][:worksheet])
      out.html_safe
    end
    
    #=col
    #Render column value
    #
    #==Usage #col
    # <% t.col :name %>               #render column :name ( t.col "name" is ok)
    # <% t.col "user.name" %>      #render column name of the user collection in item (item.user.name)
    #
    #==Options
    # :header_type =>
    #   *:sort*     #Header is MetaSearch#sort_link of columns_name
    #   :human      #Header is plain text humanized with ActiveRecord column name
    #   :nil          #No header
    #   
    # :label =>
    #   "Custom Name"      #plain text without localization
    #   :custom_name        #localized text in lazy context (.)
    #   
    # :data_type =>     #default get class name from object to render
    #   :Date | :Time | :DateTime | :Currency
    #   
    # :url => "static_path" or Proc       #Proc expose the object instance of the current row
    def col(attribute, *args)
      options = args.extract_options!
      options[:name] = attribute
      options[:type] = :column
      options[:header_type] ||= options[:label].nil? ? :sort : :plain
      options[:body_type] ||= options[:url].blank? ? :value : :link
      options[:label] ||= attribute
      @data << options
    end
    
    #=label
    #Render static label
    #
    #==Usage
    # <% t.label object %>               #render object.inspect
    # <% t.label Proc.new {|item| item.name.capitalize} %>               #Evaluate proc with item instance of the corresponding row
    def label(body, *args)
      options = args.extract_options!
      options[:name] = :label
      options[:type] = :column
      options[:header_type] ||= options[:label].nil? ? :nil : :plain
      options[:body_type] = :plain
      options[:body] = body
      @data << options
    end
    
    #Deprecated
    def status(*args)
      Rails::logger.info("TableBuilder#status if deprecated, please use monitor.")
      monitor(*args)
    end
    
    #=monitor
    #Render a tri-state icon to monitor model status
    #*  Red : Error
    #*  Yellow: Warning
    #*  Green: Status ok
    #
    #==Usage
    # <% t.monitor %>
    #
    #Clicking the icon you get the comlete problem description pushed by Ajaxs script (no page reload)
    def monitor(*args)
      options = args.extract_options!
      options[:name] = :status_flag
      options[:type] = :column
      options[:header_type] = :nil
      options[:body_type] = :flag
      options[:label] ||= I18n.t(:status_flag, :scope => "activerecord.attributes")
      @data << options if @options[:monitor][:visible] == true
    end
    
    #=link
    #Create a link to something, using Icons or CustomText
    #==Usage
    # <% t.show :url => Proc.new {|object| home_path(object) }"%>
    # <% t.destroy :url => Proc.new {|object| home_path(object) }"%>
    # <% t.link :name => "Custom Link",  :url => Proc.new {|object| my_link_home_path(object) }"%>    #text link (Custom Link) to url 
    # <% t.link :name => "Custom Link",  :body_typ => :icon,  :url => Proc.new {|object| my_link_home_path(object) }"%>    #icon link with icon name = usefull_table_cusom_link.png or localization in usefull_table.icons.custom_link 
    #
    #==Options
    # :url => Proc or string
    # :label => :show_doc localized in lazy contest (.)
    #               "Show Doc" printed without localization
    # :link_options =>  *nil* | {:method => delete, :confirm => "sicuro?"} if name == :destroy
    # :name => :symbol or "string"    #if method_name == :link the name is used as link_text (localized if symbol), ignored elsewhere
    LINK.each do |method_name|
      define_method method_name do |*args|
        options = args.extract_options!
        options[:type] = :link
        options[:header_type] ||= :nil
        options[:header_type] = :plain unless options[:label].nil?
        options[:body_type] ||= method_name == :link ? :link : :icon
        options[:label] ||= method_name
        options[:name] = method_name unless method_name == :link && !options[:name].nil?
        options[:link_options] ||= {:method => :delete, :confirm => I18n.t(:confirm, :scope => "usefull_table", :default => "Are you sure?")} if options[:name] == :destroy
        raise CustomErrors::TableBuilders::UrlMissing unless options[:url]
        @data << options
      end
    end

    private
    
    #Localize if Symbol, print if String
    def localize(value)
      value.kind_of?(String) ? value : @template.t(".#{value.to_s}")
    end
  
    #Check if the attribute_name is a reference to a collection (user.name)
    def nested?(attribute) #:doc:
      attribute[:name].to_s.match(/\./) ? true : false
    end
    
    #Convert labels from user.name to user_name to be used by meta_search for sorting columns
    def nestize(attribute) #:doc:
      nested?(attribute) ? attribute[:name].to_s.gsub(/\./,"_")  : attribute[:name]
    end
    
    #format value using data_type
    def typeize(obj, attribute) #:doc:
      #Rails::logger.info("TableBuilder#typeize")
      type = attribute[:data_type] || attribute_type(obj, attribute[:name])
      case type
        when :Date then
          @template.l(attribute_value(obj,attribute[:name]), :format => :usefull_table_date)
        when :Time then
          @template.l(attribute_value(obj,attribute[:name]), :format => :usefull_table_time )
        when :DateTime then
          @template.l(attribute_value(obj,attribute[:name]), :format => :usefull_table_datetime)
        when :Currency then
          @template.number_to_currency(attribute_value(obj,attribute[:name]))
      else
          attribute_value(obj,attribute[:name])
      end
    end
    
    #Return attribute value if defined blank otherwise
    def attribute_value(obj, attribute_name)
      #Rails::logger.info("TableBuilder#attribute_value obj=#{obj.inspect}, attribute=#{attribute_name.inspect}")
      if safe?(obj, attribute_name) 
        obj.instance_eval("self." + attribute_name.to_s) if safe?(obj, attribute_name)
      else
        ""
      end
    end
    
    #Return link to url with Icon
    #==Attributes
    # :url =>   Proc.new { |object| ...}    #eval with row_instance as contest
    #             "static_url"
    # :name =>  :show | :edit | :destroy | :download  used to loaclize icons_name
    #   /config/locales/usefull_table.it.yml
    #   it:
    #     usefull_table:
    #       icons:
    #         nane:
    def attribute_link(obj, attribute)
      #Rails::logger.info("TableBuilder#attribute_link obj=#{obj.inspect}, attribute=#{attribute.inspect}")
      url = attribute[:url].kind_of?(Proc) ? attribute[:url].call(obj) : attribute[:url]
      attribute_name = attribute[:name]
      icon_name = attribute[:body_type] == :icon ? @template.image_tag(I18n.t(attribute_name.to_s.underscore, :scope => "usefull_table.icons", :defualt => "usefull_table_#{attribute_name.to_s.underscore}.png") ): localize(attribute_name)
      @template.link_to(icon_name, url, attribute[:link_options])
    end
    
    #Return attribute Type
    #works evenif the attribute is nested : document.activity.data_prevista => :Date
    #Time object in Rails is a DateTime object, so it is renamed
    def attribute_type(obj, attribute_name)
      #Added self. because of uppercase fileds like Art are misinterprede as Constants...
      out = obj.instance_eval("self." + attribute_name.to_s + ".class.name.to_sym") if safe?(obj, attribute_name)
      Rails::logger.info("TableBuilder#attribute_type attribute=#{attribute_name.inspect}, out=#{out.inspect}")
      out == :Time ? :DateTime : out
    end
    
    #Check if attribute_name return something...
    # Documentbody.first.safe?("document.activity.customer.nome") => true
    def safe?(obj, attribute_name)
      #UserSession.log("TableHelper#safe? attribute_name=#{attribute_name.inspect}, obj=#{obj.inspect}")
      obj.instance_eval("self." + attribute_name.to_s)
      true
    rescue NoMethodError, RuntimeError
      false
    end
    
  end
  
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
  
  #==Excel
  #Export table content to excel file
  #===Parameters
  # :excel => {
  #   :visible => true | false       #default: true
  #   :columns => :all                 #Export all model columns, if not present exports only table columns
  #   :url => "documents_path"   #Url to controller returning xls file
  #   :human => true | false       #default: true , Humanize column names
  #   :filter => true | false       #default: true,  export filtered data
  #
  def usefull_table_excel_for(builder,object, search, options = {})
    if options[:visible] == true
      #Rails::logger.info("table_for#excel_tag")
      content_tag(:div, :class => "usefull_table_excel") do 
        form_tag( options[:url] , :method => :get) do
          builder.render_excel +
          submit_tag(I18n.t(:submit_excel, :scope => :usefull_table))
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
  
  
end
