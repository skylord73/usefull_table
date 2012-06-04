#Modulo per la gestione delle tabelle
#si utilizza assieme a meta_search e a will_paginate per rappresentare le tabelle:
#[documents_controller]
# def index
#   @search = Magazzino::Document.where(:Esercizio => user_session.esercizio_user, :Magazzino => user_session.magazzino).search(params[:search])
#   ...
#   respond_to do |format|
#     format.html { @documents = @search.paginate(:page => params[:page]) }
#     format.xls { send_xls(@search) }
#   end
#   ...
# end
#
#[index.html.erb]
# <%=table_for(@documents,@search, :xls_url => magazzino_documents_path(:format => "xls")) do |t| %>
#   <% t.show :url => "magazzino_document_path(obj)"%>
#   <% t.edit :url => "edit_magazzino_document_path(obj)"%>
#   <% t.col :data, :data_type => :date %>
#   <% t.col :DoCNr %>
#   <% t.col :TbDoC %>
#   <% t.col :Segnalazioni %>
#   <% t.col :BollaXENrDoC %>
#   <%# t.col :BollaXEDataDoC %>
#   <% t.col :DoCSit %>
#   <% t.col "user_updated.displayname" %>
# <% end %>
#
#Per i vari parametri di configurazione fare riferimento ai vari helper
#*  #table_for
#*  #send_xls
#
#==Note
#Nel caso di tabelle generate da sql con select , assicurarsi di includere gli id delle tabelle collegate se si vogliono utilizzare le nested collection:
# Magazzino::Documentbody.select("ART, DescriArt, product_id").search(params[:search])
#
#Mi permette poi nella tabella di rappresentare anche i campi di product:
# <%=table_for(@documentbodies,@search, :xls_url => @product ? magazzino_product_documentbodies_path(@product, :format => "xls" ) : magazzino_documentbodies_path(:format => "xls")) do |t| %>
#   <% t.show :url => "magazzino_document_path(obj.document_id)"%>
#   <% t.col :ART %>
#   <% t.col :DescriArt %>
#   <% t.col "product_CodArtFRN %>
# <% end %>
module UsefullTableHelper
  #Permette la realizzazione di una tabella in visualizzazione secondo lo standard previsto
  #
  #==Prerequisiti
  #La classe necessita delle seguenti gemme per funzionare
  #*  meta_search
  #*  will_paginate
  #*  acts_as_monitor
  #
  #==Localizzazione
  #Utilizza l'albero di localizzazione di ActiveRecord per i nomi delle colonne
  # activerecord:
  #   attributes:
  #     magazzino:
  #       document:
  #         <nome_campo>: etichetta
  #         ...
  #       ...
  #
  #I link vengono localizzati utilizzando l'albero:
  # shared:
  #   buttons:
  #     show: "mostra"
  #     edit: "modifica"
  #     ...
  #
  #==Utilizzo
  #Si utilizza nelle viste con la seguente sintassi
  # <%=table_for(@products,@search) do |t| %>
  #   <% t.show :url => "magazzino_product_path(obj)" %>
  #   <% t.show :url => "magazzino_product_documentbodies_path(obj)", :label => :show_mov%>
  #   <% t.col :CodiceArt %>
  #   <% t.col :DescriArt %>
  #  <% end %>
  #
  #In alternativa si può inizializzzare anche con:
  # <%=table_for(@search) do |t| %>
  #
  #E' necessario passargli l'oggetto da tabellare (@products) e l'oggetto creato da MetaSearch (@search) come parametri obbligatori più un blocco dove è possibile utilizzare i seguenti metodi:
  #*  col : Crea una normale colonna
  #*  show, edit, destroy : Crea un link al tipo di url passato come parametro
  #
  #===Parametri
  #====Paginator
  # :paginator => {
  #   :visible => true | false (default: true)
  #   :class => "usefull_table_paginator" 
  #
  #====Container (div wrapping table + paginator + excel)
  # :html => {
  #   :class => "usefull_table_container"
  #   }
  #
  # :table => nil,      [parametri html del tag <table>]
  #    :tr_header =>       [parametri html del tag <tr> dell'intestazione]
  #       {:class => "first_row"},
  # :paginator => false    [non fa render del blocco will_paginate. Se specificato è
  #                         necessario esplicitare secondo argomento @search = nil]
  # @search = nil =>       [fa in modo che option :header_type = :human e quindi viene
  #                         localizzato da human_attribute_name nell'helper h]
  #
  #==XLS
  #Permette l'esportazione della tabella in un file xls.
  #Di default l'estrazione contiene solo i campi esposti in tabella e le righe visualizzate (utilizza il filtro attivo)
  #*  :xls_url => url da contattare per riceve il file, se manca non abilita l'esportazione xls
  #Passando i seguenti parametri è possibile variarne il comportamento:
  #*  :xls_filter => false     Restituisce tutti i valori indipendentmente dai filtri
  #*  :xls_all => true          Restituisce TUTTE le colonne della tabella
  #*  :xls_human => false     Non umanizza i nomi delle colonne
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
      Rails::logger.info("table_for START options=#{options.inspect}")
      
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
      options[:excel][:worksheet] ||= object.class.name.gsub(/::/,"#")
      
      #Table
      options[:table] ||= {}
      options[:table][:div_html] ||=  {:class => "usefull_table"}
      options[:table][:header_html] ||= {:class => "first_row"}
      #Ususally column_type is  :sort, but is search is not present I cannot render a sort_link...
      options[:table][:header_type] = search.nil? ? :human : :sort
      
      #Monitor
      options[:monitor] ||= {}
      options[:monitor][:visible] = object.respond_to?(:status_flag) ? true : false
      
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
  #@data contiene i dati nella seguente forma
  #[ {dato}, ...]
  #dove {dato} è cos' strutturato
  #*  {
  #*    :nome => nome colonna (ActiveRecord)
  #*    :type => :column | :link
  #*    :label => etichetta della colonna (== nome se non specificato)
  #*    :header_type => :sort | :plain | :human
  #*    :body_type => :value (viene valutato) | :plain (già stringa da rappresentare)
  class TableBuilder #:doc:
    DATE = [:date, :datetime]
    LINK = [:show, :edit, :destroy, :download]

    #==Parameters
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
          element[:header_type] = :human if @options[:table][:header_type] == :human
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
          @template.loc(attribute[:label], :default => attribute[:label])
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
      Rails::logger.info("TableBuilder#body")
      case attribute[:type]
        when :link then
          attribute_link(obj, attribute)
        when :column then
          a = typeize(obj, attribute)
          Rails::logger.info("TableBuilder#body a=#{a.inspect}, attribute=#{attribute.inspect}")
          case attribute[:body_type]
            when :value
              a
            when :link
              url = attribute[:url].kind_of?(Proc) ? attribute[:url].call(obj) : attribute[:url] 
              @template.link_to(a, url)
            when :flag
              @template.monitor_tag obj if options[:moniotr][:visible] == true
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
    
    #Riceve un nome colonna e lo mette in un vettore
    # col :DoCNr
    # col "warehousebehave.DescriDo"
    #
    #Gli vengono passate le seguenti opzioni
    #*  :url => "magazzino_document_path(obj)" da usare assieme a body_type => url, lo imposta in automatico
    #*  :header_type =>
    #*    :sort (default) viene creato il titolo con Helper sort_link (MetaSearch)
    #*    :human viene creato il titolo umanizzato senza link (se manca metasearch)
    #*    :nil non viene creato alcun nome nel titolo
    #*    :plain viene indicato il nome senza localizzato
    #*  :body_type =>
    #*    :plain (viene scritto il campo passato senza valutarne il metodo
    #*    :value (viene valutato il metodo come valore)
    #*    :flag (gestisce il dato come semaforo a tre colori green = 0, yellow = -1, rosso = 1
    #*    :link => "magazzino_document_path(obj)" trasforma il valore in un link al percorso passato (impostato in atuomatico)
    #*  :data_type => tipo di dato, serve per forzarlo nel caso il campo sia calcolato e non del db (:Date, :Time, :DateTime, :Currency
    #*  :label =>
    #*    attribute (default)
    #*    "nome" stringa con nome da localizzare
    def col(attribute, *args)
      options = args.extract_options!
      options[:name] = attribute
      options[:type] = :column
      options[:header_type] ||= :sort
      #al momento non utilizzata da inplementare in b()
      #Se passo un url alla colonna il tipo colonna passa da .value a :link
      options[:body_type] ||= options[:url].blank? ? :value : :link
      options[:label] ||= attribute
      @data << options
    end
    
    #Crea un inidcatore di stato utilizzando il metodo status_flag implementato in ActiveRecord 
    #*  Rosso : Errore
    #*  Giallo: Warning
    #*  Verde: Nessun problema
    #
    #ToDo: Implementare un link au un pop_up che evidenzia gli errori presenti
    def status(*args)
      options = args.extract_options!
      options[:name] = :status_flag
      options[:type] = :column
      options[:header_type] = :nil
      #al momento non utilizzata da inplementare in b()
      #Se passo un url alla colonna il tipo colonna passa da .value a :link
      options[:body_type] = :flag
      options[:label] ||= I18n.t(:status_flag, :scope => "activerecord.attributes")
      #UserSession.log("TableHelper#table_for#status attribute=#{options.inspect}")
      @data << options
    end
    
    #Link to
    # <% t.show :url => Proc.new {|object| magazzino_document_path(object) }"%>
    #
    #Gli vengono passate le seguenti opzioni
    #* :url => Proc or string
    #* :label => :show_doc (nome del link da localizzare)
    #*  :link_options => {:method => delete, :confirm => "sicuro?"} vengono aggiunti al link
    #dove obj verrà sostituito dall'oggetto riga corrispondente
    LINK.each do |method_name|
      define_method method_name do |*args|
        options = args.extract_options!
        options[:name] = method_name
        options[:type] = :link
        options[:header_type] ||= :nil
        options[:body_type] = :plain
        options[:label] ||= method_name
        raise CustomErrors::TableBuilders::UrlMissing unless options[:url]
        @data << options
      end
    end

    private

    #Verifica ase un attributo ha la label del tipo document.documentbody.TbDoC
    def nested?(attribute) #:doc:
      attribute[:name].to_s.match(/\./) ? true : false
    end
    
    #Convert labels from document.documentbody.TbDoC to document_documentbody_TbDoC
    #to be humanized
    def nestize(attribute) #:doc:
      nested?(attribute) ? attribute[:name].to_s.gsub(/\./,"_")  : attribute[:name]
    end
    
    #format value using data_type
    def typeize(obj, attribute) #:doc:
      Rails::logger.info("TableBuilder#typeize")
      type = attribute[:data_type] || attribute_type(obj, attribute[:name])
      case type
        when :Date then
          @template.loc(attribute_value(obj,attribute[:name]))
        when :Time then
          @template.loc(attribute_value(obj,attribute[:name]), :format => :hour_min )
        when :DateTime then
          @template.loc(attribute_value(obj,attribute[:name]), :format => :data_time)
        when :Currency then
          @template.number_to_currency(attribute_value(obj,attribute[:name]))
      else
          attribute_value(obj,attribute[:name])
      end
    end
    
    #Return attribute value if defined blank otherwise
    def attribute_value(obj, attribute_name)
      Rails::logger.info("TableBuilder#attribute_value obj=#{obj.inspect}, attribute=#{attribute_name.inspect}")
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
      Rails::logger.info("TableBuilder#attribute_link obj=#{obj.inspect}, attribute=#{attribute.inspect}")
      url = attribute[:url].kind_of?(Proc) ? attribute[:url].call(obj) : attribute[:url]
      attribute_name = attribute[:name]
      icon_name = @template.image_tag I18n.t(attribute_name, :scope => "usefull_table.icons", :defualt => "usefull_table_#{attribute_name}.png")
      @template.link_to(icon_name, url, attribute[:link_options])
    end
    
    #Return attribute Type
    #works evenif the attribute is nested : document.activity.data_prevista => :Date
    def attribute_type(obj, attribute_name)
      #Added self. because of uppercase fileds like Art are misinterprede as Constants...
      obj.instance_eval("self." + attribute_name.to_s + ".class.name.to_sym") if safe?(obj, attribute_name)
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
    Rails::logger.info("TableHelper#usefull_table_for ")
    content_tag(:div, options[:div_html]) do
      content_tag(:table, options[:html]) do
          builder.render_header + 
          builder.render_body
      end
    end
  end
  
  
end
