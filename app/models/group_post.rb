class GroupPost < ActiveRecord::Base
  
  acts_as_trashable
  
  
  define_index do
    # fields
    indexes :title, :content
    indexes account.nick, :as => :account_nick
    indexes group.name, :as => :group_name
    indexes comments.content, :as => :comments_content
    indexes comments.account.nick, :as => :comments_account_nick

    # attributes
    has :created_at, :updated_at, :responded_at, :group_id
    
    set_property :delta => true
    
    # set_property :field_weights => {:field => number}
  end
  
  include CareerCommunity::AccountBelongings
  include CareerCommunity::Util
  
  has_many :comments, :class_name => "GroupPostComment", :foreign_key => "group_post_id", :dependent => :destroy
  has_many :attachments, :class_name => "GroupPostAttachment", :foreign_key => "group_post_id", :dependent => :destroy
  
  belongs_to :group, :class_name => "Group", :foreign_key => "group_id"
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  
  
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
  }
  
  def self.clear_posts_group_feed_cache(group_id)
    Cache.delete(expand_cache_key("#{GroupsController::ACKP_posts_group_feed}_#{group_id}.atom"))
  end
  
  
  
  named_scope :good, :conditions => { :good => true }
  
  
  CKP_group_post = :group_post
  
  
  
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
  
  
end