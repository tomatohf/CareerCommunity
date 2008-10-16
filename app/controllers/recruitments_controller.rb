class RecruitmentsController < ApplicationController
  
  Recruitment_List_Size = 25
  
  layout "community"
  before_filter :check_login, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :check_limited, :only => [:create, :update, :destroy]
  
  before_filter :check_edit_access, :only => [:edit, :update, :destroy]
  
  
  
  def index  
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @recruitments = Recruitment.paginate(
      :page => page,
      :per_page => Recruitment_List_Size,
      :include => [:recruitment_tags],
      :order => "publish_time DESC"
    )
    
    @recruitment_types = Recruitment.get_types
    @recruitment_locations = Recruitment.get_locations
  end
  
  def show
    @recruitment_id = params[:id]
    @recruitment = Recruitment.find(@recruitment_id, :include => [:recruitment_tags])
    
    @can_edit = has_login? && has_edit_access(@recruitment)
  end
  
  def tag
    @tag_name = params[:name] && params[:name].strip
    @tag = RecruitmentTag.get_tag(@tag_name)
    
    @new_record = @tag.new_record?
    
    unless @new_record
      page = params[:page]
      page = 1 unless page =~ /\d+/
      @recruitments = Recruitment.paginate(
        :page => page,
        :per_page => Recruitment_List_Size,
        :select => "recruitments.*",
        :joins => "INNER JOIN recruitments_recruitment_tags ON 
                    recruitments_recruitment_tags.recruitment_id = recruitments.id AND 
                    recruitments_recruitment_tags.recruitment_tag_id = #{@tag.id}",
        :order => "recruitments.publish_time DESC",
        :include => [:recruitment_tags]
      )
    end
  end
  
  def location
    @catalog_value = params[:name] && params[:name].strip
    @catalog_name = "地区"
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @recruitments = Recruitment.paginate_by_catalog(page, Recruitment_List_Size, :location, @catalog_value)
    
    render :action => "catalog"
  end

  def recruitment_type
    @catalog_value = params[:name] && params[:name].strip
    @catalog_name = "类型"

    page = params[:page]
    page = 1 unless page =~ /\d+/
    @recruitments = Recruitment.paginate_by_catalog(page, Recruitment_List_Size, :recruitment_type, @catalog_value)

    render :action => "catalog"
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
    @recruitment.source_link = params[:recruitment_source_link] && params[:recruitment_source_link].strip
    
    @recruitment.source_link += "/" if @recruitment.source_link[-1, 1] != "/"
    
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
    @recruitment.recruitment_tags.clear
    @recruitment.destroy
    
    jump_to("/recruitments")
  end
  
  
  private
  
  def has_edit_access(recruitment)
    ApplicationController.helpers.general_admin?(session[:account_id]) || (recruitment.account_id == session[:account_id])
  end
  
  def check_edit_access
    @recruitment_id = params[:id]
    @recruitment = Recruitment.find(@recruitment_id)
    
    jump_to("/errors/forbidden") unless has_edit_access(@recruitment)
  end
  
end

