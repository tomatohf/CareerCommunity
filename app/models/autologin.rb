class Autologin < ActiveRecord::Base
  
  attr_protected :session_id, :account_id, :expire_time
  
  validates_presence_of :session_id, :account_id, :expire_time
  
  
  def self.delete_by_account(account_id)
    self.delete_all(["account_id = ?", account_id])
  end
  
  def self.find_record(session_id, account_id)
    self.find(:first, :conditions => ["account_id = ? and session_id = ?", account_id, session_id])
  end
  
  def self.get_by_account_id(account_id)
    self.find(:first, :conditions => ["account_id = ?", account_id])
  end
  
  def self.clear_expired_records
    self.delete_all(["expire_time < ?", Time.now])
  end
  
  def self.delete_record(session_id, account_id)
    self.delete_all(["account_id = ? and session_id = ?", account_id, session_id])
  end
  
end
