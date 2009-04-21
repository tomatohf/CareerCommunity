class Goal < ActiveRecord::Base
  
  acts_as_trashable
  
  
  define_index do
    # fields
    indexes :title

    # attributes
    has :created_at, :updated_at, :account_id, :deprecated
    
    set_property :delta => true
    
    # set_property :field_weights => {:field => number}
  end
  
  
  
  include CareerCommunity::Util

  
  
  has_many :follows, :class_name => "GoalFollow", :foreign_key => "goal_id", :dependent => :destroy
  has_many :posts, :class_name => "GoalPost", :foreign_key => "goal_id", :dependent => :destroy
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  
  
  validates_presence_of :account_id
  
  validates_presence_of :name, :message => "请输入 名称"
  
  validates_length_of :name, :maximum => 250, :message => "名称 超过长度限制", :allow_nil => false
  
  
  
  named_scope :deprecated, :conditions => ["deprecated = ?", true]
  
  
  
  FCKP_goal_links = :fc_index_blog
  
  after_save { |goal|
    self.clear_goal_links_cache
  }
  
  after_destroy { |goal|
    self.clear_goal_links_cache
  }
  
  def self.clear_goal_links_cache
    Cache.delete(expand_cache_key(FCKP_goal_links))
  end
  
  
end

