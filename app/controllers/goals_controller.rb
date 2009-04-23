class GoalsController < ApplicationController
  
  Comment_Page_Size = 100
  Goal_Page_Size = 15
  Goal_Post_Num = 20
  Post_List_Size = 50
  
  
  layout "community"
  
  before_filter :check_current_account, :only => [:list_index, :friend_index]
  before_filter :check_login, :only => [:create, :edit, :update, :destroy,
                                        :list, :friend]
  before_filter :check_limited, :only => [:create, :update, :destroy]
  
  before_filter :check_admin, :only => [:edit, :update, :destroy]
  
  before_filter :check_account_access, :only => [:list, :friend]
  
  
  
  def index
    jump_to("/goals/summary")
  end
  
  def summary
    
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
    
  end
  
  def update
    
  end
  
  def destroy
    
  end
  
  
  private
  
  def is_general_admin?
    ApplicationController.helpers.general_admin?(session[:account_id])
  end
  
  def check_admin
    jump_to("/errors/forbidden") unless is_general_admin?
  end
  
  def check_account_access
    @account_id = params[:id]
    jump_to("/errors/forbidden") unless session[:account_id].to_s == @account_id
  end
  
end

