class CommunityController < ApplicationController
  
  New_Account_Size = 9
  New_Action_Size = 15
  New_Activity_Size = 10
  
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
    @scope = params[:scope]
    @query = params[:query]
    
    @scope = "all" unless self.respond_to?("search_#{@scope}", true)
    
    @results = self.send("search_#{@scope}", @query)

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
  
  def search_all(query)

  end
  
  def search_blog(query)
    
    # NEED TO handle raised errors
    # NEED TO handle pagination
    
    blogs = Blog.search(query)
    
    
    blogs
  end

end
