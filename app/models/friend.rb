class Friend < ActiveRecord::Base
  
  include CareerCommunity::AccountBelongings

  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :friend, :class_name => "Account", :foreign_key => "friend_id"

  # ---

  validates_presence_of :account_id, :friend_id
  
  
  
  after_destroy { |friend|
    self.clear_account_friend_ids_cache(friend.account_id)
    
    self.clear_account_be_friend_ids_cache(friend.friend_id)
  }
  
  after_save { |friend|
    self.clear_account_friend_ids_cache(friend.account_id)
    
    self.clear_account_be_friend_ids_cache(friend.friend_id)
  }
  
  
  CKP_account_friend_ids = :account_friend_ids
  CKP_account_be_friend_ids = :account_be_friend_ids
  
  
  
  def self.get_account_friend_ids(account_id)
    a_f_id = Cache.get("#{CKP_account_friend_ids}_#{account_id}".to_sym)
    
    unless a_f_id
      friends = self.get_all_by_account(account_id)
      
      a_f_id = self.set_account_friend_ids_cache(account_id, friends)
    end
    a_f_id
  end
  
  def self.set_account_friend_ids_cache(account_id, friends)
    a_f_id = friends.collect { |f| f.friend_id }
    
    Cache.set("#{CKP_account_friend_ids}_#{account_id}".to_sym, a_f_id, Cache_TTL)
    
    a_f_id
  end
  
  def self.clear_account_friend_ids_cache(account_id)
    Cache.delete("#{CKP_account_friend_ids}_#{account_id}".to_sym)
  end
  
  
  def self.get_account_be_friend_ids(account_id)
    a_b_f_id = Cache.get("#{CKP_account_be_friend_ids}_#{account_id}".to_sym)
    
    unless a_b_f_id
      be_friends = self.get_all_by_friend(account_id)
      
      a_b_f_id = self.set_account_be_friend_ids_cache(account_id, be_friends)
    end
    a_b_f_id
  end
  
  def self.set_account_be_friend_ids_cache(account_id, be_friends)
    a_b_f_id = be_friends.collect { |f| f.account_id }
    
    Cache.set("#{CKP_account_be_friend_ids}_#{account_id}".to_sym, a_b_f_id, Cache_TTL)
    
    a_b_f_id
  end
  
  def self.clear_account_be_friend_ids_cache(account_id)
    Cache.delete("#{CKP_account_be_friend_ids}_#{account_id}".to_sym)
  end
  
  
  
  def self.is_friend(a_id, f_id)
    friend_ids = self.get_account_friend_ids(a_id)
    friend_ids.include?(f_id.to_i)
  end
  
  def self.is_be_friend(a_id, f_id)
    be_friend_ids = self.get_account_be_friend_ids(a_id)
    be_friend_ids.include?(f_id.to_i)
  end
  
  def self.get_all_by_friend(friend_id, args = {})
    self.find(:all, args.merge(:conditions => ["friend_id = ?", friend_id]))
  end
  
  def self.get_all_both_friends_by_account(account_id, order = nil)
    sql = "select * from friends where account_id = ? and friend_id in (select account_id from friends where friend_id = ?)"
    sql += (order && order != "") ? "order by #{order}" : ""
    
    self.find_by_sql(
      [
        sql,
        account_id,
        account_id
      ]
    )
  end
  
  def self.count_friend(a_id)
    self.count(:conditions => ["account_id = ?", a_id])
  end
  
  
end
