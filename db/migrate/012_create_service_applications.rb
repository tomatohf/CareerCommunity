class CreateServiceApplications < ActiveRecord::Migration
  def self.up
    
    # service_applications table
    create_table :service_applications, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer, :default => 0
      # set account_id to 0 if it's not registered or logined
      
      t.column :service_id, :integer
      t.column :closed, :boolean, :default => false
      
      t.column :real_name, :string
      t.column :school, :string
      t.column :major, :string
      t.column :grade, :string
      
      t.column :mobile, :string
      t.column :email, :string
      
      t.column :requester_ip, :string, :limit => 40
      # to be compatible with IPv6, IP v6 will have 39 chars
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :service_applications, :created_at
    add_index :service_applications, :account_id
    add_index :service_applications, :service_id
    add_index :service_applications, :closed
    add_index :service_applications, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO service_applications (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM service_applications WHERE id = 1000")
    
  end

  def self.down
    drop_table :service_applications
  end
end
