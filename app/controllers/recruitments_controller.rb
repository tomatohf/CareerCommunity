class RecruitmentsController < ApplicationController
  
  Recruitment_List_Size = 25
  
  layout "community"
  before_filter :check_login, :only => []
  before_filter :check_limited, :only => []
  
  
  
  def index
    #load "recruitment_vendors/base.rb"
    #load "recruitment_vendors/hiall.rb"
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @recruitments = Recruitment.paginate(
      :page => page,
      :per_page => Recruitment_List_Size,
      :include => [:recruitment_tags],
      :order => "publish_time DESC"
    )
    
  end
  
  def show
    @recruitment_id = params[:id]
    @recruitment = Recruitment.find(@recruitment_id, :include => [:recruitment_tags])
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
  
  
  
end

