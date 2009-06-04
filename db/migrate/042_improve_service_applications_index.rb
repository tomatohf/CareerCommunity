class ImproveServiceApplicationsIndex < ActiveRecord::Migration
  def self.up
    
    remove_index :service_applications, :created_at
    # remove_index :service_applications, :account_id
    remove_index :service_applications, :service_id
    remove_index :service_applications, :closed
    
    add_index :service_applications, [:closed, :created_at]
    
  end

  def self.down
    
    remove_index :service_applications, [:closed, :created_at]
    
    add_index :service_applications, :created_at
    # add_index :service_applications, :account_id
    add_index :service_applications, :service_id
    add_index :service_applications, :closed
    
  end
end

