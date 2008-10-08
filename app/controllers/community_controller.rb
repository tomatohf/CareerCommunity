class CommunityController < ApplicationController
  
  New_Account_Size = 9
  New_Action_Size = 15
  New_Activity_Size = 10
  
  Search_Result_Page_Size = 10
  
  Search_All_Result_Page_Size = 5
  
  Search_Match_Mode = :extended
  
  before_filter :check_login_for_community_index, :only => [:index]
  
  def index
    @has_login = true
    
    welcome
  end
  
  def welcome
    @new_accounts = Account.enabled.unlimited.find(
      :all,
      :limit => New_Account_Size,
      :include => [:profile_pic],
      :order => "created_at DESC"
    )
    
    @new_actions = AccountAction.find(
      :all,
      :limit => New_Action_Size,
      :include => [:account => [:profile_pic]],
      :order => "created_at DESC"
    )
    
    @new_activities = Activity.find(
      :all,
      :limit => New_Activity_Size,
      :include => [:image],
      :order => "created_at DESC"
    )
    
    render :action => "index"
  end
  
  def search
    @scope = params[:scope] && params[:scope].strip
    @query = params[:query] && params[:query].strip
    
    if @query && @query != ""
      @scope = "all" unless self.respond_to?("search_#{@scope}", true)
    
      page = params[:page]
      page = 1 unless page =~ /\d+/
      @results = self.send("search_#{@scope}", @query, page, Search_Result_Page_Size)
    end
    
  end
  
  
  
  def interval
    unread_msg_count_txt = ""
    
    if has_login?
      
      unread_inbox_count = Message.get_unread_count(session[:account_id]) || 0
      unread_sys_count = SysMessage.get_unread_count(session[:account_id]) || 0
      total_unread_msg_count = unread_inbox_count + unread_sys_count
      unread_msg_count_txt = "(#{total_unread_msg_count})" if total_unread_msg_count > 0
      
    end
    
    render :text => %Q!
    
      var unread_msg_count_container = document.getElementById("unread_msg_count");
      if(unread_msg_count_container.firstChild){ unread_msg_count_container.removeChild(unread_msg_count_container.firstChild); }
      unread_msg_count_container.appendChild(document.createTextNode("#{unread_msg_count_txt}"));
      
      
      
      setTimeout("refresh_interval_loader();", #{1000 * 60 * 5});
      
    !, :layout => false
  end
  
  private
  
  def check_login_for_community_index
    jump_to("/community/welcome") unless has_login?
  end
  
  def search_all(query, page, per_page)
    @activities = search_activity(query, 1, Search_All_Result_Page_Size)
    @activity_posts = search_activity_post(query, 1, Search_All_Result_Page_Size)
    @groups = search_group(query, 1, Search_All_Result_Page_Size)
    @group_posts = search_group_post(query, 1, Search_All_Result_Page_Size)
  end
  
  def search_activity_post(query, page, per_page)
    ActivityPost.search(
      query,
      :page => page,
      :per_page => per_page,
      :match_mode => Search_Match_Mode,
      :order => "@relevance DESC, responded_at DESC",
      :field_weights => {
        :title => 8,
        :content => 6,
        :comments_content => 4,
        :account_nick => 2,
        :activity_title => 2,
        :comments_account_nick => 1
      },
      :include => [
        :activity,
        {:account => [:profile_pic]}
      ]
    )
  end
  
  def search_group_post(query, page, per_page)
    GroupPost.search(
      query,
      :page => page,
      :per_page => per_page,
      :match_mode => Search_Match_Mode,
      :order => "@relevance DESC, responded_at DESC",
      :field_weights => {
        :title => 8,
        :content => 6,
        :comments_content => 4,
        :account_nick => 2,
        :group_name => 2,
        :comments_account_nick => 1
      },
      :include => [
        :group,
        {:account => [:profile_pic]}
      ]
    )
  end
  
  def search_activity(query, page, per_page)
    Activity.search(
      query,
      :page => page,
      :per_page => per_page,
      :match_mode => Search_Match_Mode,
      :order => "@relevance DESC, created_at DESC",
      :field_weights => {
        :title => 8,
        :place => 4,
        :setting => 6,
        :master_nick => 1
      },
      :include => [:image, :master]
    )
  end
  
  def search_group(query, page, per_page)
    Group.search(
      query,
      :page => page,
      :per_page => per_page,
      :match_mode => Search_Match_Mode,
      :order => "@relevance DESC, created_at DESC",
      :field_weights => {
        :name => 10,
        :desc => 6,
        :setting => 4,
        :master_nick => 1
      },
      :include => [:image, :master]
    )
  end
  
  def search_account(query, page, per_page)
    Account.search(
      query,
      :page => page,
      :per_page => per_page,
      :match_mode => Search_Match_Mode,
      :order => "@relevance DESC, created_at DESC",
      :field_weights => {
        :email => 15,
        :nick => 20,
        
        :basic_real_name => 10,
        :basic_qmd => 5,
        :basic_province_name => 15,
        :basic_city_name => 15,
        :basic_hometown_province_name => 15,
        :basic_hometown_city_name => 15,
        
        :hobby_intro => 5,
        :hobby_interest => 5,
        :hobby_music => 5,
        :hobby_movie => 5,
        :hobby_cartoon => 5,
        :hobby_game => 5,
        :hobby_sport => 5,
        :hobby_book => 5,
        :hobby_words => 5,
        :hobby_food => 5,
        :hobby_idol => 5,
        :hobby_car => 5,
        :hobby_place => 5,
        
        :edu_name => 10,
        :edu_major => 5,
        
        :job_name => 10,
        :job_dept => 5,
        :job_position_title => 5,
        :job_description => 5
      },
      :include => [
        :profile_pic,
        :profile_hobby,
        {:profile_basic => [:province, :city, :hometown_province, :hometown_city]}
      ],
      :with => {
        :checked => 1,
        :active => 1,
        :enabled => 1
      }
    )
  end
  
  def search_blog(query, page, per_page)
    Blog.search(
      query,
      :page => page,
      :per_page => per_page,
      :match_mode => Search_Match_Mode,
      :order => "@relevance DESC, created_at DESC",
      :field_weights => {
        :title => 8,
        :content => 6,
        :comments_content => 4,
        :account_nick => 2,
        :comments_account_nick => 1
      },
      :include => [:account => [:profile_pic]]
    )
  end

end
