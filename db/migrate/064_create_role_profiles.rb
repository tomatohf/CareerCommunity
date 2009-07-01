class CreateRoleProfiles < ActiveRecord::Migration
  def self.up
    
    # role_profiles table
    create_table :role_profiles, :force => true do |t|
      t.column :account_id, :integer
      t.column :updated_at, :datetime
      
      t.column :role_type, :integer, :limit => 2
      
      t.column :desc, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :role_profiles, :account_id
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO role_profiles (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM role_profiles WHERE id = 1000")
    
  end

  def self.down
    drop_table :role_profiles
  end
end
