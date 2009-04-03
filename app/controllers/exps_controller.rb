class ExpsController < ApplicationController
  
  Exp_List_Size = 20
  
  layout "community"
  before_filter :check_login, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :check_limited, :only => [:create, :update, :destroy]
  
  before_filter :check_edit_access, :only => [:edit, :update, :destroy]
  
  
  
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
          :include => [:exp_tags],
          :order => "publish_time DESC"
        )
        
        render :layout => false
      }
    end
  end
  
  def show
    @exp = Exp.find(params[:id], :include => [:exp_tags])
    
    @can_edit = has_login? && has_edit_access(@exp)
  end
  
  def tag
    @tag_name = params[:name] && params[:name].strip
    
    if @tag_name && (@tag_name != "")
      @tag = ExpTag.get_tag(@tag_name)
    
      @new_record = @tag.new_record?
    
      unless @new_record
        page = params[:page]
        page = 1 unless page =~ /\d+/
        @exps = Exp.paginate(
          :page => page,
          :per_page => Exp_List_Size,
          :select => "exps.id, exps.title, exps.publish_time",
          :joins => "INNER JOIN exps_exp_tags ON 
                      exps_exp_tags.exp_id = exps.id AND 
                      exps_exp_tags.exp_tag_id = #{@tag.id}",
          :order => "exps.publish_time DESC",
          :include => [:exp_tags]
        )
      end
      
    end
  end
  
  def search
    page = params[:page]
    page = 1 unless page =~ /\d+/
    
    @query = params[:query] && params[:query].strip
    
    if @query && (@query != "")
      @exps = Exp.search(
        @query,
        :page => page,
        :per_page => 15,
        :match_mode => CommunityController::Search_Match_Mode,
        :order => "publish_time DESC, @relevance DESC",
        :field_weights => {
          :title => 4,
          :content => 3,
          :exp_tags_name => 4
        },
        :include => [:exp_tags]
      ).compact
    end
  end
  
  
  # def new
  #   @exp = Exp.new
  # end
  
  # def create
  #   @exp = Exp.new(:account_id => session[:account_id])
    
  # end
  
  def edit
    
  end
  
  def update
    @exp.title = params[:exp_title] && params[:exp_title].strip
    @exp.content = params[:exp_content] && params[:exp_content].strip
    
    @exp.source_name = params[:exp_source_name] && params[:exp_source_name].strip
    @exp.source_link = params[:exp_source_link] && params[:exp_source_link].strip
    
    if @exp.save
      return jump_to("/exps/#{@exp.id}")
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end

    render :action => "edit"
  end
  
  def destroy
    # seems it can be done automatically ...
    # @exp.exp_tags.clear
    
    @exp.destroy
    
    jump_to("/exps")
  end
  
  
  private
  
  def has_edit_access(exp)
    ApplicationController.helpers.general_admin?(session[:account_id]) || (exp.account_id == session[:account_id])
  end
  
  def check_edit_access
    @exp_id = params[:id]
    @exp = Exp.find(@exp_id)
    
    jump_to("/errors/forbidden") unless has_edit_access(@exp)
  end
  
end

