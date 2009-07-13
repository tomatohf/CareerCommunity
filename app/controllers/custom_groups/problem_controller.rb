class CustomGroups::ProblemController < CustomGroups::FeedbackController

  Problem_Group_ID = (ENV["RAILS_ENV"] == "production") ? 1 : 13
  
  
  Group_Post_Num = 40
  
  Search_Result_Page_Size = 10
  
  
  def search
    @query = params[:query] && params[:query].strip
    
    if @query && @query != ""
      page = params[:page]
      page = 1 unless page =~ /\d+/
      @posts = GroupPost.search(
        @query,
        :page => page,
        :per_page => Search_Result_Page_Size,
        :match_mode => CommunityController::Search_Match_Mode,
        :order => "@relevance DESC, responded_at DESC",
        :field_weights => {
          :title => 8,
          :content => 6,
          :comments_content => 4,
          :account_nick => 1,
          :group_name => 0,
          :comments_account_nick => 1
        },
        :include => [:account => [:profile_pic]],
        :conditions => { :group_id => @group.id }
      )
    end
  end
  
  def compose
    
  end

end

