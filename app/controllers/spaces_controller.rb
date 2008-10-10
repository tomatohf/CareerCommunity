class SpacesController < ApplicationController
  
  Comment_Page_Size = 50
  Action_Page_Size = 10
  
  Space_Comment_Num = 10
  Space_Friend_Num = 30
  Space_Group_Num = 15
  Space_Action_Num = 10
  Space_Activity_Num = 6
  Space_Photo_Num = 10
  
  layout "community"
  before_filter :check_current_account, :only => [:index]
  before_filter :check_login, :only => [:resume_edit, :show_edit, :profile_edit, :wall_edit, :create_comment, :delete_comment]
  before_filter :check_limited, :only => [:create_comment, :delete_comment]
  before_filter :check_edit_for_space, :only => [:resume_edit, :show_edit, :profile_edit, :wall_edit]
  before_filter :check_comment_owner, :only => [:delete_comment]
  
  
  # ! current account needed !
  def index
    jump_to("/spaces/show_edit/#{session[:account_id]}")
  end
  
  def resume
    @account_id = params[:id]
    @account_nick_pic = Account.get_nick_and_pic(@account_id)
    
    # get required profiles
    @basic_profile = BasicProfile.get_by_account(@account_id)
    @contact_profile = ContactProfile.get_by_account(@account_id)
    @hobby_profile = HobbyProfile.get_by_account(@account_id)
    @job_profiles = JobProfile.get_all_by_account(@account_id, :order => "enter_year DESC, enter_month DESC")
    @edu_profiles = EducationProfile.get_all_by_account(@account_id, :order => "education_id DESC, enter_year DESC")
    
    if @basic_profile
      all_provinces_cities_cache = Province.get_all_provinces_cities
      @province_name = Province.get_name(@basic_profile.province_id, all_provinces_cities_cache)
      @city_name = City.get_name(@basic_profile.city_id, all_provinces_cities_cache)
    end
  end
  
  def resume_edit
    @edit = true
    resume
    render :action => "resume"
  end
  
  def show
    @account_id = params[:id]
    @account_nick_pic = Account.get_nick_and_pic(@account_id)
    
    # should NOT cache the relationship check
    @relationship = "logout"
    if has_login?
      if session[:account_id].to_s == @account_id
        @relationship = "self"
      else
        @relationship = Friend.is_friend(session[:account_id], @account_id) ? "friend" : "not_friend"
      end
    end
    
    
    @basic_profile = BasicProfile.get_by_account(@account_id)
    if @basic_profile
      all_provinces_cities_cache = Province.get_all_provinces_cities
      @province_name = Province.get_name(@basic_profile.province_id, all_provinces_cities_cache)
      @city_name = City.get_name(@basic_profile.city_id, all_provinces_cities_cache)
      
      @hometown_province_name = Province.get_name(@basic_profile.hometown_province_id, all_provinces_cities_cache)
      @hometown_city_name = City.get_name(@basic_profile.hometown_city_id, all_provinces_cities_cache)
    end
    
    
    @space_comments = SpaceComment.find(
      :all,
      :limit => Space_Comment_Num,
      :conditions => ["owner_id = ?", @account_id],
      :include => [:account => [:profile_pic]],
      :order => "created_at DESC"
    )
    
    
    @friends = Friend.get_all_by_account(
      @account_id,
      :limit => Space_Friend_Num,
      :include => [:friend => [:profile_pic]],
      :order => "created_at DESC"
    ).collect { |f|
      account_id = f.friend.id
      account_nick = f.friend.get_nick
      account_pic_url = f.friend.get_profile_pic_url
      
      Account.set_account_nick_pic_cache(account_id, account_nick, account_pic_url, f.friend.email)
      
      [account_nick, account_pic_url, f.friend.email, account_id]
    }
    
    @group_members = GroupMember.agreed.find(
      :all,
      :limit => Space_Group_Num,
      :conditions => ["account_id = ?", @account_id],
      :include => [:group => [:image]],
      :order => "join_at DESC"
    )
    
    
    @account_actions = if @edit
      # find friends'
      AccountAction.find(
        :all,
        :limit => Space_Action_Num,
        :conditions => ["account_id in (select friend_id from friends where account_id = ?)", @account_id],
        :include => [:account => [:profile_pic]],
        :order => "created_at DESC"
      )
    else
      AccountAction.find(
        :all,
        :limit => Space_Action_Num,
        :conditions => ["account_id = ?", @account_id],
        :order => "created_at DESC"
      )
    end
    
    
    @activity_members = ActivityMember.agreed.find(
      :all,
      :limit => Space_Activity_Num,
      :conditions => ["account_id = ?", @account_id],
      :include => [:activity => [:image]],
      :order => "join_at DESC"
    )
    
    @activity_interests = ActivityInterest.find(
      :all,
      :limit => Space_Activity_Num,
      :conditions => ["account_id = ?", @account_id],
      :include => [:activity => [:image]],
      :order => "created_at DESC"
    )
    
    @photos = Photo.find(
      :all,
      :limit => Space_Photo_Num,
      :conditions => ["account_id = ?", @account_id],
      :order => "created_at DESC"
    )
  end
  
  def show_edit
    @edit = true
    show
    render :action => "show"
  end
  
  def profile
    @account_id = params[:id]
    @account_nick_pic = Account.get_nick_and_pic(@account_id)
    
    @basic_profile = BasicProfile.get_by_account(@account_id)
    @contact_profile = ContactProfile.get_by_account(@account_id)
    @hobby_profile = HobbyProfile.get_by_account(@account_id)
    
    if @basic_profile
      all_provinces_cities_cache = Province.get_all_provinces_cities
      @province_name = Province.get_name(@basic_profile.province_id, all_provinces_cities_cache)
      @city_name = City.get_name(@basic_profile.city_id, all_provinces_cities_cache)
      
      @hometown_province_name = Province.get_name(@basic_profile.hometown_province_id, all_provinces_cities_cache)
      @hometown_city_name = City.get_name(@basic_profile.hometown_city_id, all_provinces_cities_cache)
    end
  end
  
  def profile_edit
    @edit = true
    profile
    render :action => "profile"
  end
  
  def wall
    @account_id = params[:id]
    @account_nick_pic = Account.get_nick_and_pic(@account_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @space_comments = SpaceComment.paginate(
      :page => page,
      :per_page => Comment_Page_Size,
      :conditions => ["owner_id = ?", @account_id],
      :include => [:account => [:profile_pic]],
      :order => "created_at DESC"
    )
  end
  
  def wall_edit
    @edit = true
    wall
    render :action => "wall"
  end
  
  def actions
    @account_id = params[:id]
    @account_nick_pic = Account.get_nick_and_pic(@account_id)

    @action_type = params[:action_type]
    condition = (@action_type && @action_type != "") ? ["account_id = ? and action_type = ?", @account_id, @action_type] : ["account_id = ?", @account_id]
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @account_actions = AccountAction.paginate(
      :page => page,
      :per_page => Action_Page_Size,
      :conditions => condition,
      :order => "created_at DESC"
      )
  end
  
  def friend_actions
    @account_id = params[:id]
    @account_nick_pic = Account.get_nick_and_pic(@account_id)

    @action_type = params[:action_type]
    friend_condition = "account_actions.account_id in (select friend_id from friends where friends.account_id = ?)"
    condition = (@action_type && @action_type != "") ? ["#{friend_condition} and account_actions.action_type = ?", @account_id, @action_type] : [friend_condition, @account_id]
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @account_actions = AccountAction.paginate(
      :page => page,
      :per_page => Action_Page_Size,
      :conditions => condition,
      :include => [:account => [:profile_pic]],
      :order => "account_actions.created_at DESC"
      )
  end
  
  def create_comment
    space_comment = SpaceComment.new(:account_id => session[:account_id])
    
    content = params[:space_comment]
    owner_id = params[:id]
    
    if owner_id && content
      space_comment.content = content.strip
      space_comment.owner_id = owner_id
      if space_comment.save
        AccountAction.create_new(session[:account_id], "add_space_comment", {
          :owner_id => owner_id,
          :comment_id => space_comment.id,
          :comment_content => space_comment.content
        })
        
        SysMessage.create_new(owner_id, "add_space_comment", {
          :account_id => session[:account_id],
          :comment_id => space_comment.id,
          :comment_content => space_comment.content
        }) unless session[:account_id].to_s == owner_id
      end
    end
    
    jump_to("/spaces/#{params[:e] == "true" ? "wall_edit" : "wall"}/#{owner_id}")
  end
  
  def delete_comment
    @space_comment.destroy
    
    jump_to("/spaces/#{params[:e] == "true" ? "wall_edit" : "wall"}/#{session[:account_id]}")
  end
  
  private
  
  def check_edit_for_space
    jump_to("/spaces/#{action_name[0...-5]}/#{params[:id]}") unless session[:account_id].to_s == params[:id]
  end
  
  def check_comment_owner
    @space_comment = SpaceComment.find(params[:id])
    jump_to("/errors/forbidden") unless session[:account_id] == @space_comment.owner_id
  end
  
end