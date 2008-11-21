class JobTargetsController < ApplicationController
  
  layout "community"
  before_filter :check_current_account, :only => [:index]
  # generally, all action should require login to view
  before_filter :check_login #, :only => [:list]
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
  
  def new
    @company_from = "system"
  end
  
  def new_for_position
    company_id = params[:company_id] && params[:company_id].strip
    
    if company_id && company_id != ""
      company = Company.get_company(company_id)
      return jump_to("/errors/forbidden") unless company && (company.account_id.nil? || company.account_id == 0 || company.account_id == session[:account_id])
    else
      @company_name = params[:new_company_name] && params[:new_company_name].strip
      @company_desc = params[:new_company_desc] && params[:new_company_desc].strip
      
      company = Company.new(
        :name => @company_name,
        :desc => @company_desc,
        :account_id => session[:account_id]
      )
      
      unless company.save
        @company_from = "new"
        flash.now[:error_msg] = %Q!
          操作失败, 再试一次吧
          <br />
          #{ApplicationController.helpers.list_model_validate_errors(company)}
        !
        return render(:action => "new")
      end
    end
    
    session[:new_target_company_id] = company.id
    session[:new_target_company_name] = company.name
    
    @position_from = "system"
    
  end
  
  def new_for_steps
    
  end
  
  
  
  private
  
  def check_list_access
    @account_id = params[:id]
    jump_to("/errors/forbidden") unless session[:account_id].to_s == @account_id
  end
  
  
end


