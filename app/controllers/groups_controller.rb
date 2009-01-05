class GroupsController < ApplicationController
  
  Member_Page_Size = 30
  Unapprove_Page_Size = 30
  Group_List_Size = 49
  Post_List_Size = 50
  Activity_List_Size = 15
  Vote_List_Size = 6
  Bookmark_List_Size = 20
  Photo_List_Size = 30
  Picture_List_Size = 15
  
  Group_Recent_List_Size = 24
  Post_Recent_List_Size = 25
  Activity_Recent_List_Size = 16
  Bookmark_Recent_List_Size = 10
  Photo_Recent_List_Size = 10
  
  New_Member_Num = 15
  Group_Post_Num = 20
  Group_Activity_Num = 10
  Group_Vote_Num = 10
  Group_Bookmark_Num = 10
  Group_Photo_Num = 5
  
  Group_Admin_Max_Count = 11
  
  New_Comment_Size = 30

  
  layout "community"
  before_filter :check_current_account, :only => [:recent_index]
  before_filter :check_login, :only => [:new, :create,:edit_image, :update_image,
                                        :edit, :update, :update_access, :join, :quit, :members_edit,
                                        :members_master, :del_member, :add_admin, :del_admin,
                                        :unapproved, :approve_member, :reject_member, :approve_all,
                                        :invite, :invite_member, :edit_master, :update_master,
                                        :photo_selector_for_group_image, :remove_activity, :remove_vote,
                                        :invite_contact, :select_contact, :send_contact_invitations,
                                        :recent, :all_post, :all_activity, :all_vote, :all_bookmark,
                                        :all_photo, :created_post, :commented_post]
  before_filter :check_limited, :only => [:create, :update_image, :update, :update_access, :join,
                                          :quit, :del_member, :add_admin, :del_admin,
                                          :approve_member, :reject_member, :approve_all,
                                          :invite_member, :update_master, :remove_activity, :remove_vote,
                                          :send_contact_invitations]
  
  before_filter :check_can_create_group, :only => [:new, :create]
  
  before_filter :check_group_admin, :only => [:edit_image, :update_image, :edit, :update,
                                              :update_access, :members_edit, :del_member,
                                              :unapproved, :approve_member, :reject_member, :approve_all,
                                              :remove_activity, :remove_vote]
  before_filter :check_group_master, :only => [:members_master, :add_admin, :del_admin, :edit_master, :update_master]
  
  before_filter :check_group_member, :only => [:invite, :invite_member, :invite_contact,
                                                :select_contact, :send_contact_invitations]
  
  before_filter :check_owner, :only => [:recent, :all_post, :all_activity, :all_vote, :all_bookmark,
                                        :all_photo, :created_post, :commented_post]
  
  before_filter :check_custom_group, :only => [:show]
  
  
  
  # ! current account needed !
  def index
    return jump_to("/groups/all") unless has_login?
    
    account_id = session[:account_id]
    
    account_setting = AccountSetting.get_account_setting(account_id)
    module_group_index = account_setting.get_setting_value(:module_group_index)
    
    url = case module_group_index
      when "all"
        "all"
      when "recent"
        "recent/#{account_id}"
      when "join"
        "list/#{account_id}"
      when "admin"
        "list_admin/#{account_id}"
      else
        "recent/#{account_id}"
    end
    jump_to("/groups/#{url}")
  end
  
  def recent_index
    jump_to("/groups/recent/#{session[:account_id]}")
  end
  
  def recent
    @owner_id = params[:id]
    
    @edit = session[:account_id].to_s == @owner_id
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    all_group_members = GroupMember.agreed.find(
      :all,
      :conditions => ["account_id = ?", @owner_id],
      :order => "join_at DESC"
    )
    
    joined_group_ids = []
    @group_members = []
    all_group_members.each_index do |i|
      m = all_group_members[i]
      
      joined_group_ids << m.group_id
      
      @group_members << m if i < Group_Recent_List_Size
    end
    
    GroupMember.load_group_with_image(@group_members)
    
    GroupMember.set_account_group_ids_cache(@owner_id, joined_group_ids)
    
    @group_posts = GroupPost.find(
      :all,
      :limit => Post_Recent_List_Size,
      :select => "group_posts.id, group_posts.created_at, group_posts.group_id, group_posts.top, group_posts.good, group_posts.account_id, group_posts.title, group_posts.responded_at, groups.name, accounts.nick, accounts.email",
      :conditions => ["group_id in (?)", joined_group_ids],
      :include => [:account, :group],
      :order => "group_posts.responded_at DESC, group_posts.created_at DESC"
    )
    
    @group_activities = Activity.uncancelled.find(
      :all,
      :limit => Activity_Recent_List_Size,
      :conditions => ["in_group in (?)", joined_group_ids],
      :include => [:image],
      :order => "begin_at DESC"
    )

    @group_vote_topics = VoteTopic.find(
      :all,
      :limit => Group_Vote_Num,
      :conditions => ["group_id in (?)", joined_group_ids],
      :include => [:account],
      :order => "created_at DESC"
    )
    
    @group_bookmarks = GroupBookmark.find(
			:all,
			:limit => Bookmark_Recent_List_Size,
			:conditions => ["group_id in (?)", joined_group_ids],
			:order => "created_at DESC"
		)
    
    @group_photos = GroupPhoto.find(
      :all,
      :limit => Photo_Recent_List_Size,
      :conditions => ["group_id in (?)", joined_group_ids],
      :include => [:photo],
      :order => "created_at DESC"
    )
    
  end
  
  def list
    @owner_id = params[:id]
    
    @edit = (session[:account_id].to_s == params[:id])
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    conditions = @only_admin ? ["account_id = ? and admin = ?", @owner_id, true] : ["account_id = ?", @owner_id]
    @group_members = GroupMember.agreed.paginate(
      :page => page,
      :per_page => Group_List_Size,
      :conditions => conditions,
      :include => [:group => [:image]],
      :order => "join_at DESC"
    )
  end
  
  def list_admin
    @only_admin = true
    list
    render :action => "list"
  end
  
  def all
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @groups = Group.paginate(
      :page => page,
      :per_page => Group_List_Size,
      :include => [:image],
      :order => "created_at DESC"
    )
  end
  
  def list_friend
    @owner_id = params[:id]
    
    @edit = (session[:account_id].to_s == params[:id])
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    @friends = Friend.get_all_by_account(
      @owner_id,
      :include => [:friend => [:profile_pic]],
      :order => "created_at DESC"
    )
  end
  
  
  def new
    @group = Group.new
  end
  
  def create
    return jump_to("/errors/unauthorized") unless (@can_count - @created_group_count) > 0
    
    @group = Group.new(:creator_id => session[:account_id], :master_id => session[:account_id])
    
    @group.name = params[:group_name] && params[:group_name].strip
    @group.desc = params[:group_desc] && params[:group_desc].strip
    
    group_setting = {
      :need_approve => (params[:need_approve] == "true"),
      :notice => "欢迎来到圈子 #{@group.name} ~"
    }
    
    if ApplicationController.helpers.superadmin?(session[:account_id])
      group_custom_key = params[:custom_key] && params[:custom_key].strip
      @group.custom_key = group_custom_key if (group_custom_key && group_custom_key != "")
    end
    
    @group.fill_setting(group_setting)
    
    if @group.save
      # join the group
      if GroupMember.add_account_to_group(@group.id, session[:account_id], true)
        return render(:action => "edit_image")
      else
        @group.destroy
        flash.now[:error_msg] = "创建圈子的过程中遇到错误, 再试一次吧"
      end
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render(:action => "new")
  end
  
  def show
    
    # should NOT cache the relationship check
    @relationship = "logout"
    if has_login?
      if @group.master_id == session[:account_id]
        @relationship = "master"
      else
        is_member = GroupMember.is_group_member(@group_id, session[:account_id])
        @relationship = is_member ? (GroupMember.is_group_admin(@group_id, session[:account_id]) ? "admin" : "member") : "not_member"
      end
    end
    
    @no_membership = (@relationship == "not_member") || (@relationship == "logout")
    
    @group_setting = @group.get_setting
    
    need_join_to_view_post_list = @group_setting[:need_join_to_view_post_list]
    @can_list_post = !(need_join_to_view_post_list && @no_membership)
    
    need_join_to_view_bookmark = @group_setting[:need_join_to_view_bookmark]
    @can_view_bookmark = !(need_join_to_view_bookmark && @no_membership)
    
    need_join_to_view_picture = @group_setting[:need_join_to_view_picture]
    @can_view_picture = !(need_join_to_view_picture && @no_membership)
    
    need_join_to_view_member = @group_setting[:need_join_to_view_member]
    @can_view_member = !(need_join_to_view_member && @no_membership)
    
    need_join_to_view_notice = @group_setting[:need_join_to_view_notice]
    @can_view_notice = !(need_join_to_view_notice && @no_membership)
    
    @new_members = GroupMember.agreed.find(
      :all,
      :limit => New_Member_Num,
      :conditions => ["group_id = ?", @group_id],
      :include => [:account => [:profile_pic]],
      :order => "join_at DESC"
    )
    
    @top_group_posts = GroupPost.find(
      :all,
      :select => "id, created_at, group_id, top, good, account_id, title, responded_at",
      :conditions => ["group_id = ? and top = ?", @group_id, true],
      :include => [:account],
      :order => "responded_at DESC, created_at DESC"
    ) if @can_list_post
    
    @group_posts = GroupPost.find(
      :all,
      :limit => Group_Post_Num,
      :select => "id, created_at, group_id, top, good, account_id, title, responded_at",
      :conditions => ["group_id = ? and top = ?", @group_id, false],
      :include => [:account],
      :order => "responded_at DESC, created_at DESC"
    ) if @can_list_post
    
    @group_activities = Activity.uncancelled.find(
      :all,
      :limit => Group_Activity_Num,
      :conditions => ["in_group = ?", @group_id],
      :include => [:image],
      :order => "begin_at DESC"
    )
    
    @group_vote_topics = VoteTopic.find(
      :all,
      :limit => Group_Vote_Num,
      :conditions => ["group_id = ?", @group_id],
      :include => [:account],
      :order => "created_at DESC"
    )
    
    @group_photos = GroupPhoto.find(
      :all,
      :limit => Group_Photo_Num,
      :conditions => ["group_id = ?", @group_id],
      :include => [:photo],
      :order => "created_at DESC"
    )
    @all_group_photo_count = GroupPhoto.get_count(@group_id) if @group_photos.size > 0
    
    @group_pictures = GroupPicture.find(
      :all,
      :limit => Group_Photo_Num,
      :conditions => ["group_id = ?", @group_id],
      :order => "responded_at DESC, created_at DESC"
    )
    @all_group_picture_count = GroupPicture.get_count(@group_id) if @group_pictures.size > 0
    
  end
  
  def post
    @group_id = params[:id]
    @group, @group_image = Group.get_group_with_image(@group_id)
    
    need_join_to_view_post_list = @group.get_setting[:need_join_to_view_post_list]
    
    @can_view = !(need_join_to_view_post_list && (!GroupMember.is_group_member(@group_id, session[:account_id])))
    
    @top_group_posts = GroupPost.find(
      :all,
      :select => "id, created_at, group_id, top, good, account_id, title, responded_at",
      :conditions => ["group_id = ? and top = ?", @group_id, true],
      :include => [:account],
      :order => "responded_at DESC, created_at DESC"
    ) if @can_view
    
    if @can_view
      page = params[:page]
      page = 1 unless page =~ /\d+/
      @group_posts = GroupPost.paginate(
        :page => page,
        :per_page => Post_List_Size,
        :select => "id, created_at, group_id, top, good, account_id, title, responded_at",
        :conditions => ["group_id = ? and top = ?", @group_id, false],
        :include => [:account],
        :order => "responded_at DESC, created_at DESC"
      )
    end
  end
  
  def good_post
    @group_id = params[:id]
    @group, @group_image = Group.get_group_with_image(@group_id)
    
    need_join_to_view_post_list = @group.get_setting[:need_join_to_view_post_list]
    
    @can_view = !(need_join_to_view_post_list && (!GroupMember.is_group_member(@group_id, session[:account_id])))
    
    @top_group_posts = GroupPost.good.find(
      :all,
      :select => "id, created_at, group_id, top, good, account_id, title, responded_at",
      :conditions => ["group_id = ? and top = ?", @group_id, true],
      :include => [:account],
      :order => "responded_at DESC, created_at DESC"
    ) if @can_view
    
    if @can_view
      page = params[:page]
      page = 1 unless page =~ /\d+/
      @group_posts = GroupPost.good.paginate(
        :page => page,
        :per_page => Post_List_Size,
        :select => "id, created_at, group_id, top, good, account_id, title, responded_at",
        :conditions => ["group_id = ? and top = ?", @group_id, false],
        :include => [:account],
        :order => "responded_at DESC, created_at DESC"
      )
    end
  end
  
  def picture
    @group_id = params[:id]
    @group, @group_image = Group.get_group_with_image(@group_id)
    
    need_join_to_view_picture = @group.get_setting[:need_join_to_view_picture]
    @can_view = !(need_join_to_view_picture && (!GroupMember.is_group_member(@group_id, session[:account_id])))
    
    if @can_view
      page = params[:page]
      page = 1 unless page =~ /\d+/
      @group_pictures = GroupPicture.paginate(
        :page => page,
        :per_page => Picture_List_Size,
        :conditions => ["group_id = ?", @group_id],
        :include => [:account],
        :order => "responded_at DESC, created_at DESC"
      )
      
      @new_comments = GroupPictureComment.find(
        :all,
        :limit => New_Comment_Size,
        :conditions => ["group_picture_id in (select id from group_pictures where group_id = ?)", @group_id],
        :include => [:account => [:profile_pic]],
        :order => "updated_at DESC"
      )
    end
  end
  
  def good_picture
    @group_id = params[:id]
    @group, @group_image = Group.get_group_with_image(@group_id)
    
    need_join_to_view_picture = @group.get_setting[:need_join_to_view_picture]
    @can_view = !(need_join_to_view_picture && (!GroupMember.is_group_member(@group_id, session[:account_id])))
    
    if @can_view
      page = params[:page]
      page = 1 unless page =~ /\d+/
      @group_pictures = GroupPicture.good.paginate(
        :page => page,
        :per_page => Picture_List_Size,
        :conditions => ["group_id = ?", @group_id],
        :include => [:account],
        :order => "responded_at DESC, created_at DESC"
      )
      
      @new_comments = GroupPictureComment.find(
        :all,
        :limit => New_Comment_Size,
        :conditions => ["group_picture_id in (select id from group_pictures where group_id = ? and good = ?)", @group_id, true],
        :include => [:account => [:profile_pic]],
        :order => "updated_at DESC"
      )
    end
  end
  
  def activity
    @group_id = params[:id]
    @group, @group_image = Group.get_group_with_image(@group_id)
    
    @is_admin = GroupMember.is_group_admin(@group_id, session[:account_id])
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @group_activities = Activity.uncancelled.paginate(
      :page => page,
      :per_page => Activity_List_Size,
      :conditions => ["in_group = ?", @group_id],
      :include => [:image],
      :order => "begin_at DESC"
    )
  end
  
  def remove_activity
    activity_id = params[:activity_id] && params[:activity_id].strip
    activity, activity_image = Activity.get_activity_with_image(activity_id)
    
    if activity.in_group.to_s == @group_id
      # change to global activity
      activity.in_group = 0
      activity.save
    end
    
    jump_to("/groups/activity/#{@group_id}")
  end
  
  def vote
    @group_id = params[:id]
    @group, @group_image = Group.get_group_with_image(@group_id)
    
    @is_admin = GroupMember.is_group_admin(@group_id, session[:account_id])
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @vote_topics = VoteTopic.paginate(
      :page => page,
      :per_page => Vote_List_Size,
      :conditions => ["group_id = ?", @group_id],
      :include => [:image, :account],
      :order => "created_at DESC"
    )
  end

  def remove_vote
    vote_id = params[:vote_id] && params[:vote_id].strip
    vote, vote_image = VoteTopic.get_vote_topic_with_image(vote_id)

    if vote.group_id.to_s == @group_id
      # change to global vote
      vote.group_id = 0
      vote.save
    end

    jump_to("/groups/activity/#{@group_id}")
  end
  
  def photo
    @group_id = params[:id]
    @group, @group_image = Group.get_group_with_image(@group_id)
    
    @is_admin = GroupMember.is_group_admin(@group_id, session[:account_id])
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @group_photos = GroupPhoto.paginate(
      :page => page,
      :per_page => Photo_List_Size,
      :total_entries => GroupPhoto.get_count(@group_id),
      :conditions => ["group_id = ?", @group_id],
      :include => [:photo, :account],
      :order => "created_at DESC"
    )
  end
  
  def bookmark
    @group_id = params[:id]
    @group, @group_image = Group.get_group_with_image(@group_id)
    
    need_join_to_view_bookmark = @group.get_setting[:need_join_to_view_bookmark]
    @can_view_bookmark = !(need_join_to_view_bookmark && (!GroupMember.is_group_member(@group_id, session[:account_id])))
    
    if @can_view_bookmark
      @is_admin = GroupMember.is_group_admin(@group_id, session[:account_id])
    
      page = params[:page]
      page = 1 unless page =~ /\d+/
      @bookmarks = GroupBookmark.paginate(
        :page => page,
        :per_page => Bookmark_List_Size,
        :conditions => ["group_id = ?", @group_id],
        :include => [:account => :profile_pic],
        :order => "created_at DESC"
      )
    end
  end
  
  def all_post
    @owner_id = params[:id]
    
    @edit = session[:account_id].to_s == @owner_id
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @all_posts = GroupPost.paginate(
      :page => page,
      :per_page => Post_List_Size,
      :select => "group_posts.id, group_posts.created_at, group_posts.group_id, group_posts.account_id, group_posts.title, group_posts.responded_at, groups.name, accounts.nick",
      :conditions => ["group_id in (select group_id from group_members where account_id = ? and accepted = ? and approved = ?)", @owner_id, true, true],
      :include => [:account, :group],
      :order => "group_posts.responded_at DESC, group_posts.created_at DESC"
    )
  end
  
  def all_activity
    @owner_id = params[:id]
    
    @edit = session[:account_id].to_s == @owner_id
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @all_activitie = Activity.uncancelled.paginate(
      :page => page,
      :per_page => Activity_List_Size,
      :conditions => ["in_group in (select group_id from group_members where account_id = ? and accepted = ? and approved = ?)", @owner_id, true, true],
      :include => [:image],
      :order => "begin_at DESC"
    )
  end
  
  def all_vote
    @owner_id = params[:id]
    
    @edit = session[:account_id].to_s == @owner_id
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @vote_topics = VoteTopic.paginate(
      :page => page,
      :per_page => Vote_List_Size,
      :conditions => ["group_id in (select group_id from group_members where account_id = ? and accepted = ? and approved = ?)", @owner_id, true, true],
      :include => [:image, :account],
      :order => "created_at DESC"
    )
  end
  
  def all_bookmark
    @owner_id = params[:id]
    
    @edit = session[:account_id].to_s == @owner_id
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @bookmarks = GroupBookmark.paginate(
      :page => page,
      :per_page => Bookmark_List_Size,
      :conditions => ["group_id in (select group_id from group_members where account_id = ? and accepted = ? and approved = ?)", @owner_id, true, true],
      :include => [:account, {:group => :image}],
      :order => "created_at DESC"
    )
  end
  
  def all_photo
    @owner_id = params[:id]
    
    @edit = session[:account_id].to_s == @owner_id
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @all_photos = GroupPhoto.paginate(
      :page => page,
      :per_page => Photo_List_Size,
      :select => "group_photos.id, group_photos.created_at, group_photos.group_id, group_photos.account_id, group_photos.photo_id, groups.name, accounts.nick, photos.*",
      :conditions => ["group_id in (select group_id from group_members where account_id = ? and accepted = ? and approved = ?)", @owner_id, true, true],
      :include => [:photo, :account, :group],
      :order => "group_photos.created_at DESC"
    )
  end
  
  def created_post
    @owner_id = params[:id]
    
    @edit = session[:account_id].to_s == @owner_id
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @created_posts = GroupPost.paginate(
      :page => page,
      :per_page => Post_List_Size,
      :select => "group_posts.id, group_posts.created_at, group_posts.group_id, group_posts.account_id, group_posts.title, group_posts.responded_at, groups.name, accounts.nick",
      :conditions => ["account_id = ?", @owner_id],
      :include => [:account, :group],
      :order => "group_posts.responded_at DESC, group_posts.created_at DESC"
    )
  end
  
  def commented_post
    @owner_id = params[:id]
    
    @edit = session[:account_id].to_s == @owner_id
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @commented_posts = GroupPost.paginate(
      :page => page,
      :per_page => Post_List_Size,
      :select => "group_posts.id, group_posts.created_at, group_posts.group_id, group_posts.account_id, group_posts.title, group_posts.responded_at, groups.name, accounts.nick",
      :conditions => ["group_posts.id in (select group_post_id from group_post_comments where account_id = ?)", @owner_id],
      :include => [:account, :group],
      :order => "group_posts.responded_at DESC, group_posts.created_at DESC"
    )
  end
  
  def edit_image
    @group, @group_image = Group.get_group_with_image(@group_id)
    
  end
  
  def update_image
    group_image = GroupImage.get_by_group(@group_id) || GroupImage.new(:group_id => @group_id)
    
    old_photo_id = group_image.photo_id
    group_image.photo_id = params[:photo_id]
    
    # validate the photo
    if group_image.photo_id && group_image.photo_id != old_photo_id
      photo = group_image.photo
      if photo && photo.account_id == session[:account_id]
        group_image.pic_url = photo.image.url(:thumb_48)
        if group_image.save
          Group.update_group_with_image_cache(@group_id, :group_img => group_image.pic_url)
          flash.now[:message] = "已成功保存"
        else
          flash.now[:error_msg] = "操作失败, 再试一次吧"
        end
      else
        jump_to("/errors/forbidden")
      end
    end
  end
  
  def photo_selector_for_group_image
    albums = Album.get_all_names_by_account_id(session[:account_id])
    render :partial => "albums/photo_selector", :locals => {:albums => albums, :photo_list_template => "/profiles/album_photo_list_for_face"}
  end
  
  def edit
    @group, @group_image = Group.get_group_with_image(@group_id)
  end
  
  def update
    @group, @group_image = Group.get_group_with_image(@group_id)
    
    @old_group_name = @group.name
    
    @group.name = params[:group_name] && params[:group_name].strip
    @group.desc = params[:group_desc] && params[:group_desc].strip

    group_notice = params[:group_notice] && params[:group_notice].strip
    
    group_setting = {
      :notice => group_notice
    }
    if ApplicationController.helpers.superadmin?(session[:account_id])
      group_custom_key = params[:custom_key] && params[:custom_key].strip
      @group.custom_key = group_custom_key if (group_custom_key && group_custom_key != "")
    end
    
    @group.update_setting(group_setting)
    
    
    if @group.save
      Group.update_group_with_image_cache(@group_id, :group => @group)
      @old_group_name = nil
      flash.now[:message] = "圈子设置已成功修改"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render(:action => "edit")
  end
  
  def update_access    
    @group, @group_image = Group.get_group_with_image(@group_id)
    
    group_setting = {
      :need_approve => (params[:need_approve] == "true"),
      :need_join_to_view_post => (params[:need_join_to_view_post] == "true"),
      :need_join_to_view_post_list => (params[:need_join_to_view_post_list] == "true"),
      :need_join_to_view_bookmark => (params[:need_join_to_view_bookmark] == "true"),
      :need_join_to_view_member => (params[:need_join_to_view_member] == "true"),
      :need_join_to_view_notice => (params[:need_join_to_view_notice] == "true"),
      :need_join_to_view_vote => (params[:need_join_to_view_vote] == "true"),
      :need_join_to_view_activity => (params[:need_join_to_view_activity] == "true"),
      :need_join_to_view_picture => (params[:need_join_to_view_picture] == "true")
    }
    
    @group.update_setting(group_setting)
    
    if @group.save
      Group.update_group_with_image_cache(@group_id, :group => @group)
      
      # approve group join request
      # GroupMember.approve_all(@group_id)
      
      flash.now[:message] = "圈子访问权限已成功修改"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render(:action => "edit")
  end
  
  def join
    @group_id = params[:id]
    @group, @group_image = Group.get_group_with_image(@group_id)
    
    need_approve = @group.get_setting[:need_approve]
    
    group_member = GroupMember.join_group(@group_id, session[:account_id], need_approve)
    
    if group_member.agreed || (!need_approve)
      return jump_to("/groups/#{@group_id}")
    end
    
    # need to wait for the approval of group admin
    
    # send sys message to admins
    SysMessage.transaction do
      group_admins = GroupMember.get_group_admins(@group_id, false)
      group_admins.each do |ga|
        SysMessage.create_new(ga.account_id, "join_group_request", {
          :requester_id => session[:account_id],
          :group_id => @group_id
        })
      end
    end
  end
  
  def quit
    @group_id = params[:id]
    @group, @group_image = Group.get_group_with_image(@group_id)
    
    if @group.master_id != session[:account_id]
      # not group master
      GroupMember.remove_account_from_group(@group_id, session[:account_id])
      return jump_to("/groups/#{@group_id}")
    end
    
    # group master can NOT quit the group
  end
  
  def members
    @group_id ||= params[:id]
    @group, @group_image = Group.get_group_with_image(@group_id) unless @group
    
    need_join_to_view_member = @group.get_setting[:need_join_to_view_member]
    @can_view_member = !(need_join_to_view_member && (!GroupMember.is_group_member(@group_id, session[:account_id])))
    
    if @can_view_member
      @master_id = @group.master_id
      @master_nick_pic = Account.get_nick_and_pic(@master_id)
    
      @admin_members = GroupMember.get_group_admins(@group_id)
    
      # check and ensure admins include group master
      master_member = @admin_members.select {|m| (m.account_id == @master_id) && m.admin }[0]
      GroupMember.add_account_to_group(@group_id, @master_id, true) unless master_member
    
      page = params[:page]
      page = 1 unless page =~ /\d+/
      @members = GroupMember.paginate_group_members(@group_id, page, Member_Page_Size)
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
  
  def del_member
    member_id = params[:del_member_id]
    group_member = GroupMember.get_by_group_and_account(@group_id, member_id)
    group_member.destroy if group_member && (!group_member.admin)
    
    jump_to("/groups/members_edit/#{@group_id}")
  end
  
  def add_admin
    member_id = params[:add_admin_id]
    
    admin_count = GroupMember.count_admin(@group_id)
    if admin_count < Group_Admin_Max_Count
      group_member = GroupMember.get_by_group_and_account(@group_id, member_id)
      if group_member && group_member.agreed && (!group_member.admin)
        group_member.admin = true
        group_member.save
      end
    end
    
    jump_to("/groups/members_master/#{@group_id}")
  end
  
  def del_admin
    member_id = params[:del_admin_id] && params[:del_admin_id].strip
    
    if @group.master_id.to_s != member_id
      # must be NOT group master
      group_member = GroupMember.get_by_group_and_account(@group_id, member_id)
      if group_member && group_member.admin
        group_member.admin = false
        group_member.save
      end
    end
    
    jump_to("/groups/members_master/#{@group_id}")
  end
  
  def unapproved
    @group, @group_image = Group.get_group_with_image(@group_id)
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @unapproved_members = GroupMember.paginate_unapproved_members(@group_id, page, Unapprove_Page_Size)
  end
  
  def approve_member
    approve_member_id = params[:approve_member_id]
    
    group_member = GroupMember.get_by_group_and_account(@group_id, approve_member_id)
    if group_member && group_member.accepted && (!group_member.approved)
      group_member.approved = true
      group_member.join_at = DateTime.now
      if group_member.save
        SysMessage.create_new(group_member.account_id, "approve_reject_join_group", {
          :admin_account_id => session[:account_id],
          :group_id => @group_id,
          :approve => true
        })
      end
    end
    
    jump_to("/groups/unapproved/#{@group_id}")
  end
  
  def reject_member
    reject_member_id = params[:reject_member_id]
    
    group_member = GroupMember.get_by_group_and_account(@group_id, reject_member_id)
    if group_member && group_member.accepted && (!group_member.approved)
      group_member.destroy
      
      SysMessage.create_new(group_member.account_id, "approve_reject_join_group", {
          :admin_account_id => session[:account_id],
          :group_id => @group_id,
          :approve => false
        })
    end
    
    jump_to("/groups/unapproved/#{@group_id}")
  end
  
  def approve_all
    # GroupMember.approve_all(@group_id)
    
    jump_to("/groups/members_edit/#{@group_id}")
  end
  
  def invite
    @group, @group_image = Group.get_group_with_image(@group_id)
    
    @is_admin = GroupMember.is_group_admin(@group_id, session[:account_id])
    
    @friends = Friend.get_all_by_account(
      session[:account_id],
      :include => [:friend => [:profile_pic]],
      :order => "created_at DESC"
    )
    
    @unaccepted_members = GroupMember.get_unaccepted_members(@group_id) if @is_admin
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
      
      existing = GroupMember.find(
        :all,
        :conditions => ["group_id = ? and account_id in (?)", @group_id, invited_account_id]
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
        GroupMember.update_all(
          ["approved = ?, join_at = ?", true, DateTime.now],
          ["id in (?)", need_update]
        ) if need_update.size > 0
      
        GroupMember.transaction do
          need_insert.each do |account_id|
            GroupMember.create(
              :group_id => @group_id,
              :account_id => account_id,
              :accepted => false,
              :approved => true,
              :admin => false
            )
          end
        end
      end
      
      
      if invitation_way == "email"
        Group.add_group_invitation(
          {
            :group_id => @group_id,
            :invitor_account_id => session[:account_id],
            :invited_account_ids => need_invite,
            :invitation_words => invitation_words
          }
        )
      else
        # send sys message to invited account
        SysMessage.transaction do
          need_invite.each do |account_id|
            SysMessage.create_new(account_id, "invite_join_group", {
              :inviter_id => session[:account_id],
              :group_id => @group_id,
              :invitation_words => invitation_words
            })
          end
        end
      end
      
      flash[:message] = "已成功发出邀请"
      
    end
    
    jump_to("/groups/invite/#{@group_id}")
  end
  
  def invite_contact
    @group, @group_image = Group.get_group_with_image(@group_id)
  end
  
  def select_contact
    @contacts = session[:group_invite_contacts] || []
    
    return jump_to("/groups/invite_contact/#{@group_id}") unless @contacts.size > 0
    
    @group, @group_image = Group.get_group_with_image(@group_id)
    
    @type = session[:group_invite_contacts_type]
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
        return jump_to("/groups/select_contact/#{@group_id}")
      end
    end
    
    Group.add_group_contact_invitation(
      {
        :group_id => @group_id,
        :invitor_account_id => session[:account_id],
        :invited_emails => emails,
        :invitation_words => invitation_words
      }
    ) if emails.size > 0
    
    flash[:message] = "已成功发出邀请"
    jump_to("/groups/invite_contact/#{@group_id}")
    
  end
  
  
  def edit_master
    @admin_members = GroupMember.get_group_admins(@group_id)
  end
  
  def update_master
    new_master_id = params[:new_master_id] && params[:new_master_id].strip
    
    admin_member = GroupMember.is_group_admin(@group_id, new_master_id)
    if admin_member
      @group.master_id = admin_member.account_id
      if @group.save
        Group.update_group_with_image_cache(@group_id, :group => @group)
      end
    end
    
    jump_to("/groups/#{@group_id}")
  end
  
  
  
  private
  
  def check_can_create_group
    @account_id = session[:account_id]
    account = Account.find_enabled(@account_id)
    @can_count = (account && account.can_create_group_count) || 0
    
    @created_group_count = Group.get_created_count(@account_id) || 0
  end
  
  def check_custom_group
    @group_id = params[:id]
    @group, @group_image = Group.get_group_with_image(@group_id)
    
    custom_key = @group.custom_key
    custom_group = custom_key && Group::Custom_Groups[custom_key]
    
    jump_to("/custom_groups/#{custom_group}/show/#{@group_id}") if custom_group && (custom_group != "")
  end
  
  def check_group_admin
    @group_id = params[:id]
    
    jump_to("/errors/forbidden") unless GroupMember.is_group_admin(@group_id, session[:account_id])
  end
  
  def check_group_master
    @group_id = params[:id]
    @group, @group_image = Group.get_group_with_image(@group_id)
    
    jump_to("/groups/members/#{@group_id}") unless @group.master_id == session[:account_id]
  end
  
  def check_group_member
    @group_id = params[:id]
    
    jump_to("/errors/forbidden") unless GroupMember.is_group_member(@group_id, session[:account_id])
  end
  
  def check_owner
    jump_to("/errors/forbidden") unless session[:account_id].to_s == params[:id]
  end
  
end

