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
                                          :info_create, :info_update, :info_destroy,
                                          :add_job_item, :del_job_item]
  
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
    @items = get_item_class.search(
      @item_tip,
      :page => page,
      :per_page => Item_Page_Size,
      :conditions => { :account_id => 0 },
      :match_mode => Search_Match_Mode,
      :order => Search_Sort_Order,
      :field_weights => Search_Field_Weights
    )
    @items.compact!
  end
  
  def manage_company_industries
    @company = Company.get_company(params[:id])
    @company_industries = Industry.get_company_industries(@company.id) || []
    
    @query = params[:query] && params[:query].strip
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    
    if @query && @query != ""
      @industries = Industry.search(
        @query,
        :page => page,
        :per_page => Item_Page_Size,
        :conditions => { :account_id => 0 },
        :match_mode => Search_Match_Mode,
        :order => Search_Sort_Order,
        :field_weights => Search_Field_Weights
      )
      @industries.compact!
    else
      @industries = Industry.system.find(
        :all,
        :limit => Item_Page_Size,
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
  
  
  
  def select_job_item
    @owner_type = params[:owner_type]
    @query = params[:query] && params[:query].strip
    
    @item_label = get_item_label
    
    @owner_handler = get_owner_handler(@owner_type)
    @owner = @owner_handler.get_owner(params[:id])
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    
    if @query && @query != ""
      @items = @item_type.camelize.constantize.search(
        @query,
        :page => page,
        :per_page => Item_Page_Size,
        :conditions => { :account_id => 0 },
        :match_mode => Search_Match_Mode,
        :order => Search_Sort_Order,
        :field_weights => Search_Field_Weights
      )
      @items.compact!
    else
      @items = @item_type.camelize.constantize.system.find(
        :all,
        :limit => Item_Page_Size,
        :order => "created_at DESC"
      )
    end
    
  end
  
  def add_job_item
    owner_id = params[:id]
    owner_type = params[:owner_type]
    item_id = params[:item_id]
    
    owner_handler = get_owner_handler(owner_type)
    
    item = @item_type.camelize.constantize.send("get_#{@item_type}", item_id)
    
    owner = owner_handler.get_owner(owner_id)
    owner_items = owner_handler.get_items(owner, @item_type)
    
    owner_items << item unless owner_items.exists?(item)
    
    jump_to(owner_handler.get_jump_url(owner))
  end
  
  def del_job_item
    owner_id = params[:id]
    owner_type = params[:owner_type]
    item_id = params[:item_id]
    
    owner_handler = get_owner_handler(owner_type)
    
    item = @item_type.camelize.constantize.send("get_#{@item_type}", item_id)
    
    owner = owner_handler.get_owner(owner_id)
    owner_handler.get_items(owner, @item_type).delete(item)
    
    jump_to(owner_handler.get_jump_url(owner))
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
  
  
  def get_owner_handler(owner_type)
    eval("Owners::#{owner_type.camelize}").instance
  end
  
  
  
  module Owners
    
    class Base
      include Singleton
      
      def get_owner(owner_id)
        nil
      end
      
      def get_label(owner)
        ""
      end
      
      def get_type_label
        ""
      end
      
      def get_return_text
        "返回"
      end
      
      def get_return_url(owner)
        "/community"
      end
      
      def get_items(owner, item_type)
        owner.send(item_type.pluralize)
      end
      
      def get_jump_url(owner)
        get_return_url(owner)
      end
    end
    
    class Talk < Base
      def get_owner(owner_id)
        ::Talk.get_talk(owner_id)
      end
      
      def get_label(owner)
        owner.get_title
      end
      
      def get_type_label
        "访谈录"
      end
      
      def get_return_text
        "返回管理访谈录"
      end
      
      def get_return_url(owner)
        "/talks/#{owner.id}/manage"
      end
    end
    
    class JobInfo < Base
      def get_owner(owner_id)
        ::JobInfo.find(owner_id)
      end
      
      def get_label(owner)
        owner.title
      end
      
      def get_type_label
        "求职信息"
      end
      
      def get_return_text
        "返回求职信息列表"
      end
      
      def get_return_url(owner)
        "/job_infos"
      end
    end
    
    class Recruitment < Base
      def get_owner(owner_id)
        ::Recruitment.find(owner_id)
      end
      
      def get_label(owner)
        owner.title
      end
      
      def get_type_label
        "招聘信息"
      end
      
      def get_return_text
        "返回招聘信息"
      end
      
      def get_return_url(owner)
        "/recruitments/#{owner.id}"
      end
    end
    
    class Exp < Base
      def get_owner(owner_id)
        ::Exp.find(owner_id)
      end
      
      def get_label(owner)
        owner.title
      end
      
      def get_type_label
        "面经"
      end
      
      def get_return_text
        "返回面经"
      end
      
      def get_return_url(owner)
        "/exps/#{owner.id}"
      end
    end
    
    class JobPositionInfo < Base
      def get_owner(owner_id)
        ::JobPositionInfo.find(owner_id)
      end
      
      def get_label(owner)
        owner.title
      end
      
      def get_type_label
        "职位信息"
      end
      
      def get_return_text
        "返回职位信息列表"
      end
      
      def get_return_url(owner)
        "/job_position/job_items/#{owner.job_position_id}/info"
      end
    end
    
  end
  
end

