class JobTargetsController < ApplicationController
  
  layout "community"
  before_filter :check_current_account, :only => [:index]
  # generally, all action should require login to view
  before_filter :check_login #, :only => [:list]
  before_filter :check_limited, :only => [:new_for_position, :create, :add_account_process, :add_steps,
                                          ]
  
  before_filter :check_account_access, :only => [:list]
  before_filter :check_target_owner, :only => [:add_steps]
  

  
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
      
      company = Company.find(
        :first,
        :conditions => ["name = ? and account_id = ?", @company_name, session[:account_id]]
      ) || Company.new(
        :name => @company_name,
        :account_id => session[:account_id]
      )
      
      company.desc = @company_desc
      
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
    

    # Okay ... render next step
    session[:new_target_company_id] = company.id
    session[:new_target_company_name] = company.name
    
    @position_from = "system"
    
  end
  
  def create
    jump_to("/job_targets/new") unless session[:new_target_company_id] &&
                      session[:new_target_company_id] > 0 &&
                      session[:new_target_company_name] &&
                      session[:new_target_company_name] != ""
    
    position_id = params[:position_id] && params[:position_id].strip
    
    if position_id && position_id != ""
      position = JobPosition.get_position(position_id)
      return jump_to("/errors/forbidden") unless position && (position.account_id.nil? || position.account_id == 0 || position.account_id == session[:account_id])
    else
      @position_name = params[:new_position_name] && params[:new_position_name].strip
      @position_desc = params[:new_position_desc] && params[:new_position_desc].strip
      
      position = JobPosition.find(
        :first,
        :conditions => ["name = ? and account_id = ?", @position_name, session[:account_id]]
      ) || JobPosition.new(
        :name => @position_name,
        :account_id => session[:account_id]
      )
      
      position.desc = @position_desc
      
      unless position.save
        @position_from = "new"
        flash.now[:error_msg] = %Q!
          操作失败, 再试一次吧
          <br />
          #{ApplicationController.helpers.list_model_validate_errors(position)}
        !
        return render(:action => "new_for_position")
      end
    end
    
    
    # Okay ... render next step
    @target = JobTarget.new(
      :company_id => session[:new_target_company_id],
      :job_position_id => position.id,
      :account_id => session[:account_id],
      :closed => false
    )
    
    
    jump_to("/job_targets/list/session[:account_id]") unless @target.save # should never happen normally ...
    
  end
  
  
  def add_account_process
    process_name = params[:new_process_name] && params[:new_process_name].strip
    
    @process = JobProcess.new(
      :account_id => session[:account_id],
      :name => process_name
    )
    
    @saved = @process.save
    
  end
  
  def add_steps
    step_timestamps = params.keys.select { |key|
      key =~ /step_\d+_process_id/
    }.collect { |k|
      k.scan(/step_(\d+)_process_id/)[0][0].to_i
    }.sort
    
    step_order = []
    step_timestamps.each do |step_timestamp|
      step_label = params["step_#{step_timestamp}_label".to_sym]
      step_process_id = params["step_#{step_timestamp}_process_id".to_sym]
      
      step = JobStep.new(
        :job_target_id => @target.id,
        :account_id => session[:account_id],
        :job_process_id => step_process_id,
        :label => step_label
      )
      
      step_order << step.id if step.save
    end
    
    # update the step_order of job target
    @target.update_info(
      {
        :step_order => step_order
      }
    )
    @target.save
    
    jump_to("/job_targets/list/#{session[:account_id]}")
    
  end
  
  
  
  private
  
  def check_account_access
    @account_id = params[:id]
    jump_to("/errors/forbidden") unless session[:account_id].to_s == @account_id
  end
  
  def check_target_owner
    @target_id = params[:id]
    @target = JobTarget.get_target(@target_id)
    jump_to("/errors/forbidden") unless @target.account_id == session[:account_id]
  end
  
  
end


