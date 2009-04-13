class AccountActionHide < ActiveRecord::Migration
  def self.up

    add_column :account_actions, :hide, :boolean, :default => false
    add_index :account_actions, :hide
    
  end



  def self.down
    remove_column :account_actions, :hide
  end
end
