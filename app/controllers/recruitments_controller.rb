class RecruitmentsController < ApplicationController
  
  Create_Job_Target_Page_Name = "job_target_list_from_recruitment"
  
  Show_Left_Ad = false
  
  
  Recruitment_List_Size = 50
  
  layout "community"
  before_filter :check_login, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :check_limited, :only => [:create, :update, :destroy]
  
  before_filter :check_edit_access, :only => [:edit, :update, :destroy]
  
  before_filter :check_recruitment_type, :only => [:recruitment_type]
  
  
  
  ACKP_recruitments_feed = :ac_recruitments_feed
  
  caches_action :feed,
    :cache_path => Proc.new { |controller|
      ACKP_recruitments_feed.to_s
    },
    :if => Proc.new { |controller|
      controller.request.format.atom?
    }
  
  
  
  def index
    
  end
  
  def feed
    respond_to do |format|
      format.html { jump_to("/recruitments") }
      
      format.atom {
        @recruitments = Recruitment.find(
          :all,
          :limit => 50,
          :include => [:recruitment_tags],
          :order => "id DESC"
        )
        
        render :layout => false
      }
    end
  end
  
  def show
    @recruitment, @old = get_recruitment(
      params[:id], 
      [:recruitment_tags, :companies, :job_positions]
    )
    
    @can_edit = has_login? && has_edit_access(@recruitment)
  end
  
  def recruitment_type
    page = params[:page]
    page = 1 unless page =~ /\d+/
    
    @recruitments = Recruitment.paginate(
      :page => page,
      :per_page => Recruitment_List_Size,
      :select => "id, title, publish_time, location, recruitment_type",
      :conditions => ["recruitment_type = ?", params[:id]],
      :order => "publish_time DESC",
      :include => [:recruitment_tags]
    )
  end
  
  def location
    @location_name = params[:name] && params[:name].strip
    @is_parttime = (params[:rt] == "2")
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    
    @recruitments = Recruitment.search(
      @location_name,
      :page => page,
      :per_page => Recruitment_List_Size,
      :conditions => { :recruitment_type => (@is_parttime ? 2 : 1) },
      #:match_mode => CommunityController::Search_Match_Mode,
      :order => "publish_time DESC, @relevance DESC",
      :field_weights => {
        :title => 5,
        :content => 5,
        :location => 10,
        :recruitment_tags_name => 5
      },
      :include => [:recruitment_tags]
    ).compact
  end
  
  def tag
    @tag_name = params[:name] && params[:name].strip
    
    if @tag_name && (@tag_name != "")
      @tag = RecruitmentTag.get_tag(@tag_name)
    
      @new_record = @tag.new_record?
    
      unless @new_record
        page = params[:page]
        page = 1 unless page =~ /\d+/
        @recruitments = Recruitment.paginate(
          :page => page,
          :per_page => Recruitment_List_Size,
          :select => "recruitments.id, title, publish_time, location, recruitment_type",
          :joins => "INNER JOIN recruitments_recruitment_tags ON 
                      recruitments.id = recruitments_recruitment_tags.recruitment_id",
          :conditions => ["recruitment_tag_id = ?", @tag.id],
          # :order => "publish_time DESC",
          :order => "recruitment_id DESC",
          :include => [:recruitment_tags]
        ).sort { |x, y| (y.publish_time || y.created_at) <=> (x.publish_time || x.created_at) }
      end
      
    end
  end
  
  def search
    @recruitment_type = params[:recruitment_type].to_i
    # nil.to_i => 0
    # "".to_i => 0
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    
    @query = params[:query] && params[:query].strip
    
    conditions = @recruitment_type > 0 ? { :recruitment_type => @recruitment_type } : {}
    
    if @query && (@query != "")
      @recruitments = Recruitment.search(
        @query,
        :page => page,
        :per_page => 15,
        :conditions => conditions,
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
    end
  end
  
  
  # def new
  #   @recruitment = Recruitment.new
  # end
  
  # def create
  #   @recruitment = Recruitment.new(:account_id => session[:account_id])
    
  # end
  
  def edit
    
  end
  
  def update
    @recruitment.title = params[:recruitment_title] && params[:recruitment_title].strip
    @recruitment.content = params[:recruitment_content] && params[:recruitment_content].strip
    
    @recruitment.source_name = params[:recruitment_source_name] && params[:recruitment_source_name].strip

    recruitment_source_link = params[:recruitment_source_link] && params[:recruitment_source_link].strip
    recruitment_source_link = nil if recruitment_source_link == ""
    @recruitment.source_link = recruitment_source_link
    
    # @recruitment.source_link += "/" if @recruitment.source_link[-1, 1] != "/"
    
    @recruitment.recruitment_type = params[:recruitment_type] && params[:recruitment_type].strip
    @recruitment.location = params[:recruitment_location] && params[:recruitment_location].strip
    
    if @recruitment.save
      return jump_to("/recruitments/#{@recruitment.id}")
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end

    render :action => "edit"
  end
  
  def destroy
    # seems it can be done automatically ...
    # @recruitment.recruitment_tags.clear
    
    @recruitment.destroy
    
    jump_to("/recruitments")
  end
  
  
  private
  
  def has_edit_access(recruitment)
    ApplicationController.helpers.info_editor?(session[:account_id]) || (recruitment.account_id == session[:account_id])
  end
  
  def check_edit_access
    @recruitment_id = params[:id]
    @recruitment, old = get_recruitment(@recruitment_id)
    
    jump_to("/errors/forbidden") unless has_edit_access(@recruitment)
  end
  
  def check_recruitment_type
    @type_label = Recruitment.recruitment_type_label(params[:id].to_i)
    
    jump_to("/errors/forbidden") unless @type_label && (@type_label != "")
  end
  
  def get_recruitment(rid, includes = nil)
    begin
      r = Recruitment.find(
        rid,
        :include => includes
      )
      old = false
    rescue ActiveRecord::RecordNotFound => no_record_error
      r = ArchivedRecruitment.find(rid)
      old = true
    end
    
    [r, old]
  end
  
end

