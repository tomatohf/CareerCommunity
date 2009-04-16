class JobServicesController < ApplicationController
  
  Top_List_Num = 8
  
  Evaluation_Page_Size = 15
  
  Rank_Titles = [
    "1分",
    "2分",
    "3分",
    "4分",
    "5分"
  ]
  
  
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
  
  before_filter :check_service_url, :only => [:url_preview]
  
  
  
  def index
    @categories = JobServiceCategory.get_all_categories
  end
  
  def category
    @category = JobServiceCategory.get_category(params[:id])
    
    query = "SELECT job_services.id, name, url, AVG(job_service_evaluations.point) as average"
    query << " FROM job_services LEFT OUTER JOIN job_service_evaluations"
    query << " ON job_services.id = job_service_evaluations.job_service_id"
    query << " WHERE job_services.category_id = #{@category.id}"
    query << " GROUP BY job_service_evaluations.job_service_id"
    query << " ORDER BY average DESC"
    
    @category_services = JobService.find_by_sql(query)
  end

  def show
    @service = JobService.find(params[:id])
    
    @creator_nick_pic = Account.get_nick_and_pic(@service.creator_id)
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @service_evaluations = @service.evaluations.paginate(
      :page => page,
      :per_page => Evaluation_Page_Size,
      :total_entries => JobServiceEvaluation.get_count(@service.id),
      :include => [:account => [:profile_pic]],
      :order => "updated_at DESC"
    )
    
    @point = JobServiceEvaluation.average(
      "point",
      :conditions => ["job_service_id = ?", @service.id]
    ) || 0
  end
  
  def url_preview
    render :layout => "empty"
  end
  
  def url_preview_top
    @service = JobService.find(params[:id])
    
    render :layout => "empty"
  end
  
  def new
    @service = JobService.new
  end
  
  def create
    @service = JobService.new(
      :creator_id => session[:account_id],
      :updater_id => session[:account_id]
    )
    
    @service.name = params[:service_name] && params[:service_name].strip
    @service.category_id = params[:service_category] && params[:service_category].strip
    
    @service.url = params[:service_url] && params[:service_url].strip
    @service.place = params[:service_place] && params[:service_place].strip
    @service.phone = params[:service_phone] && params[:service_phone].strip
    
    if @service.save
      jump_to("/job_services/#{@service.id}")
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
    
    @service.updater_id = session[:account_id]
    
    @service.name = params[:service_name] && params[:service_name].strip
    @service.category_id = params[:service_category] && params[:service_category].strip
    
    @service.url = params[:service_url] && params[:service_url].strip
    @service.place = params[:service_place] && params[:service_place].strip
    @service.phone = params[:service_phone] && params[:service_phone].strip
    
    @service.scope = params[:service_scope] && params[:service_scope].strip
    @service.cost = params[:service_cost] && params[:service_cost].strip
    @service.desc = params[:service_desc] && params[:service_desc].strip
    
    if @service.save
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
  
  
  def create_evaluation
    job_service_id = params[:id]
    account_id = session[:account_id]
    
    evaluation = JobServiceEvaluation.find(
      :first,
      :conditions => ["job_service_id = ? and account_id = ?", job_service_id, account_id]
    ) || JobServiceEvaluation.new(
      :job_service_id => job_service_id,
      :account_id => account_id
    )  
    
    evaluation.content = params[:service_evaluation] && params[:service_evaluation].strip
    evaluation.point = params[:service_evaluation_point] && params[:service_evaluation_point].strip
    
    evaluation_saved = evaluation.save
    
    total_count = JobServiceEvaluation.get_count(evaluation.job_service_id)
    last_page = total_count > 0 ? (total_count.to_f/Evaluation_Page_Size).ceil : 1
    
    jump_to("/job_services/#{evaluation.job_service_id}/evaluation/#{last_page}#{"#evaluation_#{evaluation.id}" if evaluation_saved}")
  end
  
  def delete_evaluation
    @evaluation ||= JobServiceEvaluation.find(params[:id])
    
    @evaluation.destroy
    
    jump_to("/job_services/#{@evaluation.job_service_id}")
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
  
  def check_evaluation_owner
    valid = is_editor?
    
    unless valid
      @evaluation = JobServiceEvaluation.find(params[:id])
      valid = (session[:account_id] == @evaluation.account_id)
    end

    jump_to("/errors/forbidden") unless valid
  end
  
  def check_service_url
    @service = JobService.find(params[:id])
    
    jump_to("/job_services/#{@service.id}") unless @service.url && (@service.url != "")
  end
  
end

