class JobItemsController < ApplicationController
  
  Item_Page_Size = 50
  
  Search_Match_Mode = CommunityController::Search_Match_Mode
  Search_Sort_Order = "@relevance DESC, created_at DESC"
  Search_Field_Weights = { :name => 3, :desc => 2 }
  
  
  layout "community"
  
  before_filter :prepare_item_type
  
  before_filter :check_login
  before_filter :check_limited, :only => [:create, :update, :destroy]
  
  before_filter :check_editor
  
  
  
  def index
    @item_label = get_item_label
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @items = get_item_class.system.paginate(
      :page => page,
      :per_page => Item_Page_Size,
      :order => "created_at DESC"
    )
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
  
  def destroy
    @item = get_item_instance(params[:id])
    @item.destroy
    
    jump_to("/#{@item_type}/job_items")
  end
  
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
  
  
  private
  
  def prepare_item_type
    @item_type = params[:item_type]
  end
  
  
  def get_item_class
    @item_type.camelize.constantize
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
    case @item_type
      when "job_position"
        JobPosition.get_position(id)
      else
        get_item_class.send("get_#{@item_type}", params[:id])
    end
  end
  
  
  def is_editor?
    ApplicationController.helpers.talk_editor?(session[:account_id])
  end
  
  def check_editor
    jump_to("/errors/forbidden") unless is_editor?
  end
  
end

