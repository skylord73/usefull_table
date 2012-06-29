module UsefullTable
  class TableController < ::ApplicationController
    
    def create
      usefull_table = HashWithIndifferentAccess.new(ActiveSupport::JSON.decode(params[:usefull_table]))
      #Rails::logger.info("MonitorsController back=#{usefull_table[:paths].inspect}")
      if usefull_table[:class_name].present?
        if usefull_table[:search].present?
          @object = usefull_table[:class_name].constantize.search(usefull_table[:search]).relation
        else
          @object = usefull_table[:class_name].constantize.all
        end
        @params = usefull_table[:params]
      end
      
      respond_to do |format|
        format.html
        format.xlsx { render :xlsx => "create", :template => select_path(usefull_table[:paths],"xlsx.maker") }
      end
    end
    
    def update
      #usefull_table = HashWithIndifferentAccess.new(ActiveSupport::JSON.decode(params[:usefull_table]))
      Rails::logger.info("TableController#update params=#{params.inspect}")
      if params[:class_name].present? && params[:attribute_name].present?
        @item = params[:class_name].to_s.camelize.constantize.find(params[:id])
        @item.update_attribute(params[:attribute_name], params[:value])
        render :text => CGI::escapeHTML(@item.send(params[:attribute_name]).to_s)
      end
    end
    

  end    
end
