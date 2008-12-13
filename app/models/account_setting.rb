class AccountSetting < ActiveRecord::Base
  
  include CareerCommunity::Util

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
      
      Cache.set("#{CKP_account_setting}_#{account_id}".to_sym, a_s.clear_association, Cache_TTL)
    end
    a_s
  end
  
  def self.set_account_setting_cache(account_id, account_setting)
    Cache.set("#{CKP_account_setting}_#{account_id}".to_sym, account_setting.clear_association, Cache_TTL)
  end
  
  def self.clear_account_setting_cache(account_id)
    Cache.delete("#{CKP_account_setting}_#{account_id}".to_sym)
  end

  def clear_association
    copy = deep_copy(self)
    copy.clear_association_cache
    copy.clear_aggregation_cache
    copy
  end
  
  
  
  @@default_values = {
    # profile visible settings
    # "any" or "login" or "friend" or "both_friend"
    :profile_basic_visible => "login",
    :profile_contact_visible => "friend",
    :profile_hobby_visible => "login",
    :profile_resume_visible => "friend",
    
    # email settings
    # "true" or "false"
    :email_message_notify => "false",
    :email_group_invitation_notify => "true",
    :email_activity_invitation_notify => "true",
    :email_vote_invitation_notify => "true",
    
    # module index page settings
    # group
    # "all" or "recent" or "join" or "admin"
    :module_group_index => "recent",
    # activity
    # "all" or "week" or "recent" or "join" or "join_notbegin" or "create"
    :module_activity_index => "all",
    
    :dumy => ""
  }
  def self.default_value(name)
    @@default_values[name]
  end
  
  
  # begin: valid setting values
  
  def self.valid_profile_setting_values
    ["any", "login", "friend", "both_friend"]
  end
  
  def self.valid_email_setting_values
    ["true", "false"]
  end
  
  def self.valid_group_index_setting_values
    ["all", "recent", "join", "admin"]
  end
  
  def self.valid_activity_index_setting_values
    ["all", "week", "recent", "join", "join_notbegin", "create"]
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
