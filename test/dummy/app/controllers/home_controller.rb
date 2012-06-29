class HomeController < ApplicationController
  #in_place_edit_for :item, :name
  
  def index
    
    respond_to do |format|
      format.html do
        @search = Item.search(params[:search])
        @items = @search.paginate(:page => params[:page]) 
        @users = User.paginate(:page => params[:page]) 
        @user = User.where(:id => 1).paginate(:page => params[:page])
      end
      
      format.xlsx do
        temp = Tempfile.new("export.xlsx")
        Axlsx::Package.new do |p|
          p.workbook do |wb|
            wb.add_worksheet do |sheet|
              sheet.add_row ["a","b","c"]
            end
          end
        end.serialize temp.path
        send_file temp.path, :filename => "prova.xlsx"
      end
      
        
    end
    
  end
  
  def show
    @item = Item.find(params[:id])
  end
  
  def destroy
    @item = Item.find(params[:id])
    @item.destroy
    redirect_to "index"
  end
  
end
