class GoalsController < ApplicationController
  
  Comment_Page_Size = 100
  Goal_Page_Size = 15
  
  Track_Page_Size = 20
  Goal_Post_Num = 25
  Post_List_Size = 50
  New_Comment_Size = 10
  
  
  layout "community"
  
  before_filter :check_current_account, :only => [:list_index, :friend_index]
  before_filter :check_login, :only => [:create, :edit, :update, :destroy,
                                        :list, :friend, :track_new, :track_edit,
                                        :track_create, :track_update, :track_destroy]
  before_filter :check_limited, :only => [:create, :update, :destroy,
                                          :track_create, :track_update, :track_destroy]
  
  before_filter :check_admin, :only => [:edit, :update]
  before_filter :check_superadmin, :only => [:destroy]
  
  before_filter :check_account_access, :only => [:list, :friend]
  
  before_filter :check_follow_owner, :only => [:track_new, :track_create]
  before_filter :check_track_owner, :only => [:track_edit, :track_update, :track_destroy]
  
  
  
  def index
    jump_to("/goals/summary")
  end
  
  def summary
    
  end

  def list_index
    jump_to("/goals/list/#{session[:account_id]}")
  end

  def list
    @account_id

  end

  def friend_index
    jump_to("/goals/friend/#{session[:account_id]}")
  end

  def friend
    @account_id

  end
  
  def track_new
    @track = GoalTrack.new
    
    @goal = Goal.get_goal(@follow.goal_id)
  end
  
  def track_create
    @track = GoalTrack.new(
      :goal_follow_id => @follow.id
    )
    
    @track.value = params[:track_value] && params[:track_value].strip
    @track.desc = params[:track_desc] && params[:track_desc].strip
    
    if @track.save
      # TODO
      # record account action
      #AccountAction.create_new(session[:account_id], "add_blog", {
      #  :blog_id => @blog.id,
      #  :blog_title => @blog.title
      #})
      
      jump_to("/goals/follow/#{@follow.id}")
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
      
      @goal = Goal.get_goal(@follow.goal_id)
      
      render :action => "track_new"
    end
  end
  
  def track_edit
    
  end
  
  def track_update
    
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
      :order => "created_at DESC"
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
  
  def create
    goal_name = params[:goal_name] && params[:goal_name].strip
    
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
    
    goal_follow = GoalFollow.new(
      :account_id => session[:account_id],
      :goal_id => goal.id,
      :status_id => GoalFollowStatus.active[0],
      :type_id => GoalFollowType.rank[0]
    )
    
    if goal_follow.save
      jump_to("/goals/#{goal.id}")
    else
      jump_to("/goals/list/#{session[:account_id]}")
    end
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
  
end

