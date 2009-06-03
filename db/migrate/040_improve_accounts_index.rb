class ImproveAccountsIndex < ActiveRecord::Migration
  def self.up
    
    # remove_index :accounts, :email, :unique => true
    remove_index :accounts, :enabled
    
    
    remove_index :timezones, :name
    
    
    remove_index :roles, :name
    
    
    remove_index :accounts_roles, [:account_id, :role_id]
    
    
    remove_index :autologins, :account_id
    
    add_index :autologins, [:account_id, :session_id]
    add_index :autologins, :expire_time
    
    
    # remove_index :account_settings, :account_id
    
  end

  def self.down
    
    # add_index :account_settings, :account_id
    
    
    remove_index :autologins, :expire_time
    remove_index :autologins, [:account_id, :session_id]
    
    add_index :autologins, :account_id
    
    
    add_index :accounts_roles, [:account_id, :role_id]
    
    
    add_index :roles, :name
    
    
    add_index :timezones, :name
    
    
    # add_index :accounts, :email, :unique => true
    add_index :accounts, :enabled
    
  end
end

