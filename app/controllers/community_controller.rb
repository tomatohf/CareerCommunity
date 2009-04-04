class CommunityController < ApplicationController
  
  New_Account_Size = 9
  New_Action_Size = 15
  New_Talk_Size = 5
  New_Activity_Size = 10
  New_Group_Size = 12
  New_Activity_Post_Size = 10
  New_Group_Post_Size = 10
  New_Vote_Topic_Size = 10
  New_Blog_Size = 5
  
  Search_Result_Page_Size = 10
  
  Search_All_Result_Page_Size = 5
  
  Search_Match_Mode = :extended
  
  include CareerCommunity::Contact::InstanceMethods
  
  before_filter :check_login_for_community_index, :only => [:index]
  
  before_filter :check_login, :check_limited, :only => [:import_contact]
  
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
    ) if @has_login
    
    @new_actions = AccountAction.find(
      :all,
      :limit => New_Action_Size,
      :include => [:account => [:profile_pic]],
      :order => "created_at DESC"
    )
    
    @new_talks = Talk.published.find(
      :all,
      :limit => New_Talk_Size,
      :order => "publish_at DESC"
    )
    
    @new_activities = Activity.uncancelled.find(
      :all,
      :limit => New_Activity_Size,
      :select => "activities.id, activities.title, activities.cancelled, activity_images.photo_id",
      :joins => "INNER JOIN activity_images ON 
                  activity_images.activity_id = activities.id",
      :order => "created_at DESC"
    )

    @new_groups = Group.find(
      :all, 
      :limit => New_Group_Size,
      :include => [:image],
      :order => "created_at DESC"
    )
    
    @new_activity_posts = ActivityPost.find(
      :all,
      :limit => New_Activity_Post_Size,
      :select => "id, title, created_at, account_id",
      :include => [:account],
      :order => "created_at DESC"
    )

    @new_group_posts = GroupPost.find(
      :all,
      :limit => New_Group_Post_Size,
      :select => "id, title, created_at, account_id",
      :include => [:account],
      :order => "created_at DESC"
    )
    
    @new_blogs = Blog.find(
      :all,
      :limit => New_Blog_Size,
      :include => [:account],
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
  
  
  def import_contact
    user_id = params[:user_id] && params[:user_id].strip
    user_pwd = params[:user_pwd]
    type = params[:type] && params[:type].strip
    
    from = params[:from] && params[:from].strip
    
    # check input
    if !self.respond_to?("fetch_#{type}_contacts", true)
      return render(:layout => false, :text => "")
    elsif user_id.nil? || user_id == ""
      return render(:layout => false, :text => "请输入你的帐号")
    elsif user_pwd.nil? || user_pwd == ""
      return render(:layout => false, :text => "请输入你的密码")
    end
    
    contacts = []
    begin
      contacts = self.send("fetch_#{type}_contacts", user_id, user_pwd)
    rescue Jabber::ClientAuthenticationFailure
      return(render(:layout => false, :text => "帐号或密码错误"))
    rescue Timeout::Error
      return(render(:layout => false, :text => "操作超时, 请重试"))
    rescue
      return(render(:layout => false, :text => "发生错误, 请重试"))
    end
    
    return(render(:layout => false, :text => "抱歉, 没有找到任何联系人")) unless contacts.size > 0
    
    session["#{from}_invite_contacts_type".to_sym] = type
    session["#{from}_invite_contacts".to_sym] = contacts
    render(:layout => false, :text => "true")
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
    @votes = search_vote(query, 1, Search_All_Result_Page_Size)
    @talks = search_talk(query, 1, Search_All_Result_Page_Size)
  end
  
  def search_exp(query, page, per_page)
    Exp.search(
      query,
      :page => page,
      :per_page => per_page,
      :match_mode => Search_Match_Mode,
      :order => "@relevance DESC, publish_time DESC",
      :field_weights => {
        :title => 4,
        :content => 3,
      }
    )
  end
  
  def search_talk(query, page, per_page)
    Talk.search(
      query,
      :page => page,
      :per_page => per_page,
      :conditions => { :published => 1 },
      :match_mode => Search_Match_Mode,
      :order => "@relevance DESC, publish_at DESC",
      :field_weights => {
        :title => 10,
        :info => 8,
        
        :question_categories_name => 6,
        :question_categories_desc => 6,
        
        :questions_question => 8,
        :questions_summary => 6,
        
        :answers_answer => 8,
        :answers_summary => 6,
        
        :comments_content => 1
      }
    )
  end
  
  def search_vote(query, page, per_page)
    VoteTopic.search(
      query,
      :page => page,
      :per_page => per_page,
      :match_mode => Search_Match_Mode,
      :order => "@relevance DESC, created_at DESC",
      :field_weights => {
        :title => 8,
        :desc => 6,
        :options_title => 6,
        :comments_content => 2,
        :account_nick => 2,
        :category_name => 1,
        :comments_account_nick => 1
      },
      :include => [:image, :account, :options]
    )
  end
  
  def search_recruitment(query, page, per_page)
    Recruitment.search(
      query,
      :page => page,
      :per_page => per_page,
      :match_mode => Search_Match_Mode,
      :order => "@relevance DESC, publish_time DESC",
      :field_weights => {
        :title => 8,
        :content => 8,
        :location => 6,
        :recruitment_tags_name => 8
      },
      :include => [:recruitment_tags]
    )
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
        :profile_basic,
        :setting,
        :friends,
        :be_friends
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
