class SpacesController < ApplicationController
  
  Comment_Page_Size = 50
  Action_Page_Size = 20
  
  Space_Comment_Num = 10
  Space_Friend_Num = 30
  Space_Group_Num = 15
  Space_Action_Num = 10
  Space_Activity_Num = 5
  Space_Vote_Num = 10
  Space_Photo_Num = 10
  Space_Blog_Num = 5
  Space_Bookmark_Num = 5
  
  
  VIP_Title = "VIP"
  Kind_Hearted_Title = "我承诺尽我所能与大家互相帮助"
  Expert_Title = "<strong>[本站智囊]</strong>"
  
  
  layout "community"
  before_filter :check_current_account, :only => [:index]
  before_filter :check_login, :only => [:create_comment, :delete_comment, 
                                        :edit_point, :update_point,
                                        :edit_role, :update_role, :destroy_role,
                                        :create_kind_hearted_role,
                                        :destroy_account_action]
  before_filter :check_limited, :only => [:create_comment, :delete_comment, 
                                          :update_point, :update_role, :destroy_role,
                                          :create_kind_hearted_role,
                                          :destroy_account_action]
  before_filter :check_comment_owner, :only => [:delete_comment]
  
  before_filter :check_general_admin, :only => [:edit_point, :update_point]
  before_filter :check_info_editor, :only => [:edit_role, :update_role, :destroy_role]
  
  before_filter :check_destroy_account_action, :only => [:destroy_account_action]
  
  
  # ! current account needed !
  def index
    jump_to("/spaces/show/#{session[:account_id]}")
  end
  
  def resume
    @account_id = params[:id]
    @account_nick_pic = Account.get_nick_and_pic(@account_id)
    
    @edit = (session[:account_id].to_s == @account_id)
    
    @resume_visible = true
    unless @edit
      account_setting = AccountSetting.get_account_setting(@account_id)
      @profile_resume_visible = account_setting.get_setting_value(:profile_resume_visible)
      
      case @profile_resume_visible
        when "any"
          @resume_visible = true
        when "login"
          @resume_visible = has_login?
        when "friend"
          @resume_visible = has_login? && Friend.is_friend(@account_id, session[:account_id])
        when "both_friend"
          @resume_visible = has_login? && Friend.is_friend(@account_id, session[:account_id]) && Friend.is_be_friend(@account_id, session[:account_id])
      end
    end
    
    if @resume_visible || ApplicationController.helpers.general_admin?(session[:account_id])
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
  end
  
  def show
    @account_id = params[:id]
    
    
    @account_nick_pic = Account.get_nick_and_pic(@account_id)
    
    @edit = (@account_id == session[:account_id].to_s)
    
    # should NOT cache the relationship check
    @relationship = "logout"
    if has_login?
      if session[:account_id].to_s == @account_id
        @relationship = "self"
      else
        @relationship = Friend.is_friend(session[:account_id], @account_id) ? "friend" : "not_friend"
      end
    end
    
    
    @basic_profile_visible = true
    unless @edit
      account_setting = AccountSetting.get_account_setting(@account_id)
      @profile_basic_visible = account_setting.get_setting_value(:profile_basic_visible)
      
      case @profile_basic_visible
        when "any"
          @basic_profile_visible = true
        when "login"
          @basic_profile_visible = has_login?
        when "friend"
          @basic_profile_visible = has_login? && Friend.is_friend(@account_id, session[:account_id])
        when "both_friend"
          @basic_profile_visible = has_login? && Friend.is_friend(@account_id, session[:account_id]) && @relationship == "friend"
      end
    end
    
    if @basic_profile_visible
      @basic_profile = BasicProfile.get_by_account(@account_id)
      if @basic_profile
        all_provinces_cities_cache = Province.get_all_provinces_cities
        @province_name = Province.get_name(@basic_profile.province_id, all_provinces_cities_cache)
        @city_name = City.get_name(@basic_profile.city_id, all_provinces_cities_cache)
      
        @hometown_province_name = Province.get_name(@basic_profile.hometown_province_id, all_provinces_cities_cache)
        @hometown_city_name = City.get_name(@basic_profile.hometown_city_id, all_provinces_cities_cache)
      end
    end
    
    
    @points = PointProfile.get_account_points(@account_id)
    
    @is_vip = false
    @is_brain_trust = false
    @is_kind_hearted = false
    RoleProfile.get_account_roles(@account_id).each do |role|
      role_type_id = role[1]
      
      @is_vip ||= (role_type_id == RoleProfile.ids.customer_role_id)
      @is_brain_trust ||= (role_type_id == RoleProfile.ids.industry_expert_role_id) || (role_type_id == RoleProfile.ids.trainer_role_id)
      @is_kind_hearted ||= (role_type_id == RoleProfile.ids.kind_hearted_role_id)
    end
    
    
    @online = ChatsController.helpers.online?(@account_id) unless @edit
    
    
    @friends = Friend.get_account_friend_ids(@account_id).reverse[0, Space_Friend_Num].collect { |account_id|
      Account.get_nick_and_pic(account_id) << account_id
    }
    
    @group_members = GroupMember.agreed.find(
      :all,
      :limit => Space_Group_Num,
      :conditions => ["account_id = ?", @account_id],
      :include => [:group => [:image]],
      :order => "admin DESC, join_at DESC"
    )
    
    
    @account_actions = if @edit
      # find friends'
      friends = Friend.get_account_friend_ids(@account_id)
      
      AccountAction.visible.find(
        :all,
        :limit => Space_Action_Num,
        :conditions => ["account_id in (?)", friends],
        :include => [:account => [:profile_pic]],
        :order => "created_at DESC"
      )
    else
      AccountAction.visible.find(
        :all,
        :limit => Space_Action_Num,
        :conditions => ["account_id = ?", @account_id],
        :order => "created_at DESC"
      )
    end
    
    
    # @activity_members value is set in view ...
    
    # @activity_interests value is set in view ...
    
    # @vote_topics value is set in view ...
    
    # @photos value is set in view ...
    
    # @blogs value is set in view ...
    
    # @space_comments value is set in view ..
    
  end
  
  def profile
    @account_id = params[:id]
    @account_nick_pic = Account.get_nick_and_pic(@account_id)
    
    @edit = (session[:account_id].to_s == @account_id)
    
    @basic_profile_visible = true
    @contact_profile_visible = true
    @hobby_profile_visible = true
    unless @edit
      account_setting = AccountSetting.get_account_setting(@account_id)
      @profile_basic_visible = account_setting.get_setting_value(:profile_basic_visible)
      @profile_contact_visible = account_setting.get_setting_value(:profile_contact_visible)
      @profile_hobby_visible = account_setting.get_setting_value(:profile_hobby_visible)
      
      check_login = has_login?
      check_friend = Friend.is_friend(@account_id, session[:account_id]) if check_login && (@profile_basic_visible == "friend" || @profile_contact_visible == "friend" || @profile_hobby_visible == "friend")
      check_be_friend = Friend.is_be_friend(@account_id, session[:account_id]) if check_login && check_friend && (@profile_basic_visible == "both_friend" || @profile_contact_visible == "both_friend" || @profile_hobby_visible == "both_friend")
      
      case @profile_basic_visible
        when "any"
          @basic_profile_visible = true
        when "login"
          @basic_profile_visible = check_login
        when "friend"
          @basic_profile_visible = has_login? && check_friend
        when "both_friend"
          @basic_profile_visible = has_login? && check_friend && check_be_friend
      end
      
      case @profile_contact_visible
        when "any"
          @contact_profile_visible = true
        when "login"
          @contact_profile_visible = check_login
        when "friend"
          @contact_profile_visible = has_login? && check_friend
        when "both_friend"
          @contact_profile_visible = has_login? && check_friend && check_be_friend
      end
      
      case @profile_hobby_visible
        when "any"
          @hobby_profile_visible = true
        when "login"
          @hobby_profile_visible = check_login
        when "friend"
          @hobby_profile_visible = has_login? && check_friend
        when "both_friend"
          @hobby_profile_visible = has_login? && check_friend && check_be_friend
      end
    end
    
    @basic_profile = BasicProfile.get_by_account(@account_id) if @basic_profile_visible
    @contact_profile = ContactProfile.get_by_account(@account_id) if @contact_profile_visible
    @hobby_profile = HobbyProfile.get_by_account(@account_id) if @hobby_profile_visible
    
    if @basic_profile
      all_provinces_cities_cache = Province.get_all_provinces_cities
      @province_name = Province.get_name(@basic_profile.province_id, all_provinces_cities_cache)
      @city_name = City.get_name(@basic_profile.city_id, all_provinces_cities_cache)
      
      @hometown_province_name = Province.get_name(@basic_profile.hometown_province_id, all_provinces_cities_cache)
      @hometown_city_name = City.get_name(@basic_profile.hometown_city_id, all_provinces_cities_cache)
    end
  end
  
  def wall
    @account_id = params[:id]
    
    @edit = (session[:account_id].to_s == @account_id)
    
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
  
  def actions
    @account_id = params[:id]
    @account_nick_pic = Account.get_nick_and_pic(@account_id)

    @action_type = params[:action_type]
    condition = (@action_type && @action_type != "") ? ["account_id = ? and action_type = ?", @account_id, @action_type] : ["account_id = ?", @account_id]
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @account_actions = AccountAction.visible.paginate(
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
    friends = Friend.get_account_friend_ids(@account_id)
    friend_condition = "account_id in (?)"
    condition = (@action_type && @action_type != "") ? ["#{friend_condition} and action_type = ?", friends, @action_type] : [friend_condition, friends]
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @account_actions = AccountAction.visible.paginate(
      :page => page,
      :per_page => Action_Page_Size,
      :conditions => condition,
      :include => [:account => [:profile_pic]],
      :order => "created_at DESC"
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
    
    jump_to("/spaces/wall/#{owner_id}")
  end
  
  def delete_comment
    @space_comment.destroy
    
    jump_to("/spaces/wall/#{session[:account_id]}")
  end
  
  
  def edit_point
    @account_id = params[:id]
    
    @account_nick_pic = Account.get_nick_and_pic(@account_id)
    
    @points = PointProfile.get_account_points(@account_id)
  end
  
  def update_point
    account_id = params[:id]
    
    if request.post?
      points = params[:points] && params[:points].strip
      reason = params[:reason] && params[:reason].strip
      
      if points && (points != "") && reason && (reason != "")
        points_num = points.to_i
        if PointProfile.adjust_account_points(account_id, points_num)
          # remind user by sending sys message
          SysMessage.create_new(account_id, "adjust_point", {
            :points => points_num,
            :reason => reason
          })
        end
      end
    end
    
    jump_to("/spaces/show/#{account_id}")
  end
  
  
  def edit_role
    @account_id = params[:id]
    
    @account_nick_pic = Account.get_nick_and_pic(@account_id)
    
    @roles = RoleProfile.get_account_roles(@account_id)
  end
  
  def update_role
    account_id = params[:id]
    
    if request.post?
      role_type = params[:role_type] && params[:role_type].strip
      role_desc = params[:role_desc] && params[:role_desc].strip
      
      role_profile = RoleProfile.new(
        :account_id => account_id,
        :role_type => role_type,
        :desc => role_desc
      )
      
      role_profile.save
    end
    
    jump_to("/spaces/edit_role/#{account_id}")
  end
  
  def destroy_role
    account_id = params[:id]
    role_id = params[:role_id]
    
    if request.post?
      role_profile = RoleProfile.find(role_id)
      
      role_profile.destroy
    end
    
    jump_to("/spaces/edit_role/#{account_id}")
  end
  
  
  def create_kind_hearted_role
    account_id = params[:id]
    jump_to("/errors/forbidden") unless session[:account_id].to_s == account_id
    
    if request.post?
      is_kind_hearted = false
      kind_hearted_role_id = RoleProfile.ids.kind_hearted_role_id
      RoleProfile.get_account_roles(account_id).each do |role|
        is_kind_hearted ||= (role[1] == kind_hearted_role_id)
      end
      
      unless is_kind_hearted
        role_profile = RoleProfile.new(
          :account_id => account_id,
          :role_type => kind_hearted_role_id
        )
        role_profile.save
      end
    end
    
    jump_to("/spaces/show/#{account_id}")
  end
  
  
  def destroy_account_action
    aa = AccountAction.find(params[:id])
    
    aa.destroy
    
    jump_to("/community")
  end
  
  
  private
  
  def check_comment_owner
    @space_comment = SpaceComment.find(params[:id])
    jump_to("/errors/forbidden") unless session[:account_id] == @space_comment.owner_id
  end
  
  
  def check_general_admin
    return jump_to("/errors/forbidden") unless ApplicationController.helpers.general_admin?(session[:account_id])
  end
  
  def check_info_editor
    return jump_to("/errors/forbidden") unless ApplicationController.helpers.info_editor?(session[:account_id])
  end
  
  def check_destroy_account_action
    check_general_admin
  end
  
end