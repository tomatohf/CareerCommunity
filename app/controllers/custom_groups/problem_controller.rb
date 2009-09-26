class CustomGroups::ProblemController < CustomGroups::FeedbackController

  Problem_Group_ID = Rails.env.production? ? 28 : 13
  
  
  Group_Post_Num = 40
  
  Search_Result_Page_Size = 10
  
  Category_Observers = {
    1002 => [1020], # 小孙
    1003 => [1001], # Tomato
    1004 => [1002], # Rick
    1005 => [1002], # Rick
    1006 => [1019], # Kai
    1007 => [4102], # Martin
    1008 => [1660], # 姜鑫
    1000 => [1000]
  }
  
  
  
  before_filter :check_login, :only => [:asked, :compose]
  
  before_filter :check_account, :only => [:asked]
    
    
    
    
  def asked
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @posts = GroupPost.paginate(
      :page => page,
      :per_page => Post_List_Size,
      :select => "id, created_at, group_id, account_id, title, top, good, responded_at, responded_by",
      :conditions => ["group_id = ? and account_id = ?", @group.id, params[:account]],
      :order => "responded_at DESC"
    )
  end
  
  def search
    @query = params[:query] && params[:query].strip
    
    if @query && @query != ""
      page = params[:page]
      page = 1 unless page =~ /\d+/
      
      @posts = search_problems(@query, page, Search_Result_Page_Size, @group.id)
    end
  end
  
  def compose
    @question = params[:question] && params[:question].strip
    
    if @question && @question != ""
      page = params[:page]
      page = 1 unless page =~ /\d+/
      
      @posts = search_problems(@question, page, 5, @group.id)
    end
    
    @categories = GroupPostCategory.get_categories(@group.id)
  end
  
  
  private
  
  def search_problems(query, page, page_size, group_id)
    GroupPost.search(
      query,
      :page => page,
      :per_page => page_size,
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
      :conditions => { :group_id => group_id }
    )
  end
  
  def check_account
    jump_to("/errors/forbidden") unless session[:account_id].to_s == params[:account]
  end

end

