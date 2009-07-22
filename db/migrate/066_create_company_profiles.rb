class CreateCompanyProfiles < ActiveRecord::Migration
  def self.up
    
    # company_profiles table
    create_table :company_profiles, :force => true do |t|
      t.column :updated_at, :datetime
      t.column :updater_id, :integer
      
      t.column :company_id, :integer
      
      t.column :photo_id, :integer
      t.column :info, :text
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :company_profiles, :company_id
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO company_profiles (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM company_profiles WHERE id = 1000")
    
  end

  def self.down
    drop_table :company_profiles
  end
end

