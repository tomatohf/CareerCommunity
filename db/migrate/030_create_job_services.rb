class CreateJobServices < ActiveRecord::Migration
  def self.up
    
    # job_service_categories table
    create_table :job_service_categories, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :name, :string
      t.column :desc, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :job_service_categories, :created_at
    add_index :job_service_categories, :updated_at
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO job_service_categories (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM job_service_categories WHERE id = 1000")
    
    # job_services table
    create_table :job_services, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :updater_id, :integer
      t.column :creator_id, :integer
      
      t.column :category_id, :integer
            
      t.column :name, :string
      
      t.column :url, :string
      t.column :place, :string
      
      t.column :desc, :string, :limit => 1000
      
      t.column :phone, :string
      
      t.column :scope, :string
      
      t.column :cost, :decimal
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :job_services, :created_at
    add_index :job_services, :updated_at
    add_index :job_services, :creator_id
    add_index :job_services, :updater_id
    add_index :job_services, :category_id
    add_index :job_services, :cost
    add_index :job_services, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO job_services (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM job_services WHERE id = 1000")
    
    # job_service_evaluations table
    create_table :job_service_evaluations, :force => true do |t|
      t.column :job_service_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer
      
      t.column :point, :integer, :limit => 1
      t.column :content, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :job_service_evaluations, :created_at
    add_index :job_service_evaluations, :updated_at
    add_index :job_service_evaluations, :job_service_id
    add_index :job_service_evaluations, :account_id
    add_index :job_service_evaluations, :point
    add_index :job_service_evaluations, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO job_service_evaluations (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM job_service_evaluations WHERE id = 1000")
    
  end

  def self.down
    drop_table :job_service_evaluations
    drop_table :job_services
    drop_table :job_service_categories
  end
end
