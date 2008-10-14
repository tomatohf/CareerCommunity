class RecruitmentsController < ApplicationController
  
  Recruitment_List_Size = 2
  
  layout "community"
  before_filter :check_login, :only => []
  before_filter :check_limited, :only => []
  
  
  
  def index
    load "recruitment_vendors/base.rb"
    load "recruitment_vendors/hiall.rb"
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @recruitments = Recruitment.paginate(
      :page => page,
      :per_page => Recruitment_List_Size,
      #:include => [],
      :order => "publish_time DESC"
    )
    
    @tags = RecruitmentTag.tags
    
  end
  
  
  
end

