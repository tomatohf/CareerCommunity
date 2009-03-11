class JobItemsController < ApplicationController
  
  Item_Page_Size = 50
  
  Search_Match_Mode = CommunityController::Search_Match_Mode
  Search_Sort_Order = "@relevance DESC, created_at DESC"
  Search_Field_Weights = { :name => 3, :desc => 2 }
  
  
  layout "community"
  
  before_filter :prepare_item_type
  
  before_filter :check_login
  before_filter :check_limited, :only => [:create, :update, :destroy,
                                          :add_company_industry, :del_company_industry,
                                          :add_job_position_info_item, :del_job_position_info_item,
                                          :info_create, :info_update, :info_destroy]
  
  before_filter :check_editor
  
  
  
  def index
    @item_label = get_item_label
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    
    options = {
      :page => page,
      :per_page => Item_Page_Size,
      :order => "created_at DESC"
    }
    
    options[:include] = [:industries] if (@item_type == "company")
    
    @items = get_item_class.system.paginate(options)
  end
  
  def show
    @item_label = get_item_label
    @item = get_item_instance(params[:id])
  end
  
  def new
    @item_label = get_item_label
    @item = get_item_class.new
  end
  
  def create
    @item_label = get_item_label
    @item = get_item_class.new
    
    @item.account_id = 0
    # added by system
    
    @item.name = params[:item_name] && params[:item_name].strip
    @item.desc = params[:item_desc] && params[:item_desc].strip
    
    if @item.save
      jump_to("/#{@item_type}/job_items")
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
      render :action => "new"
    end
  end
  
  def edit
    @item_label = get_item_label
    @item = get_item_instance(params[:id])
  end
  
  def update
    @item_label = get_item_label
    @item = get_item_instance(params[:id])
    
    @item.account_id = 0
    # added by system
    
    @item.name = params[:item_name] && params[:item_name].strip
    @item.desc = params[:item_desc] && params[:item_desc].strip
    
    if @item.save
      flash.now[:message] = "已成功保存"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end

    render :action => "edit"
  end
  
  #def destroy
  #  @item = get_item_instance(params[:id])
  #  @item.destroy
  #  
  #  jump_to("/#{@item_type}/job_items")
  #end
  
  def search
    @item_tip = params[:item_tip] && params[:item_tip].strip
    
    return jump_to("/#{@item_type}/job_items") unless @item_tip && @item_tip.size > 0
    
    @item_label = get_item_label
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @items = get_item_class.system.search(
      @item_tip,
      :page => page,
      :per_page => Item_Page_Size,
      :match_mode => Search_Match_Mode,
      :order => Search_Sort_Order,
      :field_weights => Search_Field_Weights
    ).compact
  end
  
  def manage_company_industries
    @company = Company.get_company(params[:id])
    @company_industries = Industry.get_company_industries(@company.id) || []
    
    @query = params[:query] && params[:query].strip
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    
    if @query && @query != ""
      @industries = Industry.system.search(
        @query,
        :page => page,
        :per_page => JobItemsController::Item_Page_Size,
        :match_mode => JobItemsController::Search_Match_Mode,
        :order => JobItemsController::Search_Sort_Order,
        :field_weights => JobItemsController::Search_Field_Weights
      ).compact
    else
      @industries = Industry.system.find(
        :all,
        :limit => JobItemsController::Item_Page_Size,
        :order => "created_at DESC"
      )
    end
  end
  
  def add_company_industry
    company = Company.get_company(params[:id])
    industry = Industry.get_industry(params[:industry_id])
    
    company_industries = company.industries
    
    company_industries << industry unless company_industries.exists?(industry)
    
    jump_to("/company/job_items/#{company.id}/manage_company_industries")
  end
  
  def del_company_industry
    company = Company.get_company(params[:id])
    industry = Industry.get_industry(params[:industry_id])
    
    company.industries.delete(industry)
    
    jump_to("/company/job_items/#{company.id}/manage_company_industries")
  end
  
  
  def info
    @item_label = get_item_label
    @item = get_item_instance(params[:id])
    
    @infos = get_item_info_class.send("get_#{@item_type}_infos_title", @item.id)
    
    JobPositionInfo.load_industries_and_companies(@infos) if (@item_type == "job_position")
  end
  
  def info_new
    @item_label = get_item_label
    @item = get_item_instance(params[:id])
    
    @info = get_item_info_class.new
  end
  
  def info_create
    item_id = params[:id]
    
    @info = get_item_info_class.new(
      :creator_id => session[:account_id],
      :updater_id => session[:account_id],
      :title => params[:info_title] && params[:info_title].strip,
      :content => params[:info_content] && params[:info_content].strip
    )
    
    @info.send("#{@item_type}_id=", item_id)
    
    if @info.save
      jump_to("/#{@item_type}/job_items/#{item_id}/info")
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
      
      @item_label = get_item_label
      @item = get_item_instance(params[:id])
      
      render :action => "info_new"
    end
  end
  
  def info_edit
    @info = get_item_info_class.find(params[:id])
    
    @item_label = get_item_label
    @item = get_item_instance(@info.send("#{@item_type}_id"))
  end
  
  def info_update
    @info = get_item_info_class.find(params[:id])
    
    @info.title = params[:info_title] && params[:info_title].strip
    @info.content = params[:info_content] && params[:info_content].strip
    
    @info.updater_id = session[:account_id]
    
    item_id = @info.send("#{@item_type}_id")
    
    if @info.save
      jump_to("/#{@item_type}/job_items/#{item_id}/info")
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
      
      @item_label = get_item_label
      @item = get_item_instance(item_id)
      
      render :action => "info_edit"
    end
  end
  
  def info_destroy
    @info = get_item_info_class.find(params[:id])
    item_id = @info.send("#{@item_type}_id")
    
    @info.destroy
    
    jump_to("/#{@item_type}/job_items/#{item_id}/info")
  end
  
  
  def manage_job_position_info_items
    @info = JobPositionInfo.find(params[:id])
    
    @item_label = get_item_label
    
    @query = params[:query] && params[:query].strip
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    
    if @query && @query != ""
      @items = get_item_class.system.search(
        @query,
        :page => page,
        :per_page => JobItemsController::Item_Page_Size,
        :match_mode => JobItemsController::Search_Match_Mode,
        :order => JobItemsController::Search_Sort_Order,
        :field_weights => JobItemsController::Search_Field_Weights
      ).compact
    else
      @items = get_item_class.system.find(
        :all,
        :limit => JobItemsController::Item_Page_Size,
        :order => "created_at DESC"
      )
    end
  end
  
  def add_job_position_info_item
    info = JobPositionInfo.find(params[:id])
    item = get_item_instance(params[:item_id])
    
    info_items = info.send(@item_type.pluralize)
    
    info_items << item unless info_items.exists?(item)
    
    jump_to("/job_position/job_items/#{info.job_position_id}/info")
  end
  
  def del_job_position_info_item
    info = JobPositionInfo.find(params[:id])
    item = get_item_instance(params[:item_id])
    
    info.send(@item_type.pluralize).delete(item)
    
    jump_to("/job_position/job_items/#{info.job_position_id}/info")
  end
  
  
  private
  
  def prepare_item_type
    @item_type = params[:item_type]
  end
  
  
  def get_item_class
    @item_type.camelize.constantize
  end
  
  def get_item_info_class
    "#{@item_type}_info".camelize.constantize
  end
  
  def get_item_label
    case @item_type
      when "company"
        "公司"
      when "job_position"
        "职位"
      when "industry"
        "行业"
      else
        nil
    end
  end
  
  def get_item_instance(id)
    get_item_class.send("get_#{@item_type}", id)
  end
  
  
  def is_editor?
    ApplicationController.helpers.info_editor?(session[:account_id])
  end
  
  def check_editor
    jump_to("/errors/forbidden") unless is_editor?
  end
  
end

