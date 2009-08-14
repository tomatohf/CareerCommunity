class CustomerPost < ActiveRecord::Base
  
  acts_as_trashable
  
  
  
  # define_index do
  #   # fields
  #   indexes :title, :content
  #   indexes account.nick, :as => :account_nick
  #   indexes customer.name, :as => :customer_name
  #   indexes comments.content, :as => :comments_content
  #   indexes comments.account.nick, :as => :comments_account_nick
  # 
  #   # attributes
  #   has :responded_at
  #   
  #   set_property :delta => true
  #   
  #   # set_property :field_weights => {:field => number}
  # end
  
  include CareerCommunity::Util
  
  has_many :comments, :class_name => "CustomerPostComment", :foreign_key => "customer_post_id", :dependent => :destroy
  has_many :attachments, :class_name => "CustomerPostAttachment", :foreign_key => "customer_post_id", :dependent => :destroy
  
  belongs_to :customer, :class_name => "Account", :foreign_key => "customer_id"
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  
  
  validates_presence_of :account_id, :customer_id
  
  validates_presence_of :title, :message => "请输入 标题"
  validates_presence_of :content, :message => "请输入 内容"
  
  validates_length_of :title, :maximum => 256, :message => "标题 超过长度限制", :allow_nil => false
  
  
  
  after_destroy { |post|
    self.clear_post_cache(post.id)
    
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
  }
  
  after_create { |post|
    PointProfile.adjust_account_points_by_action(post.account_id, :add_post, true)
  }
  
  
  
  named_scope :good, :conditions => { :good => true }
  
  
  CKP_customer_post = :customer_post
  
  
  
  def self.get_post(post_id)
    post = Cache.get("#{CKP_customer_post}_#{post_id}".to_sym)
    
    unless post
      post = self.find(post_id)
      
      self.set_post_cache(post_id, post)
    end
    post
  end
  
  def self.set_post_cache(post_id, post)
    Cache.set("#{CKP_customer_post}_#{post_id}".to_sym, post.clear_association, Cache_TTL)
  end
  
  def self.clear_post_cache(post_id)
    Cache.delete("#{CKP_customer_post}_#{post_id}".to_sym)
  end
  
  
  def clear_association
    copy = deep_copy(self)
    copy.clear_association_cache
    copy.clear_aggregation_cache
    copy
  end
  
  
end

