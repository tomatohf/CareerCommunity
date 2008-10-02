class PhotoComment < ActiveRecord::Base
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :photo, :class_name => "Photo", :foreign_key => "photo_id"

  # ---

  validates_presence_of :account_id, :photo_id, :content
  
  validates_length_of :content, :maximum => 1000, :message => "评论内容 超过长度限制", :allow_nil => false
  
  
  
  after_destroy { |photo_comment|
    self.decrease_count_cache(photo_comment.photo_id)
  }
  
  after_create { |photo_comment|
    self.increase_count_cache(photo_comment.photo_id)
  }
  
  
  
  CKP_count = :photo_comment_count
  
  
  
  def self.get_count(photo_id)
    c = Cache.get("#{CKP_count}_#{photo_id}".to_sym)
    unless c
      c = self.count(:conditions => ["photo_id = ?", photo_id])
      
      Cache.set("#{CKP_count}_#{photo_id}".to_sym, c, Cache_TTL)
    end
    c
  end
  
  def self.increase_count_cache(photo_id, count = 1)
    c = Cache.get("#{CKP_count}_#{photo_id}".to_sym)
    if c
      updated_c = c.to_i + count
      
      Cache.set("#{CKP_count}_#{photo_id}".to_sym, updated_c, Cache_TTL)
    end
  end
  
  def self.decrease_count_cache(photo_id, count = 1)
    c = Cache.get("#{CKP_count}_#{photo_id}".to_sym)
    if c
      updated_c = c.to_i - count
      
      Cache.set("#{CKP_count}_#{photo_id}".to_sym, updated_c, Cache_TTL)
    end
  end
  
  def self.clear_count_cache(photo_id)
    Cache.delete("#{CKP_count}_#{photo_id}".to_sym)
  end
  
end