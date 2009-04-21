class GoalsController < ApplicationController
  
  Comment_Page_Size = 100
  Goal_Page_Size = 15
  
  
  layout "community"
  
  before_filter :check_login, :only => [:create, :edit, :update, :destroy]
  before_filter :check_limited, :only => [:create, :update, :destroy]
  
  before_filter :check_admin, :only => [:edit, :update, :destroy]
  
  
  
  def index
    
  end

  def show
    
  end
  
  def create
    goal_name = params[:goal_name] && params[:goal_name].strip
    
  end
  
  def edit
    
  end
  
  def update
    
  end
  
  def destroy
    
  end
  
  
  private
  
  def is_general_admin?
    ApplicationController.helpers.general_admin?(session[:account_id])
  end
  
  def check_admin
    jump_to("/errors/forbidden") unless is_general_admin?
  end
  
end

