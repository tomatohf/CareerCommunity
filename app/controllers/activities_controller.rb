class ActivitiesController < ApplicationController
  
  Activity_List_Size = 15
  Post_List_Size = 50
  Picture_List_Size = 15
  Photo_List_Size = 30
  Member_Page_Size = 30
  Unapprove_Page_Size = 30
  Members_Info_Page_Size = 100
  
  Activity_Recent_List_Size = 6
  Post_Recent_List_Size = 15
  Photo_Recent_List_Size = 5
  Picture_Recent_List_Size = 10

  Activity_Post_Num = 20
  New_Member_Num = 14
  Activity_Photo_Num = 6
  
  Activity_Group_Max_Count = 6
  
  Same_Creator_Activity_Num = 10
  
  Activity_Admin_Max_Count = 11
  
  New_Comment_Size = 30
  

  layout "community"
  before_filter :check_current_account, :only => [:recent_index, :list_group_index]
  before_filter :check_login, :only => [:new, :new_in_groups, :create, :activity_groups,
                                        :edit_image, :update_image, :check_profile, :join, :quit,
                                        :edit, :update, :update_desc, :update_access,
                                        :members_edit, :del_member, :unapproved,
                                        :approve_member, :reject_member, :invite, :invite_member,
                                        :absent_edit, :add_absent, :del_absent,
                                        :add_interest, :del_interest, :photo_selector_for_activity_image,
                                        :members_info, :cancel, :recover,
                                        :members_master, :add_admin, :del_admin, :edit_master, :update_master,
                                        :invite_contact, :select_contact, :send_contact_invitations]
  before_filter :check_limited, :only => [:create, :update_image, :check_profile, :join, :quit,
                                          :edit, :update, :update_desc, :update_access, :del_member,
                                          :approve_member, :reject_member, :invite_member,
                                          :add_absent, :del_absent, :add_interest, :del_interest,
                                          :cancel, :recover, :add_admin, :del_admin, :update_master,
                                          :send_contact_invitations]

  before_filter :check_activity_groups_account, :only => [:activity_groups]
  
  before_filter :check_activity_admin, :only => [:edit_image, :update_image,
                                                  :edit, :update, :update_desc, :update_access,
                                                  :absent_edit, :add_absent, :del_absent,
                                                  :approve_member, :reject_member,
                                                  :members_edit, :del_member, :unapproved, :members_info]
  before_filter :check_activity_master, :only => [:members_master, :add_admin, :del_admin,
                                                  :cancel, :recover, :edit_master, :update_master]
                                                  
  # before_filter :check_activity_member, :only => [:invite, :invite_member]
                                                  
  before_filter :check_activity_status_registering, :only => [:check_profile, :join, :quit,
                                                              :invite, :invite_member,
                                                              :invite_contact, :select_contact,
                                                              :send_contact_invitations]
  before_filter :check_activity_status_registered, :only => [:unapproved, :members_edit]
#  before_filter :check_activity_status_ongoing, :only => [:edit_image, :update_image,
#                                                          :edit, :update, :update_desc, :update_access]

  before_filter :check_activity_update_absent, :only => [:absent, :absent_edit, :add_absent, :del_absent]
  
  before_filter :check_activity_view_access, :only => [:show]
  before_filter :protect_activity_view_access, :only => [:members, :interest,
                                                          :check_profile, :join, :add_interest,
                                                          :photo, :post, :good_post,
                                                          :picture, :good_picture,
                                                          :invite, :invite_member,
                                                          :invite_contact, :select_contact,
                                                          :send_contact_invitations]
                                                          
  before_filter :check_owner, :only => [:all_picture]
  
  
  
  def index
    return jump_to("/activities/all") unless has_login?
    
    account_id = session[:account_id]
    
    account_setting = AccountSetting.get_account_setting(account_id)
    module_activity_index = account_setting.get_setting_value(:module_activity_index)
    
    url = case module_activity_index
      when "all"
        "all"
      when "recent"
        "recent/#{account_id}"
      when "join"
        "list_join/#{account_id}"
      when "week"
        "coming_week"
      when "create"
        "list_create/#{account_id}"
      else
        "all"
    end
    jump_to("/activities/#{url}")
  end
  
  def recent_index
    jump_to("/activities/recent/#{session[:account_id]}")
  end
  
  def list_group_index
    jump_to("/groups/all_activity/#{session[:account_id]}")
  end
  
  def recent
    @owner_id = params[:id]
    
    @edit = session[:account_id].to_s == @owner_id
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    
    @join_activity_members = ActivityMember.agreed.find(
      :all,
      :limit => Activity_Recent_List_Size,
      :conditions => ["account_id = ?", @owner_id],
      :include => [:activity => [:image]],
      :order => "join_at DESC"
    )
    
    @activity_interests = ActivityInterest.find(
      :all,
      :limit => Activity_Recent_List_Size,
      :conditions => ["account_id = ?", @owner_id],
      :include => [:activity => [:image]],
      :order => "created_at DESC"
    )
    
    
    @join_activity_posts = ActivityPost.find(
      :all,
      :limit => Post_Recent_List_Size,
      :select => "activity_posts.id, activity_posts.created_at, activity_posts.activity_id, activity_posts.top, activity_posts.good, activity_posts.account_id, activity_posts.title, activity_posts.responded_at, activity_posts.responded_by",
      :joins => "INNER JOIN activity_members ON activity_posts.activity_id = activity_members.activity_id",
      :conditions => ["activity_members.account_id = ? and activity_members.accepted = 1 and activity_members.approved = 1", 
                      @owner_id],
      :order => "activity_posts.responded_at DESC"
    )
    
    @interest_activity_posts = ActivityPost.find(
      :all,
      :limit => Post_Recent_List_Size,
      :select => "activity_posts.id, activity_posts.created_at, activity_posts.activity_id, activity_posts.top, activity_posts.good, activity_posts.account_id, activity_posts.title, activity_posts.responded_at, activity_posts.responded_by",
      :joins => "INNER JOIN activity_interests ON activity_posts.activity_id = activity_interests.activity_id",
      :conditions => ["activity_interests.account_id = ?", @owner_id],
      :order => "activity_posts.responded_at DESC"
    )
    
    @activity_photos = ActivityPhoto.find(
      :all,
      :limit => Photo_Recent_List_Size,
      :joins => "INNER JOIN activity_members ON activity_photos.activity_id = activity_members.activity_id",
      :conditions => ["activity_members.account_id = ? and activity_members.accepted = 1 and activity_members.approved = 1", 
                      @owner_id],
      :order => "activity_photos.created_at DESC"
    )
    ActivityPhoto.load_associations(@activity_photos, [:photo]) if @activity_photos.size > 0
    
    @activity_pictures = ActivityPicture.find(
      :all,
      :limit => Picture_Recent_List_Size,
      :joins => "INNER JOIN activity_members ON activity_pictures.activity_id = activity_members.activity_id",
      :conditions => ["activity_members.account_id = ? and activity_members.accepted = 1 and activity_members.approved = 1", 
                      @owner_id],
      :order => "activity_pictures.responded_at DESC"
    )
    
  end
  
  def list_join
    @owner_id = params[:id]
    
    @edit = (session[:account_id].to_s == params[:id])
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @activities = ActivityMember.agreed.paginate(
      :page => page,
      :per_page => Activity_List_Size,
      :conditions => ["account_id = ?", @owner_id],
      :include => [:activity => [:image]],
      :order => "join_at DESC"
    )
  end
  
  def list_create
    @owner_id = params[:id]
    
    @edit = (session[:account_id].to_s == params[:id])
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @activities = Activity.uncancelled.paginate(
      :page => page,
      :per_page => Activity_List_Size,
      :conditions => ["creator_id = ?", @owner_id],
      :include => [:image],
      :order => "created_at DESC"
    )
  end
  
  def list_interest
    @owner_id = params[:id]
    
    @edit = (session[:account_id].to_s == params[:id])
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @activities = ActivityInterest.paginate(
      :page => page,
      :per_page => Activity_List_Size,
      :conditions => ["account_id = ?", @owner_id],
      :include => [:activity => [:image]],
      :order => "created_at DESC"
    )
  end
  
  def del_interest
    activity_id = params[:id]
    ActivityInterest.find(
      :all,
      :conditions => ["activity_id = ? and account_id = ?", activity_id, session[:account_id]]
    ).each { |ai| ai.destroy }
    
    jump_to("/activities/list_interest/#{session[:account_id]}")
  end
  
  
  # def list_notbegin_join
  #   @owner_id = params[:id]
  #   
  #   @edit = (session[:account_id].to_s == params[:id])
  #   
  #   @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
  #   
  #   page = params[:page]
  #   page = 1 unless page =~ /\d+/
  #   @activities = ActivityMember.agreed.paginate(
  #     :page => page,
  #     :per_page => Activity_List_Size,
  #     :conditions => ["account_id = ? and activities.begin_at > ?", @owner_id, DateTime.now],
  #     :include => [:activity => [:image]],
  #     :order => "activities.begin_at ASC"
  #   )
  # end
  
  def list_friend
    @owner_id = params[:id]
    
    @edit = (session[:account_id].to_s == params[:id])
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    @friends = Friend.get_account_friend_ids(@owner_id).reverse
  end
  
  def created_post
    @owner_id = params[:id]
    
    @edit = session[:account_id].to_s == @owner_id
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @created_posts = ActivityPost.paginate(
      :page => page,
      :per_page => Post_List_Size,
      :select => "id, created_at, activity_id, account_id, title, good, responded_at, responded_by",
      :conditions => ["account_id = ?", @owner_id],
      :order => "responded_at DESC"
    )
  end
  
  def commented_post
    @owner_id = params[:id]
    
    @edit = session[:account_id].to_s == @owner_id
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @commented = ActivityPostComment.paginate(
      :page => page,
      :per_page => Post_List_Size,
      :select => "activity_post_comments.activity_post_id, activity_post_comments.created_at",
      :joins => "LEFT JOIN activity_post_comments comments ON activity_post_comments.activity_post_id = comments.activity_post_id AND activity_post_comments.account_id = comments.account_id AND activity_post_comments.created_at < comments.created_at",
      :conditions => ["comments.activity_post_id IS NULL and activity_post_comments.account_id = ?", @owner_id],
      :order => "activity_post_comments.created_at DESC"
    )
    # the posts are order by the latest time when it's commented
    post_ids = @commented.collect { |comment| comment.activity_post_id }
    posts = ActivityPost.find(
      :all,
      :select => "id, created_at, activity_id, account_id, title, good, responded_at, responded_by",
      :conditions => ["id in (?)", post_ids]
    )
    @commented_posts = post_ids.collect { |post_id| posts.detect { |post| post.id == post_id } }
  end
  
  def all_join_post
    @owner_id = params[:id]
    
    @type = "参加"
    
    @edit = session[:account_id].to_s == @owner_id
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @all_posts = ActivityPost.paginate(
      :page => page,
      :per_page => Post_List_Size,
      :select => "activity_posts.id, activity_posts.created_at, activity_posts.activity_id, activity_posts.top, activity_posts.good, activity_posts.account_id, activity_posts.title, activity_posts.responded_at, activity_posts.responded_by",
      :joins => "INNER JOIN activity_members ON activity_posts.activity_id = activity_members.activity_id",
      :conditions => ["activity_members.account_id = ? and activity_members.accepted = 1 and activity_members.approved = 1", 
                      @owner_id],
      :order => "activity_posts.responded_at DESC"
    )
    
    render(:action => "all_post")
  end
  
  def all_interest_post
    @owner_id = params[:id]
    
    @type = "感兴趣"
    
    @edit = session[:account_id].to_s == @owner_id
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @all_posts = ActivityPost.paginate(
      :page => page,
      :per_page => Post_List_Size,
      :select => "activity_posts.id, activity_posts.created_at, activity_posts.activity_id, activity_posts.account_id, activity_posts.title, activity_posts.good, activity_posts.responded_at, activity_posts.responded_by",
      :joins => "INNER JOIN activity_interests ON activity_posts.activity_id = activity_interests.activity_id",
      :conditions => ["activity_interests.account_id = ?", @owner_id],
      :order => "activity_posts.responded_at DESC"
    )
    
    render(:action => "all_post")
  end
  
  def all
    @date = Date.today
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @activities = Activity.get_activities_all_list(page)
    
    render(:action => "day")
  end
  
  def coming_day
    @date = Date.today
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @activities = Activity.paginate_list_by_begin_at(@date, 1.days.since(@date), page, Activity_List_Size)
    
    render(:action => "day")
  end
  
  def coming_week
    @date = Date.today
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @activities = Activity.paginate_list_by_begin_at(@date, 1.weeks.since(@date), page, Activity_List_Size)
    
    render(:action => "day")
  end
  
  def coming_month
    @date = Date.today
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @activities = Activity.paginate_list_by_begin_at(@date, 1.months.since(@date), page, Activity_List_Size)
    
    render(:action => "day")
  end
  
  def coming_half_year
    @date = Date.today
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @activities = Activity.paginate_list_by_begin_at(@date, 6.months.since(@date), page, Activity_List_Size)
    
    render(:action => "day")
  end
  
  def day
    begin
      @date = Date.parse(params[:date])
    rescue
      return jump_to("/activities/all")
    end
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @activities = Activity.paginate_list_by_begin_at(@date, 1.days.since(@date), page, Activity_List_Size)
    
    render(:action => "day")
  end
  
  
  def new
    @activity = Activity.new
  end
  
  def new_in_groups
    in_group_id = params[:in_group_id] || []
    
    if in_group_id.size > 0
      if in_group_id.size > Activity_Group_Max_Count
        # select too many groups
        flash[:error_msg] = "选择的圈子数目超过限制"
      else
        # OK
        @in_groups = in_group_id.collect { |group_id|
          Group.get_group_with_image(group_id)
        }
        
        new
        return render(:action => "new")
      end
    else
      # not select group
      flash[:error_msg] = "还没有选择任何圈子"
    end
    
    jump_to("/activities/activity_groups/#{session[:account_id]}")
  end
  
  def activity_groups
    @account_id = params[:id]
    
    @group_members = GroupMember.agreed.find(
      :all,
      :conditions => ["account_id = ?", @account_id],
      :include => [:group => [:image]],
      :order => "join_at DESC"
    )
    
    @multiple = false
  end
  
  def create
    @activity = Activity.new(:creator_id => session[:account_id], :master_id => session[:account_id])
    
    @activity.online = (params[:activity_online] == "true")
    
    # NOT handle the case of multiple groups
    activity_groups_id = params[:activity_groups] || []
    @activity.in_group = activity_groups_id.size > 0 ?  activity_groups_id[0] : 0
    # check group member
    if @activity.in_group && @activity.in_group > 0
      return jump_to("/errors/forbidden") unless GroupMember.is_group_member(@activity.in_group, session[:account_id])
      
      @in_groups = [Group.get_group_with_image(@activity.in_group)]
    end
    
    
    @activity.title = params[:activity_title] && params[:activity_title].strip
    @activity.place = params[:activity_place] && params[:activity_place].strip
    
    # parse date time values
    @activity.begin_at = params[:activity_begin_at]
    @activity.end_at = params[:activity_end_at]
    @activity.application_deadline = params[:activity_application_deadline]
    
    @activity.member_limit = params[:activity_member_limit] && params[:activity_member_limit].strip
    @activity.cost = params[:activity_cost] && params[:activity_cost].strip
    
    activity_setting = {
      :desc => params[:activity_desc],
      
      :need_approve => (params[:need_approve] == "true"),

      :check_mobile => (params[:check_mobile] == "true"),
      :check_real_name => (params[:check_real_name] == "true"),
      :check_gender => (params[:check_gender] == "true"),
      :check_birthday => (params[:check_birthday] == "true"),
      
      :contact => params[:activity_contact]
    }
    @activity.fill_setting(activity_setting)
    
    if @activity.save
      # join the activity
      if ActivityMember.add_account_to_activity(@activity.id, session[:account_id], true)
        return render(:action => "edit_image")
      else
        @activity.destroy
        flash.now[:error_msg] = "创建活动的过程中遇到错误, 再试一次吧"
      end
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render(:action => "new")
  end
  
  def edit_image
    @activity, @activity_image = Activity.get_activity_with_image(@activity_id)
    
  end
  
  def update_image
    activity_image = ActivityImage.get_by_activity(@activity_id) || ActivityImage.new(:activity_id => @activity_id)
    
    old_photo_id = activity_image.photo_id
    activity_image.photo_id = params[:photo_id]
    
    # validate the photo
    if activity_image.photo_id && activity_image.photo_id != old_photo_id
      photo = activity_image.photo_id && Photo.get_photo(activity_image.photo_id)
      if photo && photo.account_id == session[:account_id]
        if activity_image.save
          Activity.update_activity_with_image_cache(@activity_id, :activity_img => photo.image.url(:thumb_48))
          flash.now[:message] = "已成功保存"
        else
          flash.now[:error_msg] = "操作失败, 再试一次吧"
        end
      else
        jump_to("/errors/forbidden")
      end
    end
  end
  
  def photo_selector_for_activity_image
    albums = Album.get_all_names_by_account_id(session[:account_id])
    render :partial => "albums/photo_selector", :locals => {:albums => albums, :photo_list_template => "/profiles/album_photo_list_for_face"}
  end
  
  def show
    # @activity_id = params[:id]
    # @activity, @activity_image = Activity.get_activity_with_image(@activity_id)
    
    @is_master = (@activity.master_id == session[:account_id])
    @is_member = has_login? && ActivityMember.is_activity_member(@activity_id, session[:account_id])
    @is_admin = @is_master || (@is_member && @is_member.admin)
    @beyond_limit = (@activity.get_status[0] <= Activity::Status::Registering[0]) && (!@is_member) && is_activity_member_beyond_limit(@activity)
    
    @can_add_interest = has_login? && (!@is_member) && (!ActivityInterest.is_interest_activity(session[:account_id], @activity_id))
    
    @creator_id = @activity.creator_id
    @creator_nick_pic = Account.get_nick_and_pic(@creator_id)
    
    in_group = @activity.in_group || 0
    @group, @group_image = Group.get_group_with_image(in_group) if in_group > 0
    
    @activity_setting = @activity.get_setting
    
    need_join_to_view_member = @activity_setting[:need_join_to_view_member]
    @can_view_member = !(need_join_to_view_member && (!@is_member))
    
    need_join_to_view_picture = @activity_setting[:need_join_to_view_picture]
    @can_view_picture = !(need_join_to_view_picture && (!@is_member))
    
    need_join_to_add_post = @activity_setting[:need_join_to_add_post]
    @can_add_post = !(need_join_to_add_post && (!@is_member))
    
    @place_point = Activity.get_activity_place_point(@activity_id)
    
    @top_activity_posts = ActivityPost.find(
      :all,
      :select => "id, created_at, activity_id, top, good, account_id, title, responded_at, responded_by",
      :conditions => ["activity_id = ? and top = ?", @activity_id, true],
      :order => "responded_at DESC"
    )
    
    @activity_posts = ActivityPost.find(
      :all,
      :limit => Activity_Post_Num,
      :select => "id, created_at, activity_id, top, good, account_id, title, responded_at, responded_by",
      :conditions => ["activity_id = ? and top = ?", @activity_id, false],
      :order => "responded_at DESC"
    )
    
    @interest_accounts = ActivityInterest.find(
      :all,
      :limit => New_Member_Num,
      :conditions => ["activity_id = ?", @activity_id],
      :include => [:account => [:profile_pic]],
      :order => "created_at DESC"
    )
    
    @members = ActivityMember.agreed.find(
      :all,
      :limit => New_Member_Num,
      :conditions => ["activity_id = ?", @activity_id],
      :include => [:account => [:profile_pic]],
      :order => "join_at DESC"
    ) if @can_view_member
    
    @activity_photos = ActivityPhoto.find(
      :all,
      :limit => Activity_Photo_Num,
      :conditions => ["activity_id = ?", @activity_id],
      :include => [:photo],
      :order => "created_at DESC"
    )
    @all_activity_photo_count = ActivityPhoto.get_count(@activity_id) if @activity_photos.size > 0
    
    @activity_pictures = ActivityPicture.find(
      :all,
      :limit => Activity_Photo_Num,
      :conditions => ["activity_id = ?", @activity_id],
      :order => "responded_at DESC"
    )
    @all_activity_picture_count = ActivityPicture.get_count(@activity_id) if @activity_pictures.size > 0
    
    # @created_activities value is set in view ...
  end
  
  def cache_point
    activity_id = params[:id]
    
    if ActivityMember.is_activity_admin(activity_id, session[:account_id])
      point_x = params[:point_x]
      point_y = params[:point_y]
      Activity.set_activity_place_point(activity_id, point_x, point_y)
    end
    
    render :layout => false, :text => ""
  end
  
  def post
    @activity_id = params[:id]
    @activity, @activity_image = Activity.get_activity_with_image(@activity_id)
    
    @top_activity_posts = ActivityPost.find(
      :all,
      :select => "id, created_at, activity_id, top, good, account_id, title, responded_at, responded_by",
      :conditions => ["activity_id = ? and top = ?", @activity_id, true],
      :order => "responded_at DESC"
    )
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @activity_posts = ActivityPost.paginate(
      :page => page,
      :per_page => Post_List_Size,
      :select => "id, created_at, activity_id, top, good, account_id, title, responded_at, responded_by",
      :conditions => ["activity_id = ? and top = ?", @activity_id, false],
      :order => "responded_at DESC"
    )
  end
  
  def good_post
    @activity_id = params[:id]
    @activity, @activity_image = Activity.get_activity_with_image(@activity_id)
    
    @top_activity_posts = ActivityPost.good.find(
      :all,
      :select => "id, created_at, activity_id, top, good, account_id, title, responded_at, responded_by",
      :conditions => ["activity_id = ? and top = ?", @activity_id, true],
      :order => "responded_at DESC"
    )
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @activity_posts = ActivityPost.good.paginate(
      :page => page,
      :per_page => Post_List_Size,
      :select => "id, created_at, activity_id, top, good, account_id, title, responded_at, responded_by",
      :conditions => ["activity_id = ? and top = ?", @activity_id, false],
      :order => "responded_at DESC"
    )
  end
  
  def picture
    @activity_id = params[:id]
    @activity, @activity_image = Activity.get_activity_with_image(@activity_id)
    
    need_join_to_view_picture = @activity.get_setting[:need_join_to_view_picture]
    @can_view = !(need_join_to_view_picture && (!ActivityMember.is_activity_member(@activity_id, session[:account_id])))
    
    if @can_view
      page = params[:page]
      page = 1 unless page =~ /\d+/
      @activity_pictures = ActivityPicture.paginate(
        :page => page,
        :per_page => Picture_List_Size,
        :conditions => ["activity_id = ?", @activity_id],
        :order => "responded_at DESC"
      )
      
      @new_comments = ActivityPictureComment.find(
        :all,
        :limit => New_Comment_Size,
        :conditions => ["activity_picture_id in (select id from activity_pictures where activity_id = ?)", @activity_id],
        :order => "updated_at DESC"
      )
    end
  end
  
  def good_picture
    @activity_id = params[:id]
    @activity, @activity_image = Activity.get_activity_with_image(@activity_id)
    
    need_join_to_view_picture = @activity.get_setting[:need_join_to_view_picture]
    @can_view = !(need_join_to_view_picture && (!ActivityMember.is_activity_member(@activity_id, session[:account_id])))
    
    if @can_view
      page = params[:page]
      page = 1 unless page =~ /\d+/
      @activity_pictures = ActivityPicture.good.paginate(
        :page => page,
        :per_page => Picture_List_Size,
        :conditions => ["activity_id = ?", @activity_id],
        :order => "responded_at DESC"
      )
      
      @new_comments = ActivityPictureComment.find(
        :all,
        :limit => New_Comment_Size,
        :conditions => ["activity_picture_id in (select id from activity_pictures where activity_id = ? and good = ?)", @activity_id, true],
        :order => "updated_at DESC"
      )
    end
  end
  
  def photo
    @activity_id = params[:id]
    @activity, @activity_image = Activity.get_activity_with_image(@activity_id)
    
    @is_admin = ActivityMember.is_activity_admin(@activity_id, session[:account_id])
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @activity_photos = ActivityPhoto.paginate(
      :page => page,
      :per_page => Photo_List_Size,
      :total_entries => ActivityPhoto.get_count(@activity_id),
      :conditions => ["activity_id = ?", @activity_id],
      :include => [:photo, :account],
      :order => "created_at DESC"
    )
  end
  
  def all_photo
    @owner_id = params[:id]
    
    @edit = session[:account_id].to_s == @owner_id
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @all_photos = ActivityPhoto.paginate(
      :page => page,
      :per_page => Photo_List_Size,
      :joins => "INNER JOIN activity_members ON activity_photos.activity_id = activity_members.activity_id",
      :conditions => ["activity_members.account_id = ? and activity_members.accepted = 1 and activity_members.approved = 1", 
                      @owner_id],
      :order => "activity_photos.created_at DESC"
    )
    ActivityPhoto.load_associations(@all_photos, [:photo, :account, :activity]) if @all_photos.size > 0
  end
  
  def all_picture
    @owner_id = params[:id]
    
    @edit = session[:account_id].to_s == @owner_id
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @all_pictures = ActivityPicture.paginate(
      :page => page,
      :per_page => Picture_List_Size,
      :joins => "INNER JOIN activity_members ON activity_pictures.activity_id = activity_members.activity_id",
      :conditions => ["activity_members.account_id = ? and activity_members.accepted = 1 and activity_members.approved = 1", 
                      @owner_id],
      :order => "activity_pictures.responded_at DESC"
    )
    
    @new_comments = ActivityPictureComment.find(
      :all,
      :limit => New_Comment_Size,
      :conditions => ["activity_picture_id in (?)", @all_pictures],
      :order => "id DESC"
    )
  end
  
  def check_profile
    # @activity_id = params[:id]
    # @activity, @activity_image = Activity.get_activity_with_image(@activity_id)


    # check if need to check profile
    activity_setting = @activity.get_setting
    @check_mobile = activity_setting[:check_mobile] && (!@activity.online)
    @check_real_name = activity_setting[:check_real_name] && (!@activity.online)
    @check_gender = activity_setting[:check_gender] && (!@activity.online)
    @check_birthday = activity_setting[:check_birthday] && (!@activity.online)
    
    @need_approve = activity_setting[:need_approve]
    
    if (!@need_approve) && (!@check_mobile) && (!@check_real_name) && (!@check_gender) && (!@check_birthday)
      join
      render(:action => "join") unless performed_render_or_redirect
      return
    end
    
    # check group member for group activity
    in_group = @activity.in_group
    if in_group && in_group > 0
      unless GroupMember.is_group_member(in_group, session[:account_id])
        @group, @group_image = Group.get_group_with_image(in_group)
        return render(:action => "join")
      end
    end
    
    @basic_profile = (BasicProfile.get_by_account(session[:account_id]) || BasicProfile.new) if @check_real_name || @check_gender || @check_birthday
    @contact_profile = ContactProfile.get_by_account(session[:account_id]) if @check_mobile
  end
  
  def join
    # @activity_id = params[:id]
    # @activity, @activity_image = Activity.get_activity_with_image(@activity_id)

    
    # save profile if needed
    real_name = params[:real_name] && params[:real_name].strip
    gender = params[:gender] && params[:gender].strip
    gender = nil if gender == ""
    birthday_year = params[:birthday_year]
    birthday_month = params[:birthday_month]
    birthday_date = params[:birthday_date]
    begin
      birthday = Date.new(birthday_year.to_i, birthday_month.to_i, birthday_date.to_i)
    rescue
      birthday = nil
    end
    if (real_name && real_name != "") || gender || birthday
      basic_profile = BasicProfile.get_by_account(session[:account_id]) || BasicProfile.new(:account_id => session[:account_id])
      if gender
        basic_profile.gender = case gender
          when "true"
            true
          when "false"
            false
          else
            nil
        end
      end
      basic_profile.birthday = birthday if birthday
      basic_profile.real_name = real_name
      basic_profile.save
    end
    mobile = params[:mobile] && params[:mobile].strip
    if mobile && mobile != ""
      contact_profile = ContactProfile.get_by_account(session[:account_id]) || ContactProfile.new(:account_id => session[:account_id])
      contact_profile.mobile = mobile
      contact_profile.save
    end
    
    
    
    # check activity member limit
    return jump_to("/activities/#{@activity_id}") if is_activity_member_beyond_limit(@activity)
    
    # check group member for group activity
    in_group = @activity.in_group
    if in_group && in_group > 0
      unless GroupMember.is_group_member(in_group, session[:account_id])
        @group, @group_image = Group.get_group_with_image(in_group)
        return
      end
    end
    
    
    need_approve = @activity.get_setting[:need_approve]
    
    activity_member = ActivityMember.join_activity(@activity_id, session[:account_id], need_approve)
    
    if activity_member.agreed || (!need_approve)
      return jump_to("/activities/members/#{@activity_id}")
    end
    
    # need to wait for the approval of activity master
    
    # send sys message to admins
    SysMessage.transaction do
      activity_admins = ActivityMember.get_activity_admins(@activity_id, false)
      activity_admins.each do |aa|
        SysMessage.create_new(aa.account_id, "join_activity_request", {
          :requester_id => session[:account_id],
          :activity_id => @activity_id,
          :message => params[:apply_msg]
        })
      end
    end
  end
  
  def quit
    # @activity_id = params[:id]
    # @activity, @activity_image = Activity.get_activity_with_image(@activity_id)
    
    if @activity.master_id != session[:account_id]
      # not activity master
      ActivityMember.remove_account_from_activity(@activity_id, session[:account_id])
      return jump_to("/activities/#{@activity_id}")
    end
    
    # group master can NOT quit the group
  end
  
  def add_interest
    activity_id = params[:id]
    
    unless ActivityInterest.is_interest_activity(session[:account_id], activity_id)
      # has not been added as interest activity_id
      ActivityInterest.add_interest_activity(session[:account_id], activity_id)
    end
    
    jump_to("/activities/#{activity_id}")
  end
  
  
  def edit
    @activity, @activity_image = Activity.get_activity_with_image(@activity_id)
    
    @in_groups = [Group.get_group_with_image(@activity.in_group)] if @activity.in_group && @activity.in_group > 0
  end
  
  def update
    @activity, @activity_image = Activity.get_activity_with_image(@activity_id)
    
    @old_activity_title = @activity.get_title
    
    @activity.online = (params[:activity_online] == "true")
    
    @in_groups = [Group.get_group_with_image(@activity.in_group)] if @activity.in_group && @activity.in_group > 0
    
    @activity.title = params[:activity_title] && params[:activity_title].strip
    @activity.place = params[:activity_place] && params[:activity_place].strip
    
    # parse date time values
    @activity.begin_at = params[:activity_begin_at]
    @activity.end_at = params[:activity_end_at]
    @activity.application_deadline = params[:activity_application_deadline]
    
    @activity.member_limit = params[:activity_member_limit] && params[:activity_member_limit].strip
    @activity.cost = params[:activity_cost] && params[:activity_cost].strip
    
    activity_setting = {
      :contact => params[:activity_contact]
    }
    @activity.update_setting(activity_setting)
    
    if is_activity_member_beyond_limit(@activity, false)
      flash.now[:error_msg] = "活动的人数限制 小于 当前已经报名的人数"
      return render(:action => "edit")
    end
    
    if @activity.save
      @old_activity_title = nil
      flash.now[:message] = "活动信息已成功修改"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render(:action => "edit")
  end
  
  def update_desc
    @activity, @activity_image = Activity.get_activity_with_image(@activity_id)
    
    @in_groups = [Group.get_group_with_image(@activity.in_group)] if @activity.in_group && @activity.in_group > 0
    
    activity_setting = {
      :desc => params[:activity_desc]
    }
    @activity.update_setting(activity_setting)
    
    if @activity.save
      @old_activity_title = nil
      flash.now[:message] = "活动描述已成功修改"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render(:action => "edit")
  end
  
  def update_access
    @activity, @activity_image = Activity.get_activity_with_image(@activity_id)
    
    @in_groups = [Group.get_group_with_image(@activity.in_group)] if @activity.in_group && @activity.in_group > 0
    
    activity_setting = {
      :need_approve => (params[:need_approve] == "true"),

      :check_mobile => (params[:check_mobile] == "true"),
      :check_real_name => (params[:check_real_name] == "true"),
      :check_gender => (params[:check_gender] == "true"),
      :check_birthday => (params[:check_birthday] == "true"),
      
      :need_join_group_to_view => (params[:need_join_group_to_view] == "true"),
      :need_join_to_view_member => (params[:need_join_to_view_member] == "true"),
      :need_join_to_add_post => (params[:need_join_to_add_post] == "true"),
      :need_join_to_view_post => (params[:need_join_to_view_post] == "true"),
      :need_join_to_view_picture => (params[:need_join_to_view_picture] == "true"),
      :hide_map => (params[:hide_map] == "true")
    }
    @activity.update_setting(activity_setting)
    
    if @activity.save
      @old_activity_title = nil
      flash.now[:message] = "活动的报名设置已成功修改"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render(:action => "edit")
  end
  
  
  def members
    @activity_id ||= params[:id]
    @activity, @activity_image = Activity.get_activity_with_image(@activity_id) unless @activity
    
    need_join_to_view_member = @activity.get_setting[:need_join_to_view_member]
    @can_view_member = !(need_join_to_view_member && (!ActivityMember.is_activity_member(@activity_id, session[:account_id])))
    
    if @can_view_member
    
      @master_id = @activity.master_id
      @master_nick_pic = Account.get_nick_and_pic(@master_id)
    
      @admin_members = ActivityMember.get_activity_admins(@activity_id)
    
      # check and ensure admins include activity master
      master_member = @admin_members.select {|m| (m.account_id == @master_id) && m.admin }[0]
      ActivityMember.add_account_to_activity(@activity_id, @master_id, true) unless master_member
    
      page = params[:page]
      page = 1 unless page =~ /\d+/
      @members = ActivityMember.paginate_activity_members(@activity_id, page, Member_Page_Size)
      
    end
  end
  
  def members_edit
    @is_admin = true
    members
    render :action => "members"
  end
  
  def members_master
    @is_master = true
    members
    render :action => "members"
  end
  
  def interest
    @activity_id = params[:id]
    @activity, @activity_image = Activity.get_activity_with_image(@activity_id)
    
    @master_id = @activity.master_id
    @master_nick_pic = Account.get_nick_and_pic(@master_id)
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @accounts = ActivityInterest.paginate_activity_interest_accounts(@activity_id, page, Member_Page_Size)
  end
  
  def absent
    # done in before filter
    # @activity_id ||= params[:id]
    # @activity, @activity_image = Activity.get_activity_with_image(@activity_id)
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @attend_members = ActivityMember.paginate_activity_attend_members(@activity_id, page, Member_Page_Size)
    
    @absent_members = ActivityMember.get_activity_absent_members(@activity_id)
  end
  
  def absent_edit
    @is_master = true
    absent
    render :action => "absent"
  end
  
  def add_absent
    member_id = params[:add_absent_id]
    
    activity_member = ActivityMember.get_by_activity_and_account(@activity_id, member_id)
    if activity_member && activity_member.agreed && (!activity_member.absent)
      activity_member.absent = true
      activity_member.save
    end
    
    jump_to("/activities/absent_edit/#{@activity_id}")
  end
  
  def del_absent
    member_id = params[:del_absent_id] && params[:del_absent_id].strip
    
    activity_member = ActivityMember.get_by_activity_and_account(@activity_id, member_id)
    if activity_member && activity_member.absent
      activity_member.absent = false
      activity_member.save
    end
    
    jump_to("/activities/absent_edit/#{@activity_id}")
  end
  
  def attend_stat
    @owner_id = params[:id]
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id)
    
    @attend_activity_members = ActivityMember.agreed.find(
      :all,
      :limit => Activity_List_Size,
      :conditions => ["account_id = ? and absent = ?", @owner_id, false],
      :include => [:activity => [:image]],
      :order => "join_at DESC"
    )
    
    @absent_activity_members = ActivityMember.agreed.find(
      :all,
      :limit => Activity_List_Size,
      :conditions => ["account_id = ? and absent = ?", @owner_id, true],
      :include => [:activity => [:image]],
      :order => "join_at DESC"
    )
    
    @attend_count = ActivityMember.agreed.count(
      :conditions => ["account_id = ? and absent = ?", @owner_id, false]
    )
    @absent_count = ActivityMember.agreed.count(
      :conditions => ["account_id = ? and absent = ?", @owner_id, true]
    )
  end
  
  def list_attend
    @owner_id = params[:id]
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @activities = ActivityMember.agreed.paginate(
      :page => page,
      :per_page => Activity_List_Size,
      :conditions => ["account_id = ? and absent = ?", @owner_id, false],
      :include => [:activity => [:image]],
      :order => "join_at DESC"
    )
    
    render(:action => "list_attend_absent")
  end
  
  def list_absent
    @owner_id = params[:id]
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @activities = ActivityMember.agreed.paginate(
      :page => page,
      :per_page => Activity_List_Size,
      :conditions => ["account_id = ? and absent = ?", @owner_id, true],
      :include => [:activity => [:image]],
      :order => "join_at DESC"
    )

    render(:action => "list_attend_absent")
  end
  
  def del_member
    @activity, @activity_image = Activity.get_activity_with_image(@activity_id)
    
    member_id = params[:del_member_id]
    if @activity.master_id.to_s != member_id
      activity_member = ActivityMember.get_by_activity_and_account(@activity_id, member_id)
      if activity_member
        activity_member.destroy
        SysMessage.create_new(activity_member.account_id, "deleted_from_activity", {
          :deleted_by_id => session[:account_id],
          :activity_id => @activity_id
        })
      end
    end
    
    jump_to("/activities/members_edit/#{@activity_id}")
  end
  
  def add_admin
    member_id = params[:add_admin_id] && params[:add_admin_id].strip
    
    # disable admin count check ...
    # since it's not so necessary
    # while it would require extra index
    # admin_count = ActivityMember.agreed.count(:conditions => ["activity_id = ? and admin = ?", @activity_id, true])
    # if admin_count < Activity_Admin_Max_Count
      activity_member = ActivityMember.get_by_activity_and_account(@activity_id, member_id)
      if activity_member && activity_member.agreed && (!activity_member.admin)
        activity_member.admin = true
        activity_member.save
      end
    # end
    
    jump_to("/activities/members_master/#{@activity_id}")
  end
  
  def del_admin
    member_id = params[:del_admin_id] && params[:del_admin_id].strip
    
    if @activity.master_id.to_s != member_id
      # must be NOT activity master
      activity_member = ActivityMember.get_by_activity_and_account(@activity_id, member_id)
      if activity_member && activity_member.admin
        activity_member.admin = false
        activity_member.save
      end
    end
    
    jump_to("/activities/members_master/#{@activity_id}")
  end
  
  def unapproved
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @unapproved_members = ActivityMember.paginate_unapproved_members(@activity_id, page, Unapprove_Page_Size)
  end
  
  def approve_member
    @activity, @activity_image = Activity.get_activity_with_image(@activity_id)
    
    approve_member_id = params[:approve_member_id]
    
    if is_activity_member_beyond_limit(@activity)
      flash[:error_msg] = "无法批准, 报名参加活动的人数已经达到人数限制"
    else
      
      activity_member = ActivityMember.get_by_activity_and_account(@activity_id, approve_member_id)
      if activity_member && activity_member.accepted && (!activity_member.approved)
        activity_member.approved = true
        activity_member.join_at = DateTime.now
        if activity_member.save
          SysMessage.create_new(activity_member.account_id, "approve_reject_join_activity", {
            :admin_account_id => session[:account_id],
            :activity_id => @activity_id,
            :approve => true
          })
        end
      end
    
    end

    jump_to("/activities/unapproved/#{@activity_id}")
  end
  
  def reject_member
    reject_member_id = params[:reject_member_id]
    
    activity_member = ActivityMember.get_by_activity_and_account(@activity_id, reject_member_id)
    if activity_member && activity_member.accepted && (!activity_member.approved)
      activity_member.destroy
      
      SysMessage.create_new(activity_member.account_id, "approve_reject_join_activity", {
          :admin_account_id => session[:account_id],
          :activity_id => @activity_id,
          :approve => false,
          :message => params[:reject_message]
        })
    end
    
    jump_to("/activities/unapproved/#{@activity_id}")
  end
  
  def invite
    @is_admin = ActivityMember.is_activity_admin(@activity_id, session[:account_id])
    
    @friends = Friend.get_account_friend_ids(session[:account_id]).reverse
    
    @unaccepted_members = ActivityMember.get_unaccepted_members(@activity_id) if @is_admin
  end
  
  def invite_member
    invited_account_id = params[:invited_account_id] || []
    invitation_words = (params[:invitation_words] && params[:invitation_words].strip) || ""
    invitation_way = params[:invitation_way]
    
    if invitation_words.size > 100
      flash[:error_msg] = "邀请的话 超过长度限制"
    elsif invited_account_id.size <= 0
      flash[:error_msg] = "还没有选择想邀请的朋友"
    else
      is_admin = GroupMember.is_group_admin(@group_id, session[:account_id])
      
      existing = ActivityMember.find(
        :all,
        :conditions => ["activity_id = ? and account_id in (?)", @activity_id, invited_account_id]
      )
      
      no_need_insert = []
      need_update = []
      no_need_invite = []
      existing.each do |m|
        no_need_insert << m.account_id.to_s
        if m.approved
          no_need_invite << m.account_id.to_s if m.accepted
        else
          need_update << m.id if m.accepted
        end
      end
      
      need_insert = invited_account_id - no_need_insert
      need_invite = invited_account_id - no_need_invite
      
      
      if is_admin
        ActivityMember.update_all(
          ["approved = ?, join_at = ?", true, DateTime.now],
          ["id in (?)", need_update]
        ) if need_update.size > 0
      
        ActivityMember.transaction do
          need_insert.each do |account_id|
            ActivityMember.create(
              :activity_id => @activity_id,
              :account_id => account_id,
              :accepted => false,
              :approved => true,
              :admin => false
            )
          end
        end
      end
      
      
      if invitation_way == "email"
        Activity.add_activity_invitation(
          {
            :activity_id => @activity_id,
            :invitor_account_id => session[:account_id],
            :invited_account_ids => need_invite,
            :invitation_words => invitation_words
          }
        )
      else
        # send sys message to invited account
        SysMessage.transaction do
          need_invite.each do |account_id|
            SysMessage.create_new(account_id, "invite_join_activity", {
              :inviter_id => session[:account_id],
              :activity_id => @activity_id,
              :invitation_words => invitation_words
            })
          end
        end
      end
      
      flash[:message] = "已成功发出邀请"
      
    end
    
    jump_to("/activities/invite/#{@activity_id}")
  end
  
  def invite_contact
    
  end
  
  def select_contact
    @contacts = session[:activity_invite_contacts] || []
    
    return jump_to("/activities/invite_contact/#{@activity_id}") unless @contacts.size > 0
    
    @type = session[:activity_invite_contacts_type]
  end
  
  def send_contact_invitations
    type = params[:type]
    invitation_words = params[:invitation_words] && params[:invitation_words].strip
    
    if type == "email"
      emails = params[:emails].split(",").collect { |email|
        addr = email && email.strip
        (addr != "") ? addr : nil
      }.compact
    else
      emails = params[:emails] || []
    
      unless emails.size > 0
        flash[:error_msg] = "还没有选择要邀请谁"
        return jump_to("/activities/select_contact/#{@activity_id}")
      end
    end
    
    Activity.add_activity_contact_invitation(
      {
        :activity_id => @activity_id,
        :invitor_account_id => session[:account_id],
        :invited_emails => emails,
        :invitation_words => invitation_words
      }
    ) if emails.size > 0
    
    flash[:message] = "已成功发出邀请"
    jump_to("/activities/invite_contact/#{@activity_id}")
    
  end
  
  
  def members_info
    @activity, @activity_image = Activity.get_activity_with_image(@activity_id)
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    
    activity_setting = @activity.get_setting
    @check_mobile = activity_setting[:check_mobile]
    @check_real_name = activity_setting[:check_real_name]
    @check_gender = activity_setting[:check_gender]
    @check_birthday = activity_setting[:check_birthday]
    
    @include_basic_profile = @check_real_name || @check_gender || @check_birthday
    
    include_items = [:profile_pic]
    include_items << :profile_basic if @include_basic_profile
    include_items << :profile_contact if @check_mobile
    
    @members = ActivityMember.agreed.paginate(
      :page => page,
      :per_page => Members_Info_Page_Size,
      :conditions => ["activity_id = ?", @activity_id],
      :include => [:account => include_items],
      :order => "join_at ASC"
    )
  end
  
  def cancel
    @activity.cancelled = true
    @activity.save
    
    jump_to("/activities/#{@activity_id}")
  end
  
  def recover
    @activity.cancelled = false
    @activity.save
    
    jump_to("/activities/#{@activity_id}")
  end
  
#  def destroy
#    if ApplicationController.helpers.superadmin?(session[:account_id])
#      # only super admin can destroy an activity
#      
#      activity_id = params[:id]
#      activity = Activity.find(activity_id)
#      
#      activity.destroy
#    end
#    
#    jump_to("/activities")
#  end

  def edit_master
    @admin_members = ActivityMember.get_activity_admins(@activity_id)
  end
  
  def update_master
    new_master_id = params[:new_master_id] && params[:new_master_id].strip
    
    if ActivityMember.is_activity_admin(@activity_id, new_master_id)
      @activity.master_id = new_master_id
      @activity.save
    end
    
    jump_to("/activities/#{@activity_id}")
  end
  
  
  
  private
  
  def check_activity_groups_account
    jump_to("/activities/activity_groups/#{session[:account_id]}") unless session[:account_id].to_s == params[:id]
  end
  
  def check_activity_admin
    @activity_id = params[:id]
    
    jump_to("/errors/forbidden") unless ActivityMember.is_activity_admin(@activity_id, session[:account_id])
  end
  
  def check_activity_master
    @activity_id = params[:id]
    @activity, @activity_image = Activity.get_activity_with_image(@activity_id)
    
    jump_to("/errors/forbidden") unless @activity.master_id == session[:account_id]
  end
  
  def check_activity_member
    @activity_id = params[:id]
    
    jump_to("/errors/forbidden") unless ActivityMember.is_activity_member(@activity_id, session[:account_id])
  end
  
  def is_before_status?(status)
    @activity.get_status[0] <= status[0]
  end
  
  def is_after_status?(status)
    @activity.get_status[0] >= status[0]
  end
  
  def check_activity_status_registering
    @activity_id = params[:id]
    @activity, @activity_image = Activity.get_activity_with_image(@activity_id) unless @activity
    
    jump_to("/activities/#{@activity_id}") unless @activity.online || is_before_status?(Activity::Status::Registering)
  end
  
  def check_activity_status_registered
    @activity_id = params[:id]
    @activity, @activity_image = Activity.get_activity_with_image(@activity_id) unless @activity
    
    jump_to("/activities/#{@activity_id}") unless @activity.online || is_before_status?(Activity::Status::Registered)
  end
  
  def check_activity_status_ongoing
    @activity_id = params[:id]
    @activity, @activity_image = Activity.get_activity_with_image(@activity_id) unless @activity
    
    jump_to("/activities/#{@activity_id}") unless @activity.online || is_before_status?(Activity::Status::Ongoing)
  end
  
  def check_activity_update_absent
    @activity_id = params[:id]
    @activity, @activity_image = Activity.get_activity_with_image(@activity_id) unless @activity
    
    jump_to("/activities/#{@activity_id}") unless is_after_status?(Activity::Status::Ongoing)
  end
  
  def is_activity_member_beyond_limit(activity, include_equal = true)
    limit = activity.member_limit
    (limit && limit > 0) && (ActivityMember.count_activity_member(activity.id).send(include_equal ? ">=" : ">", limit))
  end
  
  
  def check_activity_view_access
    @activity_id = params[:id]
    @activity, @activity_image = Activity.get_activity_with_image(@activity_id)
    
    group_id = @activity.in_group
    if group_id && group_id > 0
      @group, @group_image = Group.get_group_with_image(group_id)
      
      need_join_to_view_activity = @group.get_setting[:need_join_to_view_activity]
      need_join_group_to_view = @activity.get_setting[:need_join_group_to_view]
      @can_not_view = (need_join_to_view_activity || need_join_group_to_view) && (!GroupMember.is_group_member(@group.id, session[:account_id]))
      
      if @can_not_view
        render :layout => true, :inline => %Q!
          <% activity_title = h(@activity.title)%>

          <% community_page_title(activity_title) %>

          <div class="float_r activity_container_r">

          	<div class="community_block align_c">
        			<a href="/groups/<%= @group.id %>">
        				<img src="<%= face_img_src(@group_image) %>" border="0" /></a>
        		</div>
        		
        		<div class="community_block align_c form_info_s">
      				圈子 <a href="/groups/<%= @group.id %>"><%= h(@group.name) %></a> 的圈内活动
        		</div>

          </div>

          <div class="activity_container_l">
          	<h2>
          		<%= activity_title %>
          	</h2>
          	
          	<p class="warning_msg">
        			根据活动及其所在圈子的设置, 只有活动所在的圈子的成员可以查看活动的具体内容
        		</p>

        		<p>
        			<% form_tag "/groups/#{@group.id}/join", :method => :post do %>
        				<input type="submit" value="我要加入圈子" class="button" />
        			<% end %>
        		</p>

          </div>
        !
      end
    end
  end
  
  def protect_activity_view_access
    activity_id = params[:id]
    activity = Activity.get_activity_with_image(activity_id)[0]
    
    group_id = activity.in_group
    if group_id && group_id > 0
      group = Group.get_group_with_image(group_id)[0]
      
      need_join_to_view_activity = group.get_setting[:need_join_to_view_activity]
      need_join_group_to_view = activity.get_setting[:need_join_group_to_view]
      can_not_view = (need_join_to_view_activity || need_join_group_to_view) && (!GroupMember.is_group_member(group.id, session[:account_id]))
      
      jump_to("/activities/#{activity_id}") if can_not_view
    end
  end
  
  def check_owner
    jump_to("/errors/forbidden") unless session[:account_id].to_s == params[:id]
  end
  
  
end
