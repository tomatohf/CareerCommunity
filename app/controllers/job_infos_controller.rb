class JobInfosController < ApplicationController
  
  Info_Page_Size = 50
  
  Search_Match_Mode = CommunityController::Search_Match_Mode
  Search_Sort_Order = "@relevance DESC, created_at DESC"
  Search_Field_Weights = { :title => 3, :content => 2 }
  
  
  layout "community"
  
  before_filter :check_login
  before_filter :check_limited, :only => [:create, :update, :destroy,
                                          :category_create, :category_update, :category_destroy,
                                          :add_job_item, :del_job_item,
                                          :add_job_process, :del_job_process,
                                          :add_category, :del_category]
  
  before_filter :check_editor
  
  
  
  def index
    page = params[:page]
    page = 1 unless page =~ /\d+/
    
    @infos = JobInfo.paginate(
      :page => page,
      :per_page => Info_Page_Size,
      :select => "id, title, general, created_at",
      :include => [:job_info_categories, :industries, :companies, :job_positions, :job_processes],
      :order => "created_at DESC"
    )
  end
  
  def search
    @info_tip = params[:info_tip] && params[:info_tip].strip
    
    return jump_to("/job_infos") unless @info_tip && @info_tip.size > 0
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @info_ids = JobInfo.search_for_ids(
      @info_tip,
      :page => page,
      :per_page => Info_Page_Size,
      :match_mode => Search_Match_Mode,
      :order => Search_Sort_Order,
      :field_weights => Search_Field_Weights
    ).compact
    
    @infos = JobInfo.find(
      :all,
      :limit => Info_Page_Size,
      :select => "id, title, general, created_at",
      :conditions => ["id in (?)", @info_ids],
      :include => [:job_info_categories, :industries, :companies, :job_positions, :job_processes],
      :order => "created_at DESC"
    )
  end
  
  def show
    
  end
  
  def new
    @info = JobInfo.new
  end
  
  def create
    @info = JobInfo.new(
      :creator_id => session[:account_id],
      :updater_id => session[:account_id]
    )
    
    @info.title = params[:info_title] && params[:info_title].strip
    @info.content = params[:info_content] && params[:info_content].strip
    
    @info.general = (params[:info_general] == "true")
    
    if @info.save
      jump_to("/job_infos")
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
      render :action => "new"
    end
  end
  
  def edit
    @info = JobInfo.find(params[:id])
  end
  
  def update
    @info = JobInfo.find(params[:id])
    
    @info.updater_id = session[:account_id]
    
    @info.title = params[:info_title] && params[:info_title].strip
    @info.content = params[:info_content] && params[:info_content].strip
    
    @info.general = (params[:info_general] == "true")
    
    if @info.save
      flash.now[:message] = "已成功保存"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end

    render :action => "edit"
  end
  
  def destroy
    info = JobInfo.find(params[:id])
    
    info.destroy
    
    jump_to("/job_infos")
  end
  
  
  def categories
    @categories = JobInfoCategory.get_all_categories
  end
  
  def category_new
    @category = JobInfoCategory.new
  end
  
  def category_create
    @category = JobInfoCategory.new
    
    @category.name = params[:category_name] && params[:category_name].strip
    @category.desc = params[:category_desc] && params[:category_desc].strip
    
    if @category.save
      jump_to("/job_infos/categories")
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
      render :action => "category_new"
    end
  end
  
  def category_edit
    @category = JobInfoCategory.get_category(params[:id])
  end
  
  def category_update
    @category = JobInfoCategory.get_category(params[:id])
    
    @category.name = params[:category_name] && params[:category_name].strip
    @category.desc = params[:category_desc] && params[:category_desc].strip
    
    if @category.save
      flash.now[:message] = "已成功保存"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end

    render :action => "category_edit"
  end
  
  def category_destroy
    @category = JobInfoCategory.get_category(params[:id])
    
    @category.destroy
    
    jump_to("/job_infos/categories")
  end
  
  
  def select_job_item
    @item_type = params[:type]
    @query = params[:query] && params[:query].strip
    
    @info = JobInfo.find(params[:id])
    
    @item_label = case @item_type
      when "company"
        "公司"
      when "job_position"
        "职位"
      when "industry"
        "行业"
      else
        nil
    end
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    
    if @query && @query != ""
      @items = @item_type.camelize.constantize.system.search(
        @query,
        :page => page,
        :per_page => JobItemsController::Item_Page_Size,
        :match_mode => JobItemsController::Search_Match_Mode,
        :order => JobItemsController::Search_Sort_Order,
        :field_weights => JobItemsController::Search_Field_Weights
      ).compact
    else
      @items = @item_type.camelize.constantize.system.find(
        :all,
        :limit => JobItemsController::Item_Page_Size,
        :order => "created_at DESC"
      )
    end
  end
  
  def add_job_item
    info = JobInfo.find(params[:id])
    
    item_type = params[:item_type]
    item_id = params[:item_id]
    
    item = item_type.camelize.constantize.send("get_#{item_type}", item_id)
    
    info_items = info.send(item_type.pluralize)
    
    info_items << item unless info_items.exists?(item)
    
    jump_to("/job_infos")
  end
  
  def del_job_item
    info = JobInfo.find(params[:id])
    
    item_type = params[:item_type]
    item_id = params[:item_id]
    
    item = item_type.camelize.constantize.send("get_#{item_type}", item_id)
    
    info.send(item_type.pluralize).delete(item)
    
    jump_to("/job_infos")
  end
  
  def add_job_process
    info = JobInfo.find(params[:id])
    
    job_process_id = params[:job_process_id]
    
    job_process = JobProcess.get_process(job_process_id)
    info_job_processes = info.job_processes
    info_job_processes << job_process unless info_job_processes.exists?(job_process)
    
    jump_to("/job_infos")
  end
  
  def del_job_process
    info = JobInfo.find(params[:id])
    
    job_process_id = params[:job_process_id]
    
    job_process = JobProcess.get_process(job_process_id)
    
    info.job_processes.delete(job_process)
    
    jump_to("/job_infos")
  end
  
  def add_category
    info = JobInfo.find(params[:id])
    
    category_id = params[:category_id]
    
    category = JobInfoCategory.get_category(category_id)
    info_categories = info.job_info_categories
    info_categories << category unless info_categories.exists?(category)
    
    jump_to("/job_infos")
  end
  
  def del_category
    info = JobInfo.find(params[:id])
    
    category_id = params[:category_id]
    
    category = JobInfoCategory.get_category(category_id)
    
    info.job_info_categories.delete(category)
    
    jump_to("/job_infos")
  end
  
  
  private
  
  def is_editor?
    ApplicationController.helpers.info_editor?(session[:account_id])
  end
  
  def check_editor
    jump_to("/errors/forbidden") unless is_editor?
  end
  
end

