class JobServicesController < ApplicationController
  
  Top_List_Num = 8
  
  
  layout "community"
  
  before_filter :check_login, :only => [:new, :create, :edit, :update, :destroy,
                                        :categories, :category_new, :category_create,
                                        :category_edit, :category_update, :category_destroy]
  before_filter :check_limited, :only => [:create, :update, :destroy,
                                          :category_create, :category_update, :category_destroy]
  
  before_filter :check_editor, :only => [:edit, :update, :destroy,
                                          :categories, :category_new, :category_create,
                                          :category_edit, :category_update, :category_destroy]
  
  
  
  def index
    
  end
  
  def show
    
  end
  
  def new
    @service = JobService.new
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
    @service = JobService.find(params[:id])
  end
  
  def update
    @service = JobService.find(params[:id])
    
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
    service = JobService.find(params[:id])
    
    service.destroy
    
    jump_to("/job_services")
  end
  
  
  def categories
    @categories = JobServiceCategory.get_all_categories
  end
  
  def category_new
    @category = JobServiceCategory.new
  end
  
  def category_create
    @category = JobServiceCategory.new
    
    @category.name = params[:category_name] && params[:category_name].strip
    @category.desc = params[:category_desc] && params[:category_desc].strip
    
    if @category.save
      jump_to("/job_services/categories")
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
      render :action => "category_new"
    end
  end
  
  def category_edit
    @category = JobServiceCategory.get_category(params[:id])
  end
  
  def category_update
    @category = JobServiceCategory.get_category(params[:id])
    
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
    @category = JobServiceCategory.get_category(params[:id])
    
    # check that there is no service under this category
    service_count = JobService.count(:conditions => ["category_id = ?", @category.id])
    if service_count > 0
      # can NOT delete album
      flash[:error_msg] = "删除求职服务分类失败... 该分类中还包含 #{service_count} 个求职服务, 只能删除不包含求职服务的空分类"
    else
      @category.destroy
      flash[:message] = "已成功求职服务"
    end
    
    jump_to("/job_services/categories")
  end
  
  
  private
  
  def is_editor?
    ApplicationController.helpers.info_editor?(session[:account_id])
  end
  
  def check_editor
    jump_to("/errors/forbidden") unless is_editor?
  end
  
end

