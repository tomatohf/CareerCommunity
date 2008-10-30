class AccountSetting < ActiveRecord::Base

  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"

  # ---

  validates_presence_of :account_id
  
  # TODO - private setting, how to display birthday(year, year&month, year&month&date)
  
  
  
  @@default_values = {
    
  }
  def self.default_value(name)
    @@default_values[name]
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
