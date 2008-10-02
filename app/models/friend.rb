class Friend < ActiveRecord::Base
  
  include CareerCommunity::AccountBelongings

  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :friend, :class_name => "Account", :foreign_key => "friend_id"

  # ---

  validates_presence_of :account_id, :friend_id
  
  def self.is_friend(a_id, f_id)
    self.find(:first, :conditions => ["account_id = ? and friend_id = ?", a_id, f_id])
  end
  
  def self.is_be_friend(a_id, f_id)
    self.find(:first, :conditions => ["account_id = ? and friend_id = ?", f_id, a_id])
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
