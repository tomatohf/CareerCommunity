class Goal < ActiveRecord::Base
  
  acts_as_trashable
  
    
  include CareerCommunity::Util


  has_many :follows, :class_name => "GoalFollow", :foreign_key => "goal_id", :dependent => :destroy
  has_many :posts, :class_name => "GoalPost", :foreign_key => "goal_id", :dependent => :destroy
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  
  
  define_index do
    # fields
    indexes :name

    # attributes
    has :created_at
    
    set_property :delta => true
    
    # set_property :field_weights => {:field => number}
  end
  
  
  validates_presence_of :account_id
  
  validates_presence_of :name, :message => "请输入 名称"
  
  validates_length_of :name, :maximum => 250, :message => "名称 超过长度限制", :allow_nil => false
  
  
  
  named_scope :deprecated, :conditions => ["deprecated = ?", true]
  
  
  
  CKP_goal = :goal
  
  FCKP_goal_links = :fc_goal_links
  
  after_save { |goal|
    self.set_goal_cache(goal)
    
    self.clear_goal_links_cache
  }
  
  after_destroy { |goal|
    self.clear_goal_cache(goal.id)
    
    self.clear_goal_links_cache
  }
  
  def self.clear_goal_links_cache
    Cache.delete(expand_cache_key(FCKP_goal_links))
  end
  
  
  
  def self.get_goal(goal_id)
    g = Cache.get("#{CKP_goal}_#{goal_id}".to_sym)
    
    unless g
      g = self.find(goal_id)
      
      self.set_goal_cache(g)
    end
    g
  end
  
  def self.set_goal_cache(goal)
    Cache.set("#{CKP_goal}_#{goal.id}".to_sym, goal.clear_association, Cache_TTL)
  end
  
  def self.clear_goal_cache(goal_id)
    Cache.delete("#{CKP_goal}_#{goal_id}".to_sym)
  end
  
  
  
  def clear_association
    copy = deep_copy(self)
    copy.clear_association_cache
    copy.clear_aggregation_cache
    copy
  end
  
end

