class VoteComment < ActiveRecord::Base
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :vote_topic, :class_name => "VoteTopic", :foreign_key => "vote_topic_id"
        

  # ---

  validates_presence_of :account_id, :vote_topic_id, :content
  
  validates_length_of :content, :maximum => 1000, :message => "评论内容 超过长度限制", :allow_nil => false
  
  
  
  after_destroy { |vote_comment|
    self.decrease_count_cache(vote_comment.vote_topic_id)
  }
  
  after_create { |vote_comment|
    self.increase_count_cache(vote_comment.vote_topic_id)
  }
  
  
  
  CKP_count = :vote_comment_count
  
  
  
  def self.get_count(vote_topic_id)
    c = Cache.get("#{CKP_count}_#{vote_topic_id}".to_sym)
    unless c
      c = self.count(:conditions => ["vote_topic_id = ?", vote_topic_id])
      
      Cache.set("#{CKP_count}_#{vote_topic_id}".to_sym, c, Cache_TTL)
    end
    c
  end
  
  def self.increase_count_cache(vote_topic_id, count = 1)
    c = Cache.get("#{CKP_count}_#{vote_topic_id}".to_sym)
    if c
      updated_c = c.to_i + count
      
      Cache.set("#{CKP_count}_#{vote_topic_id}".to_sym, updated_c, Cache_TTL)
    end
  end
  
  def self.decrease_count_cache(vote_topic_id, count = 1)
    c = Cache.get("#{CKP_count}_#{vote_topic_id}".to_sym)
    if c
      updated_c = c.to_i - count
      
      Cache.set("#{CKP_count}_#{vote_topic_id}".to_sym, updated_c, Cache_TTL)
    end
  end
  
  def self.clear_count_cache(vote_topic_id)
    Cache.delete("#{CKP_count}_#{vote_topic_id}".to_sym)
  end
  
end