class AccountSetting < ActiveRecord::Base

  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"

  # ---

  validates_presence_of :account_id
  
  
  
  after_destroy { |account_setting|
    self.clear_account_setting_cache(account_setting.account_id)
  }
  
  after_save { |account_setting|
    self.set_account_setting_cache(account_setting.account_id, account_setting)
  }
  
  
  CKP_account_setting = :account_setting
  
  
  
  def self.get_account_setting(account_id)
    a_s = Cache.get("#{CKP_account_setting}_#{account_id}".to_sym)
    
    unless a_s
      a_s = AccountSetting.find(
        :first, :conditions => ["account_id = ?", account_id]
      )
      unless a_s
        a_s = AccountSetting.new(:account_id => account_id, :setting => "")
        a_s.save
      end
      
      Cache.set("#{CKP_account_setting}_#{account_id}".to_sym, a_s, Cache_TTL)
    end
    a_s
  end
  
  def self.set_account_setting_cache(account_id, account_setting)
    Cache.set("#{CKP_account_setting}_#{account_id}".to_sym, account_setting, Cache_TTL)
  end
  
  def self.clear_account_setting_cache(account_id)
    Cache.delete("#{CKP_account_setting}_#{account_id}".to_sym)
  end
  
  
  
  @@default_values = {
    # profile visible settings
    # "any" or "login" or "friend" or "both_friend"
    :profile_basic_visible => "any",
    :profile_contact_visible => "friend",
    :profile_hobby_visible => "any",
    :profile_resume_visible => "any"
    
  }
  def self.default_value(name)
    @@default_values[name]
  end
  
  
  # begin: valid setting values
  
  def self.valid_profile_setting_values
    ["any", "login", "friend", "both_friend"]
  end
    
  # end: valid setting values
  
  def get_setting_value(key, hash_setting = nil)
    hash_setting ||= get_setting
    
    hash_setting[key] || self.class.default_value(key)
  end
  
  def get_setting
    ((self.setting && self.setting != "") && eval(self.setting)) || {}
  end
  
  def fill_setting(hash_setting)
    self.setting = hash_setting.inspect
  end
  
  def update_setting(hash_setting)
    new_setting = self.get_setting.merge(hash_setting)
    self.fill_setting(new_setting)
  end

end
