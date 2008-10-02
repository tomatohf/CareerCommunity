class Message < ActiveRecord::Base
  
  include CareerCommunity::AccountBelongings
  
  belongs_to :receiver, :class_name => "Account", :foreign_key => "receiver_id"
  belongs_to :sender, :class_name => "Account", :foreign_key => "sender_id"

  # ---

  validates_presence_of :receiver_id, :sender_id, :content
  
  validates_length_of :content, :maximum => 1000, :message => "消息内容 超过长度限制", :allow_nil => false
  
  
  after_destroy { |message|
    Message.decrease_unread_count_cache(message.receiver_id, 1) unless message.has_read
  }
  
  after_create { |message|
    Message.increase_unread_count_cache(message.receiver_id, 1)
  }
  
  
  CKP_unread_count = :message_unread_count
  
  
  
  def self.get_threads(receiver_id, sender_id, reply_id)
    self.find(
      :all,
      :conditions => ["(reply_to_id = ? or id = ?) and receiver_id = ? and sender_id = ?", reply_id, reply_id, receiver_id, sender_id]
    )
  end
  
  def self.get_unread_count(account_id)
    u_c = Cache.get("#{CKP_unread_count}_#{account_id}".to_sym)
    unless u_c
      u_c = Message.count(:conditions => ["receiver_id = ? and has_read = ?", account_id, false])
      
      Cache.set("#{CKP_unread_count}_#{account_id}".to_sym, u_c, Cache_TTL)
    end
    u_c
  end
  
  def self.clear_unread_count_cache(account_id)
    Cache.delete("#{CKP_unread_count}_#{account_id}".to_sym)
  end
  
  def self.increase_unread_count_cache(account_id, count = 1)
    u_c = Cache.get("#{CKP_unread_count}_#{account_id}".to_sym)
    if u_c
      updated_u_c = u_c.to_i + count
      
      Cache.set("#{CKP_unread_count}_#{account_id}".to_sym, updated_u_c, Cache_TTL)
    end
  end
  
  def self.decrease_unread_count_cache(account_id, count = 1)
    u_c = Cache.get("#{CKP_unread_count}_#{account_id}".to_sym)
    if u_c
      updated_u_c = u_c.to_i - count
      
      Cache.set("#{CKP_unread_count}_#{account_id}".to_sym, updated_u_c, Cache_TTL)
    end
  end
  
end