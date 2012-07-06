require "active_resource/formats"

module UsefullTable
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
  class TableBuilder
    DATE = [:date, :datetime]
    LINK = [:show, :edit, :destroy, :download, :link]
    
    attr_reader :options

    #Initialize Builder with the following parameters:
    # @data = [ {column}, .. ]        see #col description
    # @object => ActiveRecod instance (paginated)
    # @search => MetaSearch instance
    # @template => View Contest
    # @options => options
    # :params => Tabel.builder.new.to_param[:params]
    #def initialize(object, search, options, template, data = nil, &block)
    def initialize(object, search, opt, template, *args, &block)
      options = args.extract_options!
      
      raise MissingBlock if block.nil? && options[:params].blank?
      
      @object = object
      @search = search
      @template = template
      
      if options[:params]
        #debugger
        @data = _decode_hash(options[:params][:data]).map{|e| e.with_indifferent_access } if options[:params][:data].present?
        opt = _decode_hash(options[:params][:options]).with_indifferent_access
      else
        @data ||= []
      end
      
      _manage_options(opt)
      
      @excel = []
      yield(self) if block
      
      #Rendering order is importanto so body and header are pre-rendered by initilizer and returned at will.
      @rendered_header = _render_header
      @rendered_body = _render_body
    end
    
    #Render table as Array, 
    #Columns Name in the first row
    #Bodies follows
    #Note: be sure to call after render_header and render_body
    def to_a
      @excel
    end
    
    #~ #Return path if temporary file where excel il saved
    #~ #Note: the file vanisch with the instance, so if you have more than one table per page, only the last one persist
    #~ #Note2: then excel is created on object so exports only the page (is affected by will_paginate)
    #~ def excel_path
        #~ to_a.to_xls(:file => true).path
    #~ end
    
    #Header is pre_rendered because we need the renderengi order is followed
    def render_header
      @rendered_header
    end
    
    #Body is pre_rendered because we need the renderengi order is followed
    def render_body
      @rendered_body
    end
    
    #~ def render_excel
      #~ @rendered_excel
    #~ end
    
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
    #   "Custom Name"      #plain text without localization in header
    #   :custom_name        #localized text in lazy context (.) in header
    #   
    # :data_type =>     #default get class name from object to render
    #   :Date | :Time | :DateTime | :Currency
    #   
    # :url => "static_path" or Proc       #Proc expose the object instance of the current row
    #
    # :inline => true (default false) enable inline edit
    #
    def col(attribute, *args)
      options = args.extract_options!
      options[:method_name] = :col
      options[:name] = attribute
      options[:type] = :column
      options[:header_type] ||= options[:label].nil? ? :sort : :plain
      options[:body_type] ||= options[:url].blank? ? :value : :link
      options[:label] ||= attribute
      @data << options
    end
    
    #=bool
    #
    # <% t.bool :name %>               #render column :name ( t.bool "name" is ok) as a green/red point
    # <% t.bool "user.name" %>       #render column name of the user collection in item (item.user.name) as a green/red point
    #
    #==Options
    # :header_type =>
    #   *:sort*     #Header is MetaSearch#sort_link of columns_name
    #   :human      #Header is plain text humanized with ActiveRecord column name
    #   :nil          #No header
    #   
    # :label =>
    #   "Custom Name"      #plain text without localization in header
    #   :custom_name        #localized text in lazy context (.) in header
    #
    # :url => "static_path" or Proc       #Proc expose the object instance of the current row
    #
    # :reverse => true    #transofrm true => false
    #
    def bool(attribute, *args)
      options = args.extract_options!
      options[:method_name] = :bool
      options[:name] = attribute
      options[:type] = :bool
      options[:header_type] ||= options[:label].nil? ? :sort : :plain
      options[:body_type] ||= options[:url].blank? ? :value : :link
      options[:data_type] = options[:reverse] == true ? :Bool_reverse : :Bool
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
      options[:method_name] = :label
      options[:name] = :label
      options[:type] = :column
      options[:header_type] ||= options[:label].nil? ? :nil : :plain
      options[:body_type] = :plain
      options[:body] = body
      @data << options
    end
    
    #Deprecated
    def status(*args)
      Rails::logger.info("TableBuilder#status is deprecated, please use monitor.")
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
      options[:method_name] = :monitor
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
        options[:method_name] = :link
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
    
    def to_param
      @params = {}
      @params[:data] = _encode_hash(_sanitize_data(@data))
      @params[:options] = _encode_hash(@options)
      
      @params
    end
    

    private
    
    #remove columns with link and procs
    #*  Links are not rendered so sending them is a waste
    #*  Proc cannot be serialized so are not sendable.
    def _sanitize_data(d)
      data = d.dup
      #Rails::logger.info("TableBuilder#_sanitize_data data=#{data.inspect}")
      num = 1
      data.delete_if { |element| element[:method_name] == :link || element[:body].kind_of?(Proc)}
      data.each do |element|
        element[:url] = "/" if element[:url].present?
      end if data.present?
      #Rails::logger.info("TableBuilder#_sanitize_data(fine) data=#{data.inspect}")
      data
    end
    
    def _encode_hash(a)
      a.to_xml
    end
    
    def _decode_hash(a)
      ActiveResource::Formats::XmlFormat.decode(a)
    end
    
    #set default values for options
    def _manage_options(options)
      @options = HashWithIndifferentAccess.new(options)
      #Paginator
      @options[:paginator] ||= {}
      @options[:paginator][:visible] = true if @options[:paginator][:visible].nil?
      @options[:paginator][:visible] = false if !@object.respond_to? :total_pages
      @options[:paginator][:class] = "usefull_table_paginator"
      
      #Container
      @options[:html] ||= {:class => "usefull_table_container"}
      
      #Excel
      @options[:export] ||= {}
      @options[:export][:visible] = true if @options[:export][:visible].nil?
      @options[:export][:visible] = false unless defined?(ActsAsXls)
      @options[:export][:filter] ||= false if @search.nil?
      @options[:export][:human] = true if @options[:export][:human].nil?
      @options[:export][:worksheet] ||= @object.first.class.name.gsub(/::/,"#")
      #remove search options if custom url is passed
      @options[:export][:search] = @options[:export][:url] ? false : true
      @options[:export][:url] ||= @template.url_for(:action => "create", :controller => "usefull_table/table") + ".xlsx"
      @options[:export][:class] = "usefull_table_export"
      
      #Table
      @options[:table] ||= {}
      @options[:table][:div_html] ||=  {:class => "usefull_table"}
      @options[:table][:header_html] ||= {:class => "first_row"}
      #Ususally column_type is  :sort, but is search is not present I cannot render a sort_link...
      @options[:table][:header_type] = :human if @search.nil?
      
      #Monitor
      @options[:monitor] ||= {}
      @options[:monitor][:visible] = @object.first.respond_to?(:status_flag) ? true : false
    end
    
    
    #Render table Header
    def _render_header
      out = []
      @template.content_tag(:tr, @options[:table][:header_html]) do
        @data.each do |element|
          element[:header_type] = :human if @options[:table][:header_type] == :human && element[:header_type] == :sort
          head = header(element)
          out << head[:plain]
          @template.concat @template.content_tag(:th, head[:html])
          #out_html = @template.content_tag(:th, head[:html])
        end
        @excel << out.compact
      end
    end
    
    #Render table row
    def _render_body
      out_html = ""
      @object.each do |obj|
        row = []
        out_html <<@template.content_tag(:tr, :class => @template.cycle("even","odd")) do
          @data.each do |element| 
            b = body(obj,element)
            row << b[:plain]
            @template.concat @template.content_tag(:td, b[:html]) 
          end
        end
        @excel << row.compact
      end
      out_html.html_safe
    end
    
    #Render column Header
    def header(attribute)
      out = ""
      out_html = ""
      case attribute[:header_type]
        when :sort then
          value = nestize(attribute)
          out_html = @template.sort_link(@search, value)
          out = value
        when :plain then
          out_html = out = attribute[:label] = localize(attribute[:label])
        when :human then
          #UserSession.log("TableHelper#h: object.first.class.human_attribute_name(#{attribute[:label]})")
          out_html = out = @object.first.class.human_attribute_name(attribute[:label].to_s.gsub(/\./,"_"))
        when :nil then
          out_html = out = ""
        else
          out_html = out = I18n.t(:Header_error, :scope => :usefull_table, :default => "Header Error")
      end
      out = nil if attribute[:type] == :link 
      out = I18n.t(:title, :scope => "usefull_table.monitor", :default => "Status") if attribute[:method_name] == :monitor
      {:html => out_html.html_safe, :plain => out}
    end
    
    #Render column body
    #return :plain and :html value
    def body(obj, attribute)
      #Rails::logger.info("TableBuilder#body")
      out = ""
      out_html = ""
      case attribute[:type]
        when :link then
          out_html = attribute_link(obj, attribute)
          out = nil
        when :bool
          out = typeize(obj, attribute)
          out_html = attribute_bool(out)
          out = out ? 1 : 0
        when :column then
          out = a = typeize(obj, attribute) unless attribute[:body_type] == :plain
          #Rails::logger.info("TableBuilder#body a=#{a.inspect}, attribute=#{attribute.inspect}")
          case attribute[:body_type]
            when :value
              out_html = a
              out_html = attribute_inline(obj,attribute,a) if attribute[:inline] == true
            when :link
              #url = attribute[:url].kind_of?(Proc) ? attribute[:url].call(obj) : attribute[:url] 
              #Rails::logger.info("TableBuilder#body a=#{a.inspect}, item=#{obj.BollaXENrDoC} or #{obj.activity.id}, id_bolla=#{obj.id}, attribute=#{attribute.inspect}")
              out_html = a.blank? ? a : @template.link_to(a, attribute[:url].kind_of?(Proc) ? attribute[:url].call(obj) : attribute[:url] )
              #out_html = @template.link_to(a, url)
            when :flag
              out_html = @template.monitor_tag obj 
              out = I18n.t(a , :scope => "usefull_table.monitor", :default => a)
            when :plain
              #Rails::logger.info("TableBuilder#body#plain obj=#{obj.inspect}")
              if attribute[:body].kind_of?(Proc)
                out_html = out = attribute[:body].call(obj)
              else
                out_html = out = attribute[:body].kind_of?(String) ? attribute[:body] : attribute[:body].inspect
              end
          end
      else
        out_html = out = I18n.t(:body_error, :scope => :usefull_table, :default => "Body Error")
      end
      {:html => out_html.to_s.html_safe, :plain =>  out}
    end
    
    
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
      true_values = [1, true, "vero", "true", "yes", "si", "s"]
      case type
        when :Date then
          @template.l(attribute_value(obj,attribute[:name]), :format => :usefull_table_date)
        when :Time then
          @template.l(attribute_value(obj,attribute[:name]), :format => :usefull_table_time )
        when :DateTime then
          @template.l(attribute_value(obj,attribute[:name]), :format => :usefull_table_datetime)
        when :Currency then
          @template.number_to_currency(attribute_value(obj,attribute[:name]))
        when :Bool then
          true_values.include?(attribute_value(obj,attribute[:name])) ? true : false
        when :Bool_reverse then
          true_values.include?(attribute_value(obj,attribute[:name])) ? false : true
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
    
    #Render in_place_editor
    #
    #get Class and method name and send them to helper for rendering.
    #
    #ToDo: Add check to multi level columns
    def attribute_inline(obj, attribute, value)
      Rails::logger.info("TableBuilder#attribute_inline obj=#{obj.inspect}, attribute=#{attribute.inspect}, value=#{value.inspect}")
      if safe?(obj, attribute[:name])
        attributes = attribute[:name].to_s.split(".")
        base = obj.class
        method = attributes.pop
        Rails::logger.info("TableBuilder#attribute_inline(1) attributes=#{attributes.inspect}")
        id = obj.id
        Rails::logger.info("TableBuilder#attribute_inline(2) method=#{method}, base=#{base.name}, attributes=#{attributes.inspect}")
        unless attributes.blank?
          id_relation = eval("obj.#{attributes.join(".")}.id")
          attributes.each do |association|
            reflection = base.reflect_on_association(association.to_sym)
            base = reflection.blank? ? nil : reflection.klass
          end
        end
        @template.inline_field(base, id, method, value, id_relation)
      else
        value
      end
      
    end
    
    #Render a red/green label 
    def attribute_bool(value)
      name = value ? :ok : :ko
      @template.content_tag(:span, @template.image_tag(I18n.t(name, :scope => "usefull_table.icons", :defualt => "usefull_table_#{name.to_s}.png")), :align => :center )
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
      #Rails::logger.info("TableBuilder#attribute_type attribute=#{attribute_name.inspect}, out=#{out.inspect}")
      out == :Time ? :DateTime : out
    end
    
    #Check if attribute_name return something...
    # Documentbody.first.safe?("document.activity.customer.nome") => true
    def safe?(obj, attribute_name)
      #Rails::logger.info("TableHelper#safe? attribute_name=#{attribute_name.inspect}, obj=#{obj.inspect}")
      raise RuntimeError if obj.instance_eval("self." + attribute_name.to_s).nil?
      true
    rescue NoMethodError, RuntimeError
      false
    end
    
  end
  
  
end
