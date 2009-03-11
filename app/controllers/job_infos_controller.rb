class JobInfosController < ApplicationController
  
  Info_Page_Size = 50
  
  Search_Match_Mode = CommunityController::Search_Match_Mode
  Search_Sort_Order = "@relevance DESC, created_at DESC"
  Search_Field_Weights = { :title => 3, :content => 2 }
  
  
  layout "community"
  
  before_filter :check_login
  before_filter :check_limited, :only => [:create, :update, :destroy,
                                          :category_create, :category_update, :category_destroy]
  
  before_filter :check_editor
  
  
  
  def index
    page = params[:page]
    page = 1 unless page =~ /\d+/
    
    @infos = JobInfo.paginate(
      :page => page,
      :per_page => Info_Page_Size,
      :select => "id, title, general, created_at",
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
  
  
  private
  
  def is_editor?
    ApplicationController.helpers.info_editor?(session[:account_id])
  end
  
  def check_editor
    jump_to("/errors/forbidden") unless is_editor?
  end
  
end

