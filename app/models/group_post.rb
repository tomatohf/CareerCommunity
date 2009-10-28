class GroupPost < ActiveRecord::Base
  
  acts_as_trashable
  
  
  include CareerCommunity::AccountBelongings
  include CareerCommunity::Util
  
  has_many :comments, :class_name => "GroupPostComment", :foreign_key => "group_post_id", :dependent => :destroy
  has_many :attachments, :class_name => "GroupPostAttachment", :foreign_key => "group_post_id", :dependent => :destroy
  
  belongs_to :group, :class_name => "Group", :foreign_key => "group_id"
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  
  
  define_index do
    # fields
    indexes :title, :content
    indexes account.nick, :as => :account_nick
    indexes group.name, :as => :group_name
    indexes comments.content, :as => :comments_content
    indexes comments.account.nick, :as => :comments_account_nick

    # attributes
    has :responded_at, :group_id
    
    set_property :delta => true
    
    # set_property :field_weights => {:field => number}
  end
  
  
  validates_presence_of :account_id, :group_id
  
  validates_presence_of :title, :message => "请输入 标题"
  validates_presence_of :content, :message => "请输入 内容"
  
  validates_length_of :title, :maximum => 256, :message => "标题 超过长度限制", :allow_nil => false
  
  
  
  after_destroy { |post|
    self.clear_post_cache(post.id)
    
    self.clear_posts_group_feed_cache(post.group_id)
    
    PointProfile.adjust_account_points_by_action(post.account_id, :add_post, false)
    # should also think about to decrease good post points, if it's good post
  }
  
  after_save { |post|
    if post.good_changed?
      PointProfile.adjust_account_points_by_action(post.account_id, :add_post_to_good, post.good)
    end
    
    # clear changed attributes, before we cache it ...
    post.clean_myself
    self.set_post_cache(post.id, post)
    
    self.clear_posts_group_feed_cache(post.group_id)
  }
  
  after_create { |post|
    PointProfile.adjust_account_points_by_action(post.account_id, :add_post, true)
    
    # check whether the post is in the problem group
    # if so, send email notifications
    if post.group_id == CustomGroups::ProblemController::Problem_Group_ID && post.category_id && post.category_id != ""
      observers = CustomGroups::ProblemController::Category_Observers[post.category_id]
      self.add_problem_group_notification(
        {
          :post_id => post.id,
          :poster_id => post.account_id,
          :post_title => post.title,
          :observers_id => observers
        }
      ) if observers && observers.size > 0
    end
  }
  
  def self.clear_posts_group_feed_cache(group_id)
    Cache.delete(expand_cache_key("#{GroupsController::ACKP_posts_group_feed}_#{group_id}.atom"))
  end
  
  
  
  named_scope :good, :conditions => { :good => true }
  
  
  CKP_group_post = :group_post
  
  CKP_problem_group_notifications = :problem_group_notifications
  
  
  
  def self.get_post(post_id)
    post = Cache.get("#{CKP_group_post}_#{post_id}".to_sym)
    
    unless post
      post = self.find(post_id)
      
      self.set_post_cache(post_id, post)
    end
    post
  end
  
  def self.set_post_cache(post_id, post)
    Cache.set("#{CKP_group_post}_#{post_id}".to_sym, post.clear_association, Cache_TTL)
  end
  
  def self.clear_post_cache(post_id)
    Cache.delete("#{CKP_group_post}_#{post_id}".to_sym)
  end
  
  
  def clear_association
    copy = deep_copy(self)
    copy.clear_association_cache
    copy.clear_aggregation_cache
    copy
  end
  
  
  def self.load_associations(posts, includes)
    preload_associations(posts, includes)
  end
  
  
  
  # problem group related methods
  def self.get_problem_group_notifications
    Cache.get(CKP_problem_group_notifications) || []
  end
  
  def self.add_problem_group_notification(notification)
    notifications = get_problem_group_notifications
    notifications << notification
    Cache.set(CKP_problem_group_notifications, notifications)
  end
  
  def self.clear_problem_group_notifications
    Cache.delete(CKP_problem_group_notifications)
  end
  
  
end