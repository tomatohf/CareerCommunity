class TalksController < ApplicationController
  
  Comment_Page_Size = 100
  Talk_Page_Size = 10
  
  New_Comment_Size = 30
  
  
  layout "community"
  before_filter :check_login, :only => []
  before_filter :check_limited, :only => []
  
  
  
  def index
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
#    @talks = Talk.paginate(
#      :page => page,
#      :per_page => Talk_Page_Size,
#      :order => "created_at DESC"
#    )
    
    @new_comments = TalkComment.find(
      :all,
      :limit => New_Comment_Size,
      :include => [:account => [:profile_pic]],
      :order => "updated_at DESC"
    )
    
  end
  
end

