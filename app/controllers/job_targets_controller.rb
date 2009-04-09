class JobTargetsController < ApplicationController
  
  Closed_Target_Page_Size = 30
  
  layout "community"
  before_filter :check_current_account, :only => [:index]
  # generally, all action should require login to view
  before_filter :check_login #, :only => []
  before_filter :check_limited, :only => [:new_for_position, :create, :add_account_process, :add_steps,
                                          :adjust_step_order, :set_current_step, :update_step_label,
                                          :update_step_process, :update_step_status, :del_step,
                                          :create_step, :update_step_date, :update_step_remind_date,
                                          :create_account_process, :create_account_status, :close_target,
                                          :open_target, :destroy, :star_target, :unstar_target,
                                          :create_system_status, :status_update, :status_destroy,
                                          :create_system_process, :process_update, :process_destroy,
                                          :account_job_item_update, :account_job_item_destroy,
                                          :create_account_item, :update_target_job_item,
                                          :create_from_recruitment, :update_refer, :update_note]
  
  before_filter :check_account_access, :only => [:list, :list_closed, :account_status, :account_process,
                                                  :account_job_item, :calendar]
  before_filter :check_info_editor, :only => [:system_status, :create_system_status,
                                                :system_process, :create_system_process]
  before_filter :check_status_change, :only => [:status_update, :status_destroy]
  before_filter :check_process_change, :only => [:process_update, :process_destroy]
  before_filter :check_account_job_item_change, :only => [:account_job_item_update, :account_job_item_destroy]
  
  before_filter :check_target_owner, :only => [:add_steps, :adjust_step_order, :set_current_step,
                                                :update_step_label, :update_step_process,
                                                :update_step_status, :del_step, :create_step,
                                                :update_step_date, :update_step_remind_date,
                                                :close_target, :open_target, :destroy, :star_target,
                                                :unstar_target,
                                                :edit_target_job_item, :update_target_job_item,
                                                :recruitments, :exps,
                                                :edit_refer, :update_refer, :edit_note, :update_note]
  

  
  # ! current account needed !
  def index
    jump_to("/job_targets/list/#{session[:account_id]}")
  end
  
  def list
    @targets = JobTarget.unclosed.find(
      :all,
      :conditions => ["account_id = ?", session[:account_id]],
      :include => [:company, :job_position, :steps],
      :order => "created_at DESC"
    )
    
    @system_processes = JobProcess.get_system_processes
    @account_processes = JobProcess.get_account_processes(session[:account_id])
    
    @system_statuses = JobStatus.get_system_statuses
    @account_statuses = JobStatus.get_account_statuses(session[:account_id])
    
  end
  
  def list_closed
    @page = params[:page]
    @page = 1 unless @page =~ /\d+/
    @targets = JobTarget.closed.paginate(
      :page => @page,
      :per_page => Closed_Target_Page_Size,
      :conditions => ["account_id = ?", session[:account_id]],
      :include => [:company, :job_position, :steps],
      :order => "created_at DESC"
    )
  end
  
  def new
    @company_from = "system"
    
    @query = params[:query] && params[:query].strip
    if @query && @query != ""
      page = params[:page]
      page = 1 unless page =~ /\d+/
      @found_system_companies = Company.system.search(
        @query,
        :page => page,
        :per_page => JobItemsController::Item_Page_Size,
        :match_mode => JobItemsController::Search_Match_Mode,
        :order => JobItemsController::Search_Sort_Order,
        :field_weights => JobItemsController::Search_Field_Weights
      ).compact
    end
  end
  
  def new_for_position
    company_id = (params[:company_id] && params[:company_id].strip) || session[:new_target_company_id]
    
    if company_id && company_id != ""
      company = Company.get_company(company_id)
      return jump_to("/errors/forbidden") unless company && (company.account_id.nil? || company.account_id == 0 || company.account_id == session[:account_id])
    else
      @company_name = (params[:new_company_name] && params[:new_company_name].strip) || ""
      @company_desc = params[:new_company_desc] && params[:new_company_desc].strip
      
      company = Company.find(
        :first,
        :conditions => ["LOWER(name) = ? and account_id = ?", @company_name.downcase, session[:account_id]]
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
    
    @query = params[:query] && params[:query].strip
    if @query && @query != ""
      page = params[:page]
      page = 1 unless page =~ /\d+/
      @found_system_job_positions = JobPosition.system.search(
        @query,
        :page => page,
        :per_page => JobItemsController::Item_Page_Size,
        :match_mode => JobItemsController::Search_Match_Mode,
        :order => JobItemsController::Search_Sort_Order,
        :field_weights => JobItemsController::Search_Field_Weights
      ).compact
    end
    
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
      @position_name = (params[:new_position_name] && params[:new_position_name].strip) || ""
      @position_desc = params[:new_position_desc] && params[:new_position_desc].strip
      
      position = JobPosition.find(
        :first,
        :conditions => ["LOWER(name) = ? and account_id = ?", @position_name.downcase, session[:account_id]]
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
    
    
    jump_to("/job_targets/list/#{session[:account_id]}") unless @target.save # should never happen normally ...
    
  end
  
  def create_from_recruitment
    recruitment_name = params[:recruitment_title] && params[:recruitment_title].strip
    recruitment_id = params[:recruitment_id] && params[:recruitment_id].strip
    
    target = JobTarget.new(
      :company_id => Company::Null_Record_ID,
      :job_position_id => JobPosition::Null_Record_ID,
      :account_id => session[:account_id],
      :closed => false
    )
    
    target.fill_info(
      {
        :refer_name => recruitment_name,
        :refer_url => "/recruitments/#{recruitment_id}"
      }
    )
    
    target.save
    
    add_default_steps_to_target(target)
    
    jump_to("/job_targets/list/#{session[:account_id]}")
  end
  
  
  def add_account_process
    process_name = params[:new_process_name] && params[:new_process_name].strip
    
    @process = JobProcess.new(
      :account_id => session[:account_id],
      :name => process_name
    )
    
    @saved = @process.save
    
  end
  
  def create_account_process
    process_name = params[:process_name] && params[:process_name].strip
    
    process = JobProcess.new(
      :account_id => session[:account_id],
      :name => process_name
    )
    
    if process.save
      render(:layout => false, :text => process.id.to_s)
    else
      render(:layout => false, :text => "false")
    end
  end
  
  def create_account_status
    status_name = params[:status_name] && params[:status_name].strip
    status_color = params[:status_color] && params[:status_color].strip
    
    status = JobStatus.new(
      :account_id => session[:account_id],
      :name => status_name,
      :color => status_color
    )
    
    if status.save
      render(:layout => false, :text => status.id.to_s)
    else
      render(:layout => false, :text => "false")
    end
  end
  
  def add_steps
    step_timestamps = params.keys.select { |key|
      key =~ /step_\d+_process_id/
    }.collect { |k|
      k.scan(/step_(\d+)_process_id/)[0][0].to_i
    }.sort
    
    step_order = []
    step_timestamps.each do |step_timestamp|
      step_process_id = params["step_#{step_timestamp}_process_id".to_sym]
      process = JobProcess.get_process(step_process_id)
      
      if process && (process.account_id.nil? || process.account_id == 0 || process.account_id == session[:account_id])
      
        step_label = params["step_#{step_timestamp}_label".to_sym]
      
        step = JobStep.new(
          :job_target_id => @target.id,
          :account_id => session[:account_id],
          :job_process_id => step_process_id,
          :label => step_label
        )
      
        step_order << step.id if step.save
        
      end
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
  
  def adjust_step_order
    moved_step_id = params[:moved_step_id] && params[:moved_step_id].strip
    des_step_id = params[:des_step_id] && params[:des_step_id].strip
    
    step_order = @target.get_info[:step_order]
    des_index = step_order.index(des_step_id.to_i)
    
    moved_step_id_int = moved_step_id.to_i
    if des_index
      new_step_order = []
      step_order.each_index do |i|
        new_step_order << moved_step_id_int if i == des_index
        
        step_id = step_order[i]
        new_step_order << step_id unless step_id == moved_step_id_int
      end
      
      @target.update_info(
        {
          :step_order => new_step_order
        }
      )
      return render(:layout => false, :text => @target.save.to_s)
    end
    
    render :layout => false, :text => "false"
  end
  
  def set_current_step
    step_id = params[:step_id] && params[:step_id].strip
    
    unless step_id && step_id != ""
      # to clear the current step of target
      @target.current_job_step_id = nil
      return render(:layout => false, :text => @target.save.to_s)
    end
    
    step = JobStep.get_step(step_id)
    
    if (step.account_id == session[:account_id]) && step.job_target_id == @target.id
      @target.current_job_step_id = step_id
    
      return render(:layout => false, :text => @target.save.to_s)
    end
    
    render :layout => false, :text => "false"
  end
  
  def update_step_label
    step_id = params[:step_id] && params[:step_id].strip
    new_label = params[:label] && params[:label].strip
    
    step = JobStep.get_step(step_id)
    
    if (step.account_id == session[:account_id]) && step.job_target_id == @target.id
      step.label = new_label
    
      return render(:layout => false, :text => step.save.to_s)
    end
    
    render :layout => false, :text => "false"
  end
  
  def update_step_process
    step_id = params[:step_id] && params[:step_id].strip
    new_process_id = params[:process_id] && params[:process_id].strip
    
    step = JobStep.get_step(step_id)
    
    if (step.account_id == session[:account_id]) && step.job_target_id == @target.id
      process = JobProcess.get_process(new_process_id)
      if process.account_id.nil? || process.account_id == 0 || process.account_id == session[:account_id]
        step.job_process_id = process.id
    
        return render(:layout => false, :text => step.save.to_s)
      end
    end
    
    render :layout => false, :text => "false"
  end

  def update_step_status
    step_id = params[:step_id] && params[:step_id].strip
    new_status_id = params[:status_id] && params[:status_id].strip
    
    step = JobStep.get_step(step_id)
    
    if (step.account_id == session[:account_id]) && step.job_target_id == @target.id
      unless new_status_id && new_status_id != ""
        # to clear the status of step
        step.job_status_id = nil
        return render(:layout => false, :text => step.save.to_s)
      end
      
      status = JobStatus.get_status(new_status_id)
      if status.account_id.nil? || status.account_id == 0 || status.account_id == session[:account_id]
        step.job_status_id = status.id
    
        return render(:layout => false, :text => step.save.to_s)
      end
      
    end
    
    render :layout => false, :text => "false"
  end
  
  def del_step
    step_id = params[:step_id] && params[:step_id].strip
    
    step = JobStep.get_step(step_id)
    int_step_id = step.id
    
    step.destroy
    
    step_order = @target.get_info[:step_order]
    step_order.delete(int_step_id)
    @target.update_info(
      {
        :step_order => step_order
      }
    )
    @target.current_job_step_id = nil if int_step_id == @target.current_job_step_id
    @target.save
    
    render :layout => false, :text => "true"
  end
  
  def create_step
    process_id = params[:process_id] && params[:process_id].strip
    label = params[:label] && params[:label].strip

    process = JobProcess.get_process(process_id)
    
    if process.account_id.nil? || process.account_id == 0 || process.account_id == session[:account_id]
      step = JobStep.new(
        :job_target_id => @target.id,
        :account_id => session[:account_id],
        :job_process_id => process.id,
        :label => label
      )
      
      saved = step.save
      
      if saved
        step_order = @target.get_info[:step_order] || []
        step_order << step.id
        @target.update_info(
          {
            :step_order => step_order
          }
        )
        @target.save
      end
  
      return render(:partial => "step", :locals => {:step => step, :target => @target, :process => process}) if saved
    end
    
    render :layout => false, :text => "false"
  end
  
  def update_step_date
    step_id = params[:step_id] && params[:step_id].strip
    at = params[:at] && params[:at].strip
    new_date = params[:date] && params[:date].strip
    
    step = JobStep.get_step(step_id)
    
    if (step.account_id == session[:account_id]) && step.job_target_id == @target.id
      step.send("#{at == "begin" ? "begin_at" : "end_at"}=", new_date)
    
      return render(:layout => false, :text => step.save.to_s)
    end
    
    render :layout => false, :text => "false"
  end
  
  def update_step_remind_date
    step_id = params[:step_id] && params[:step_id].strip
    remind_date = params[:date] && params[:date].strip
    
    step = JobStep.get_step(step_id)
    
    if (step.account_id == session[:account_id]) && step.job_target_id == @target.id
      step.remind_at = remind_date
    
      return render(:layout => false, :text => step.save.to_s)
    end
    
    render :layout => false, :text => "false"
  end
  
  def close_target
    @target.closed = true
    
    render(:layout => false, :text => @target.save.to_s)
  end
  
  def open_target
    @target.closed = false
    @target.save
    
    page = params[:page] && params[:page].strip
    
    jump_to("/job_targets/list_closed/#{session[:account_id]}/#{page}")
  end
  
  def destroy
    @target.destroy
    
    page = params[:page] && params[:page].strip
    
    jump_to("/job_targets/list_closed/#{session[:account_id]}/#{page}")
  end
  
  def star_target
    @target.starred = true
    
    render(:layout => false, :text => @target.save.to_s)
  end
  
  def unstar_target
    @target.starred = false
    
    render(:layout => false, :text => @target.save.to_s)
  end
  
  
  def system_status
    @statuses = JobStatus.get_system_statuses
    
    render(:action => "status_list")
  end
  
  def account_status
    @statuses = JobStatus.get_account_statuses(@account_id)
    
    render(:action => "status_list")
  end
  
  def status_update
    @status.name = params[:status_name] && params[:status_name].strip
    @status.color = params[:status_color]
    @status.save
    
    jump_to(@is_account_status ? "/job_targets/account_status/#{session[:account_id]}" : "/job_targets/system_status")
  end
  
  def status_destroy
    @status.destroy
    
    jump_to(@is_account_status ? "/job_targets/account_status/#{session[:account_id]}" : "/job_targets/system_status")
  end
  
  def create_system_status
    status = JobStatus.new(:account_id => 0)
    
    status.name = params[:status_name] && params[:status_name].strip
    status.color = params[:status_color]
    
    status.save
    
    jump_to("/job_targets/system_status")
  end
  
  def system_process
    @processes = JobProcess.get_system_processes
    
    render(:action => "process_list")
  end
  
  def account_process
    @processes = JobProcess.get_account_processes(@account_id)
    
    render(:action => "process_list")
  end
  
  def process_update
    @process.name = params[:process_name] && params[:process_name].strip
    @process.save
    
    jump_to(@is_account_process ? "/job_targets/account_process/#{session[:account_id]}" : "/job_targets/system_process")
  end
  
  def process_destroy
    # @process.destroy
    # currently set to only allow to destroy account process
    @process.destroy if @is_account_process
    
    jump_to(@is_account_process ? "/job_targets/account_process/#{session[:account_id]}" : "/job_targets/system_process")
  end
  
  def create_system_process
    process = JobProcess.new(:account_id => 0)
    
    process.name = params[:process_name] && params[:process_name].strip
    
    process.save
    
    jump_to("/job_targets/system_process")
  end
  
  def account_job_item
    @item_type = params[:item_type]
    @item_label = get_job_item_label(@item_type)
        
    @items = @item_type.camelize.constantize.send("get_account_#{@item_type.pluralize}", @account_id)
  end
  
  def account_job_item_update
    @item.name = params[:item_name] && params[:item_name].strip
    @item.desc = params[:item_desc] && params[:item_desc].strip
    @item.save
    
    jump_to("/job_targets/account_job_item/#{@item.account_id}?item_type=#{@item_type}")
  end
  
  def account_job_item_destroy
    # check there is no job target using this item(company or job position)
    target_count = JobTarget.count(
      :conditions => ["#{@item_type}_id = ?", @item.id]
    )
    
    item_account_id = @item.account_id
    
    if target_count > 0
      # just set warning message
      item_label = get_job_item_label(@item_type)
      flash[:error_msg] = "删除#{item_label}失败... 还有 #{target_count} 条求职目标与此#{item_label}相关联. 只能删除已经不与任何求职目标关联的#{item_label}."
    else
      # do destroy
      @item.destroy
    end
    
    jump_to("/job_targets/account_job_item/#{item_account_id}?item_type=#{@item_type}")
  end
  
  def create_account_item
    @item_type = params[:item_type]
    item = @item_type.camelize.constantize.new(
      :account_id => session[:account_id],
      :name => params[:item_name] && params[:item_name].strip,
      :desc => params[:item_desc] && params[:item_desc].strip
    )
    
    item.save
    
    flash[:error_msg] = ApplicationController.helpers.list_model_validate_errors(item) if (item.errors.size > 0)
    
    jump_to("/job_targets/account_job_item/#{session[:account_id]}?item_type=#{@item_type}")
  end
  
  
  def edit_target_job_item
    @item_type = params[:item_type]
    @item_label = get_job_item_label(@item_type)
    
    @company = Company.get_company(@target.company_id)
    @position = JobPosition.get_position(@target.job_position_id)
    
    @query = params[:query]
    item_class = @item_type.camelize.constantize
    if @query && @query != ""
      page = params[:page]
      page = 1 unless page =~ /\d+/
      @found_system_companies = item_class.system.search(
        @query,
        :page => page,
        :per_page => JobItemsController::Item_Page_Size,
        :match_mode => JobItemsController::Search_Match_Mode,
        :order => JobItemsController::Search_Sort_Order,
        :field_weights => JobItemsController::Search_Field_Weights
      ).compact
    end

    @account_items = item_class.send("get_account_#{@item_type.pluralize}", session[:account_id])
  end
  
  def update_target_job_item
    item_type = params[:item_type]
    item_id = params[:item_id]
    
    item = item_type.camelize.constantize.send("get_#{item_type}", item_id)
    
    # check if new job item can be used by target owner
    if item.account_id.nil? || (item.account_id == 0) || item.account_id == @target.account_id
      @target.send("#{item_type}_id=", item.id)
      @target.save
    end
    
    jump_to("/job_targets/list/#{@target.account_id}")
  end
  
  
  def recruitments
    @company_name = JobTargetsController.helpers.get_target_company_name(@target)
    @target_name = JobTargetsController.helpers.append_job_position_name(@company_name, JobPosition.get_job_position(@target.job_position_id))
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    
    if @company_name && @company_name.strip != ""
      
      @recruitments = Recruitment.search(
        @company_name,
        :page => page,
        :per_page => 50,
        :match_mode => CommunityController::Search_Match_Mode,
        :order => "publish_time DESC, @relevance DESC",
        :field_weights => {
          :title => 8,
          :content => 8,
          :location => 6,
          :recruitment_tags_name => 8
        },
        :include => [:recruitment_tags]
      ).compact
      
    else
      
      @recruitments = []
      
    end
  end
  
  def exps
    @company_name = JobTargetsController.helpers.get_target_company_name(@target)
    @target_name = JobTargetsController.helpers.append_job_position_name(@company_name, JobPosition.get_job_position(@target.job_position_id))
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    
    if @company_name && @company_name.strip != ""
      @exps = Exp.search(
        @company_name,
        :page => page,
        :per_page => 30,
        :match_mode => CommunityController::Search_Match_Mode,
        :order => "publish_time DESC, @relevance DESC",
        :field_weights => {
          :title => 4,
          :content => 3,
        }
      ).compact
    else
      
      @exps = []
      
    end
  end
  
  
  def edit_refer
    
  end
  
  def update_refer
    refer_name = params[:refer_name] && params[:refer_name].strip
    
    @target.update_info(
      {
        :refer_name => refer_name
      }
    ) 
    
    @target.save
    
    jump_to("/job_targets/list/#{session[:account_id]}")
  end
  
  
  def edit_note
    @target_name = JobTargetsController.helpers.get_target_name(@target)
    
    @note = @target.note || JobTargetNote.new(:job_target_id => @target.id)
  end
  
  def update_note
    edit_note
    
    @note.content = params[:note_content] && params[:note_content].strip
    
    if @note.save
      flash.now[:message] = "已成功保存"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end

    render :action => "edit_note"
  end
  
  
  def calendar
    month = params[:month]
    
    d = month ? Date.parse("#{month}01") : Date.today
    
    
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
  
  def check_info_editor
    jump_to("/errors/forbidden") unless ApplicationController.helpers.info_editor?(session[:account_id])
  end
  
  def check_status_change
    status_id = params[:id]
    
    @status = JobStatus.get_status(status_id)
    status_account_id = @status.account_id
    
    valid = false
    @is_account_status = status_account_id && (status_account_id > 0)
    if @is_account_status
      # account status ...
      valid = (session[:account_id] == status_account_id)
    else
      # system status ...
      valid = ApplicationController.helpers.info_editor?(session[:account_id])
    end
    
    return jump_to("/errors/forbidden") unless valid
  end
  
  def check_process_change
    process_id = params[:id]
    
    @process = JobProcess.get_process(process_id)
    process_account_id = @process.account_id
    
    valid = false
    @is_account_process = process_account_id && (process_account_id > 0)
    if @is_account_process
      # account process ...
      valid = (session[:account_id] == process_account_id)
    else
      # system process ...
      # valid = ApplicationController.helpers.info_editor?(session[:account_id])
      valid = ApplicationController.helpers.superadmin?(session[:account_id])
    end
    
    return jump_to("/errors/forbidden") unless valid
  end
  
  def check_account_job_item_change
    @item_type = params[:item_type]

    item_id = params[:id]
    @item = @item_type.camelize.constantize.send("get_#{@item_type}", item_id)
    
    jump_to("/errors/forbidden") unless @item.account_id == session[:account_id]
  end
  
  def get_job_item_label(item_type)
    case item_type
      when "company"
        "公司"
      when "job_position"
        "职位"
      else
        nil
    end
  end
  
  def add_default_steps_to_target(target)
    step_order = target.get_info[:step_order] || []
    
    
    resume_process = JobProcess.get_system_process_by_name("简历")
    if resume_process
      resume_step = JobStep.new(
        :job_target_id => target.id,
        :account_id => session[:account_id],
        :job_process_id => resume_process.id,
        :label => ""
      )
      step_order << resume_step.id if resume_step.save
    end
    
    interview_process = JobProcess.get_system_process_by_name("面试")
    if interview_process
      interview1_step = JobStep.new(
        :job_target_id => target.id,
        :account_id => session[:account_id],
        :job_process_id => interview_process.id,
        :label => "一面"
      )
      step_order << interview1_step.id if interview1_step.save
      
      interview2_step = JobStep.new(
        :job_target_id => target.id,
        :account_id => session[:account_id],
        :job_process_id => interview_process.id,
        :label => "终面"
      )
      step_order << interview2_step.id if interview2_step.save
    end
    
    
    target.update_info(
      {
        :step_order => step_order
      }
    )
    target.save
  end
  
end


