class AddRoleTypeIndex < ActiveRecord::Migration
  def self.up
    
    add_index :role_profiles, [:role_type, :updated_at]
    
  end

  def self.down
    remove_index :role_profiles, [:role_type, :updated_at]
  end
end

