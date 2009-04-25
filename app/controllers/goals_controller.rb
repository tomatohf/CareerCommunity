class GoalsController < ApplicationController
  
  Comment_Page_Size = 100
  Follow_Page_Size = 15
  Goal_Page_Size = 30
  
  Track_Page_Size = 20
  Goal_Post_Num = 25
  Post_List_Size = 50
  New_Comment_Size = 10
  New_Track_Size = 10
  
  Summary_New_Post_Size = 30
  Summary_New_Track_Size = 10
  
  
  layout "community"
  
  before_filter :check_current_account, :only => [:list_index]
  before_filter :check_login, :only => [:create, :edit, :update, :destroy,
                                        :list, :friend, :track_new, :track_edit,
                                        :track_create, :track_update, :track_destroy,
                                        :create_track_comment, :delete_track_comment,
                                        :follow_goal, :finish_goal,
                                        :active_follow, :finish_follow, :cancel_follow,
                                        :follow_edit, :follow_update,
                                        :follow_type_edit, :follow_type_update]
  before_filter :check_limited, :only => [:create, :update, :destroy,
                                          :track_create, :track_update, :track_destroy,
                                          :create_track_comment, :delete_track_comment,
                                          :follow_goal, :finish_goal,
                                          :active_follow, :finish_follow, :cancel_follow,
                                          :follow_update, :follow_type_update]
  
  before_filter :check_admin, :only => [:edit, :update]
  before_filter :check_superadmin, :only => [:destroy]
  
  before_filter :check_account_access, :only => [:list, :friend]
  
  before_filter :check_follow_owner, :only => [:track_new, :track_create,
                                                :active_follow, :finish_follow, :cancel_follow,
                                                :follow_edit, :follow_update,
                                                :follow_type_edit, :follow_type_update]
  before_filter :check_track_owner, :only => [:track_edit, :track_update, :track_destroy]
  
  before_filter :check_comment_owner, :only => [:delete_track_comment]
  
  
  
  def index
    jump_to("/goals/summary")
  end
  
  def summary
    @new_tracks = GoalTrack.find(
      :all,
      :limit => Summary_New_Track_Size,
      :include => [:goal_follow],
      :order => "created_at DESC"
    )
    
    @new_posts = GoalPost.find(
      :all,
      :limit => Summary_New_Post_Size,
      :select => "id, created_at, goal_id, top, good, account_id, title, responded_at",
      :include => [:account],
      :order => "responded_at DESC, created_at DESC"
    )
  end
  
  def all
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @goals = Goal.paginate(
			:page => page,
      :per_page => Goal_Page_Size,
		  :order => "created_at DESC"
		)
		
		goal_ids = @goals.collect { |goal| goal.id }
		
		@follow_counts = GoalFollow.count(
      :conditions => ["goal_id in (?)", goal_ids],
      :group => "goal_id"
    )
    
		@goal_posts = GoalPost.find(
      :all,
      :limit => Summary_New_Post_Size,
      :select => "id, created_at, goal_id, good, title, responded_at",
      :conditions => ["goal_id in (?)", goal_ids],
      :order => "responded_at DESC, created_at DESC"
    )
  end

  def list_index
    jump_to("/goals/list/#{session[:account_id]}")
  end

  def list
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @goal_follows = GoalFollow.paginate(
			:page => page,
      :per_page => Follow_Page_Size,
			:conditions => ["account_id = ?", @account_id],
			:include => [:goal],
		  :order => "created_at DESC"
		)
		
		goal_ids = @goal_follows.collect { |goal_follow| goal_follow.goal_id }
		@goal_posts = GoalPost.find(
      :all,
      :limit => Summary_New_Post_Size,
      :select => "id, created_at, goal_id, good, title, responded_at",
      :conditions => ["goal_id in (?)", goal_ids],
      :order => "responded_at DESC, created_at DESC"
    )
  end
  
  def create_track_comment
    track_comment = GoalTrackComment.new(:account_id => session[:account_id])
    
    track_comment.content = params[:track_comment] && params[:track_comment].strip
    track_comment.goal_track_id = params[:id]
    
    comment_saved = track_comment.save
    
    
    if comment_saved
      AccountAction.create_new(session[:account_id], "add_goal_track_comment", {
        :track_id => track_comment.goal_track_id,
        :comment_id => track_comment.id,
        :comment_content => track_comment.content
      })
    end
    
    
    total_count = GoalTrackComment.get_count(track_comment.goal_track_id)
    last_page = total_count > 0 ? (total_count.to_f/Comment_Page_Size).ceil : 1
    
    jump_to("/goals/track/#{track_comment.goal_track_id}/#{last_page}#{"#comment_#{track_comment.id}" if comment_saved}")
  end
  
  def delete_track_comment
    @track_comment.destroy
    
    jump_to("/goals/track/#{@track_id}")
  end
  
  def track
    @track = GoalTrack.find(params[:id])
    @follow = GoalFollow.find(@track.goal_follow_id)
    @goal = Goal.get_goal(@follow.goal_id)
    
    @edit = (@follow.account_id == session[:account_id])
    
    @follower = Account.get_nick_and_pic(@follow.account_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @track_comments = @track.comments.paginate(
      :page => page,
      :per_page => Comment_Page_Size,
      :total_entries => GoalTrackComment.get_count(@track.id),
      :include => [:account => [:profile_pic]],
      :order => "created_at ASC"
    )
  end
  
  def track_new
    @track = GoalTrack.new
    
    @goal = Goal.get_goal(@follow.goal_id)
  end
  
  def track_create
    @track = GoalTrack.new(
      :goal_follow_id => @follow.id,
      :goal_id => @follow.goal_id
    )
    
    @track.value = params[:track_value] && params[:track_value].strip
    @track.desc = params[:track_desc] && params[:track_desc].strip
    
    if @track.save
      AccountAction.create_new(session[:account_id], "add_goal_track", {
        :track_id => @track.id,
        :track_value => @track.value,
        :track_desc => @track.desc,
        :goal_follow_id => @track.goal_follow_id,
        :goal_id => @track.goal_id
      })
      
      jump_to("/goals/follow/#{@follow.id}")
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
      
      @goal = Goal.get_goal(@follow.goal_id)
      
      render :action => "track_new"
    end
  end
  
  def track_edit
    @goal = Goal.get_goal(@follow.goal_id)
  end
  
  def track_update
    @track.value = params[:track_value] && params[:track_value].strip
    @track.desc = params[:track_desc] && params[:track_desc].strip
    
    if @track.save
      flash.now[:message] = "已成功保存"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    @goal = Goal.get_goal(@follow.goal_id)

    render :action => "track_edit"
  end
  
  def track_destroy
    @track.destroy
    
    jump_to("/goals/follow/#{@track.goal_follow_id}")
  end
  
  def follow
    @follow = GoalFollow.find(params[:id])
    
    @edit = (@follow.account_id == session[:account_id])
    
    @goal = Goal.get_goal(@follow.goal_id)
    @follower = Account.get_nick_and_pic(@follow.account_id) unless @edit
    
    @new_comments = GoalTrackComment.find(
      :all,
      :limit => New_Comment_Size,
      :conditions => ["goal_track_id in (select id from goal_tracks where goal_follow_id = ?)", @follow.id],
      :include => [:account => [:profile_pic]],
      :order => "updated_at DESC"
    )
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @tracks = @follow.tracks.paginate(
      :page => page,
      :per_page => Track_Page_Size,
      :conditions => ["goal_follow_id = ?", @follow.id],
      :order => "created_at DESC"
    )
  end

  def show
    @goal = Goal.get_goal(params[:id])
    
    @goal_account = Account.get_nick_and_pic(@goal.account_id)
    
    @follow = GoalFollow.find(
      :first,
      :conditions => ["goal_id = ? and account_id = ?", @goal.id, session[:account_id]]
    )
    
    @top_goal_posts = GoalPost.find(
      :all,
      :select => "id, created_at, goal_id, top, good, account_id, title, responded_at",
      :conditions => ["goal_id = ? and top = ?", @goal.id, true],
      :include => [:account],
      :order => "responded_at DESC, created_at DESC"
    )
    
    @goal_posts = GoalPost.find(
      :all,
      :limit => Goal_Post_Num,
      :select => "id, created_at, goal_id, top, good, account_id, title, responded_at",
      :conditions => ["goal_id = ? and top = ?", @goal.id, false],
      :include => [:account],
      :order => "responded_at DESC, created_at DESC"
    )
    
    @new_tracks = GoalTrack.find(
      :all,
      :limit => New_Track_Size,
      :conditions => ["goal_id = ?", @goal.id],
      :include => [:goal_follow],
      :order => "created_at DESC"
    )
  end
  
  def post
    @goal = Goal.get_goal(params[:id])
    
    @top_goal_posts = GoalPost.find(
      :all,
      :select => "id, created_at, goal_id, top, good, account_id, title, responded_at",
      :conditions => ["goal_id = ? and top = ?", @goal.id, true],
      :include => [:account],
      :order => "responded_at DESC, created_at DESC"
    )
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @goal_posts = GoalPost.paginate(
      :page => page,
      :per_page => Post_List_Size,
      :select => "id, created_at, goal_id, top, good, account_id, title, responded_at",
      :conditions => ["goal_id = ? and top = ?", @goal.id, false],
      :include => [:account],
      :order => "responded_at DESC, created_at DESC"
    )
  end
  
  def good_post
    @goal = Goal.get_goal(params[:id])
    
    @top_goal_posts = GoalPost.good.find(
      :all,
      :select => "id, created_at, goal_id, top, good, account_id, title, responded_at",
      :conditions => ["goal_id = ? and top = ?", @goal.id, true],
      :include => [:account],
      :order => "responded_at DESC, created_at DESC"
    )
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @goal_posts = GoalPost.good.paginate(
      :page => page,
      :per_page => Post_List_Size,
      :select => "id, created_at, goal_id, top, good, account_id, title, responded_at",
      :conditions => ["goal_id = ? and top = ?", @goal.id, false],
      :include => [:account],
      :order => "responded_at DESC, created_at DESC"
    )
  end
  
  def follow_edit
    @goal = Goal.get_goal(@follow.goal_id)
  end
  
  def follow_update
    goal_name = params[:goal_name] && params[:goal_name].strip
    
    goal = get_goal_from_name(goal_name)
    
    @follow.goal_id = goal.id
    @follow.save
    
    jump_to("/goals/#{@follow.goal_id}")
  end
  
  def follow_type_edit
    @goal = Goal.get_goal(@follow.goal_id)
  end
  
  def follow_type_update
    follow_type_id = params[:goal_follow_type] && params[:goal_follow_type].strip
    
    @follow.type_id = follow_type_id
    @follow.save
    
    jump_to("/goals/#{@follow.goal_id}")
  end
  
  def active_follow
    change_follow_status(@follow, GoalFollowStatus.active[0])
    
    jump_to("/goals/#{@follow.goal_id}")
  end
  
  def finish_follow
    flash[:message] = [
      ["刚刚完成了这个目标, 来"],
      ["发个帖子跟大家分享一下你的经验和感想吧"]
    ] if change_follow_status(@follow, GoalFollowStatus.finished[0])
    
    jump_to("/goals/#{@follow.goal_id}")
  end
  
  def cancel_follow
    flash[:message] = [
      ["刚刚终止了这个目标, 来"],
      ["发个帖子跟大家讨论一下为什么吧"]
    ] if change_follow_status(@follow, GoalFollowStatus.cancelled[0])
    
    jump_to("/goals/#{@follow.goal_id}")
  end
  
  def follow_goal
    create_goal_follow(params[:id], GoalFollowStatus.active[0])
    
    jump_to("/goals/#{@goal_id}")
  end
  
  def finish_goal
    create_goal_follow(params[:id], GoalFollowStatus.finished[0])
    
    jump_to("/goals/#{@goal_id}")
  end
  
  def create
    goal_name = params[:goal_name] && params[:goal_name].strip
    
    goal = get_goal_from_name(goal_name)
    
    create_goal_follow(goal.id, GoalFollowStatus.active[0], goal)
    
    jump_to("/goals/#{@goal_id}")
  end
  
  def edit
    @goal = Goal.get_goal(params[:id])
  end
  
  def update
    @goal = Goal.get_goal(params[:id])
    
    @goal.name = params[:goal_name] && params[:goal_name].strip
    
    if @goal.save
      flash.now[:message] = "已成功保存"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end

    render :action => "edit"
  end
  
  def destroy
    @goal = Goal.get_goal(params[:id])
    
    @goal.destroy
    
    jump_to("/goals/summary")
  end
  
  
  private
  
  def is_general_admin?
    ApplicationController.helpers.general_admin?(session[:account_id])
  end
  
  def check_admin
    jump_to("/errors/forbidden") unless is_general_admin?
  end
  
  def is_superadmin?
    ApplicationController.helpers.superadmin?(session[:account_id])
  end
  
  def check_superadmin
    jump_to("/errors/forbidden") unless is_superadmin?
  end
  
  def check_account_access
    @account_id = params[:id]
    jump_to("/errors/forbidden") unless session[:account_id].to_s == @account_id
  end
  
  def check_follow_owner
    @follow = GoalFollow.find(params[:id])
    
    jump_to("/errors/forbidden") unless @follow.account_id == session[:account_id]
  end
  
  def check_track_owner
    @track = GoalTrack.find(params[:id])
    @follow = GoalFollow.find(@track.goal_follow_id)
    
    jump_to("/errors/forbidden") unless @follow.account_id == session[:account_id]
  end
  
  def check_comment_owner
    @track_comment = GoalTrackComment.find(params[:id])
    @track_id = @track_comment.goal_track_id
    track = GoalTrack.find(@track_id)
    follow = GoalFollow.find(track.goal_follow_id)
    
    jump_to("/errors/forbidden") unless follow.account_id == session[:account_id]
  end
  
  def create_goal_follow(goal_id, status_id, goal = nil)
    goal_follow = GoalFollow.find(
      :first,
      :conditions => ["goal_id = ? and account_id = ?", goal_id, session[:account_id]]
    )
    
    unless goal_follow
      goal_follow = GoalFollow.new(
        :account_id => session[:account_id],
        :goal_id => goal_id,
        :status_id => status_id,
        :type_id => GoalFollowType.rank[0]
      )
      
      if goal_follow.save
        goal ||= Goal.get_goal(goal_id)
        
        AccountAction.create_new(session[:account_id], "add_goal", {
          :goal_id => goal_id,
          :goal_name => goal.name
        })
      end
    end
  end
  
  def change_follow_status(follow, status_id)
    follow.status_id = status_id
    follow.status_updated_at = DateTime.now

    follow.save
  end
  
  def get_goal_from_name(goal_name)
    jump_to("/goals/list/#{session[:account_id]}") unless goal_name && (goal_name != "")
    
    goal = Goal.find(
      :first,
      :conditions => ["name = ?", goal_name]
    )
    
    unless goal
      goal = Goal.new(
        :account_id => session[:account_id],
        :name => goal_name
      )
      
      jump_to("/goals/list/#{session[:account_id]}") unless goal.save
    end
    
    goal
  end
  
end

