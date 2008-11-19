class JobTargetsController < ApplicationController
  
  layout "community"
  before_filter :check_current_account, :only => [:index]
  before_filter :check_login, :only => [:list]
  before_filter :check_limited, :only => []
  
  before_filter :check_list_access, :only => [:list]
  

  
  # ! current account needed !
  def index
    jump_to("/job_targets/list/#{session[:account_id]}")
  end
  
  def list
    @edit = true
    
    @targets = JobTarget.find(
      :all,
      :conditions => ["account_id = ?", session[:account_id]],
      :include => [:company, :job_position, :steps],
      :order => "created_at DESC"
    )
    
  end
  
  
  
  private
  
  def check_list_access
    @account_id = params[:id]
    jump_to("/errors/forbidden") unless session[:account_id].to_s == @account_id
  end
  
  
end


