class BlogComment < ActiveRecord::Base
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :blog, :class_name => "Blog", :foreign_key => "blog_id"

  # ---

  validates_presence_of :account_id, :blog_id, :content
  
  validates_length_of :content, :maximum => 1000, :message => "评论内容 超过长度限制", :allow_nil => false
  
  
  
  after_destroy { |blog_comment|
    self.decrease_count_cache(blog_comment.blog_id)
  }
  
  after_create { |blog_comment|
    self.increase_count_cache(blog_comment.blog_id)
  }
  
  
  
  CKP_count = :blog_comment_count
  
  
  
  def self.get_count(blog_id)
    c = Cache.get("#{CKP_count}_#{blog_id}".to_sym)
    unless c
      c = self.count(:conditions => ["blog_id = ?", blog_id])
      
      Cache.set("#{CKP_count}_#{blog_id}".to_sym, c, Cache_TTL)
    end
    c
  end
  
  def self.increase_count_cache(blog_id, count = 1)
    c = Cache.get("#{CKP_count}_#{blog_id}".to_sym)
    if c
      updated_c = c.to_i + count
      
      Cache.set("#{CKP_count}_#{blog_id}".to_sym, updated_c, Cache_TTL)
    end
  end
  
  def self.decrease_count_cache(blog_id, count = 1)
    c = Cache.get("#{CKP_count}_#{blog_id}".to_sym)
    if c
      updated_c = c.to_i - count
      
      Cache.set("#{CKP_count}_#{blog_id}".to_sym, updated_c, Cache_TTL)
    end
  end
  
  def self.clear_count_cache(blog_id)
    Cache.delete("#{CKP_count}_#{blog_id}".to_sym)
  end
  
end