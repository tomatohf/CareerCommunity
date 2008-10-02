class AccountSetting < ActiveRecord::Base

  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"

  # ---

  validates_presence_of :account_id
  
  # TODO - private setting, how to display birthday(year, year&month, year&month&date)
  
  
  
  @@default_values = {
                      # :name => "value"
                    }
  def self.default_value(name)
    @@default_values[name]
  end
  
  
  def setting_hash
    {}
  end

end
