class SpaceComment < ActiveRecord::Base
  
  include CareerCommunity::Util
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :owner, :class_name => "Account", :foreign_key => "owner_id"

  # ---

  validates_presence_of :account_id, :owner_id, :content
  
  validates_length_of :content, :maximum => 1000, :message => "评论内容 超过长度限制", :allow_nil => false
  
  
  
  FCKP_spaces_show_wall = :fc_spaces_show_wall
  
  after_save { |space_comment|
    self.clear_spaces_show_wall_cache(space_comment.owner_id)
  }
  
  after_destroy { |space_comment|
    self.clear_spaces_show_wall_cache(space_comment.owner_id)
  }
  
  def self.clear_spaces_show_wall_cache(account_id)
    Cache.delete(expand_cache_key("#{FCKP_spaces_show_wall}_#{account_id}"))
  end
  
end