class ExpsController < ApplicationController
  
  Show_Left_Ad = false
  
  
  Exp_List_Size = 30
  
  layout "community"
  before_filter :check_login, :only => [:new, :zz, :create, :edit, :update, :destroy]
  before_filter :check_limited, :only => [:create, :update, :destroy]
  
  before_filter :check_edit_access, :only => [:edit, :update, :destroy]
  
  before_filter :check_info_editor, :only => [:zz]
  
  
  
  ACKP_exps_feed = :ac_exps_feed
  
  caches_action :feed,
    :cache_path => Proc.new { |controller|
      ACKP_exps_feed.to_s
    },
    :if => Proc.new { |controller|
      controller.request.format.atom?
    }
  
  
  
  def index
    
  end
  
  def feed
    respond_to do |format|
      format.html { jump_to("/exps") }
      
      format.atom {
        @exps = Exp.find(
          :all,
          :limit => 50,
          :order => "publish_time DESC"
        )
        
        render :layout => false
      }
    end
  end
  
  def show
    @exp = Exp.find(
      params[:id],
      :include => [:companies, :job_positions]
    )
    
    @can_edit = has_login? && has_edit_access(@exp)
  end
  
  def list
    # disable the exp list page
    #return jump_to("/exps")
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    
    @exps = Exp.paginate(
      :page => page,
      :per_page => Exp_List_Size,
      :select => "id, title, publish_time",
      :order => "publish_time DESC"
    )
  end
  
  def search
    page = params[:page]
    page = 1 unless page =~ /\d+/
    
    @query = params[:query] && params[:query].strip
    
    if @query && (@query != "")
      @exps = Exp.search(
        @query,
        :page => page,
        :per_page => 10,
        :match_mode => CommunityController::Search_Match_Mode,
        :order => "@relevance DESC, publish_time DESC",
        :field_weights => {
          :title => 4,
          :content => 3,
        }
      ).compact
    end
  end
  
  def company
    @industries = Industry.system.find(
      :all,
      :include => [:companies]
    )
  end
  
  
  def new
    @exp = Exp.new
  end
  
  def zz
    @zz = true
    new
    render :action => "new"
  end
  
  def create
    is_info_editor = ApplicationController.helpers.info_editor?(session[:account_id])
    
    @zz = is_info_editor && (params[:zz] == "true")
    
    @exp = Exp.new(:account_id => @zz ? -1 : session[:account_id])
    
    @exp.title = params[:exp_title] && params[:exp_title].strip
    @exp.content = params[:exp_content] && params[:exp_content].strip
    
    if @zz
      @exp.source_name = params[:exp_source_name] && params[:exp_source_name].strip
      @exp.publish_time = params[:exp_publish_time] && params[:exp_publish_time].strip
      
      exp_source_link = params[:exp_source_link] && params[:exp_source_link].strip
      exp_source_link = nil if exp_source_link == ""
      @exp.source_link = exp_source_link
    end
    
    @exp.publish_time ||= DateTime.now
    
    if @exp.save
      return jump_to("/exps/#{@exp.id}")
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end

    render :action => "new"
  end
  
  def edit
    
  end
  
  def update
    @exp.title = params[:exp_title] && params[:exp_title].strip
    @exp.content = params[:exp_content] && params[:exp_content].strip
    
    if ApplicationController.helpers.info_editor?(session[:account_id])
      @exp.source_name = params[:exp_source_name] && params[:exp_source_name].strip
      @exp.publish_time = params[:exp_publish_time] && params[:exp_publish_time].strip
      
      exp_source_link = params[:exp_source_link] && params[:exp_source_link].strip
      exp_source_link = nil if exp_source_link == ""
      @exp.source_link = exp_source_link
    end
    
    if @exp.save
      return jump_to("/exps/#{@exp.id}")
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end

    render :action => "edit"
  end
  
  def destroy
    @exp.destroy
    
    jump_to("/exps")
  end
  
  
  private
  
  def has_edit_access(exp)
    ApplicationController.helpers.info_editor?(session[:account_id]) || (exp.account_id == session[:account_id])
  end
  
  def check_edit_access
    @exp_id = params[:id]
    @exp = Exp.find(@exp_id)
    
    jump_to("/errors/forbidden") unless has_edit_access(@exp)
  end
  
  def check_info_editor
    jump_to("/errors/forbidden") unless ApplicationController.helpers.info_editor?(session[:account_id])
  end
  
end

