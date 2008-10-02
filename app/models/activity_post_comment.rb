class ActivityPostComment < ActiveRecord::Base
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :activity_post, :class_name => "ActivityPost", :foreign_key => "activity_post_id"

  # ---

  validates_presence_of :account_id, :activity_post_id, :content
  
  validates_length_of :content, :maximum => 1000, :message => "评论内容 超过长度限制", :allow_nil => false
  
  
  
  after_destroy { |activity_post_comment|
    self.decrease_count_cache(activity_post_comment.activity_post_id)
  }
  
  after_create { |activity_post_comment|
    self.increase_count_cache(activity_post_comment.activity_post_id)
  }
  
  
  
  CKP_count = :activity_post_comment_count
  
  
  
  def self.get_count(activity_post_id)
    c = Cache.get("#{CKP_count}_#{activity_post_id}".to_sym)
    unless c
      c = self.count(:conditions => ["activity_post_id = ?", activity_post_id])
      
      Cache.set("#{CKP_count}_#{activity_post_id}".to_sym, c, Cache_TTL)
    end
    c
  end
  
  def self.increase_count_cache(activity_post_id, count = 1)
    c = Cache.get("#{CKP_count}_#{activity_post_id}".to_sym)
    if c
      updated_c = c.to_i + count
      
      Cache.set("#{CKP_count}_#{activity_post_id}".to_sym, updated_c, Cache_TTL)
    end
  end
  
  def self.decrease_count_cache(activity_post_id, count = 1)
    c = Cache.get("#{CKP_count}_#{activity_post_id}".to_sym)
    if c
      updated_c = c.to_i - count
      
      Cache.set("#{CKP_count}_#{activity_post_id}".to_sym, updated_c, Cache_TTL)
    end
  end
  
  def self.clear_count_cache(activity_post_id)
    Cache.delete("#{CKP_count}_#{activity_post_id}".to_sym)
  end
  
end