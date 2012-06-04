class HomeController < ApplicationController
  def index
    @search = Item.search(params[:search])
    @items = @search.paginate(:page => params[:page]) 
    @users = User.paginate(:page => params[:page]) 
    @user = User.where(:id => 1).paginate(:page => params[:page])
  end
  
  def show
    @item = Item.find(params[:id])
  end
  

end
