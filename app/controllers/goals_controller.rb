class GoalsController < ApplicationController
  
  Comment_Page_Size = 100
  Goal_Page_Size = 15
  
  
  layout "community"
  
  before_filter :check_login, :only => [:new, :create, :edit, :update, :destroy,
                                        :categories, :category_new, :category_create,
                                        :category_edit, :category_update, :category_destroy,
                                        :create_evaluation, :delete_evaluation]
  before_filter :check_limited, :only => [:create, :update, :destroy,
                                          :category_create, :category_update, :category_destroy,
                                          :create_evaluation, :delete_evaluation]
  
  before_filter :check_editor, :only => [:edit, :update, :destroy,
                                          :categories, :category_new, :category_create,
                                          :category_edit, :category_update, :category_destroy]
                                          
  before_filter :check_evaluation_owner, :only => [:delete_evaluation]
  
  
  
  def index
    
  end
  
  def category
    
  end

  def show
    
  end
  
  
  private
  
  def is_editor?
    ApplicationController.helpers.info_editor?(session[:account_id])
  end
  
  def check_editor
    jump_to("/errors/forbidden") unless is_editor?
  end
  
end

