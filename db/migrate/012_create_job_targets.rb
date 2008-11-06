class CreateJobTargets < ActiveRecord::Migration
  def self.up
    
    # companies table
    create_table :companies, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :name, :string
      # TODO - industry info ...
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :companies, :created_at
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO companies (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM companies WHERE id = 1000")
    
    # job_positions table
    create_table :job_positions, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :name, :string
      # TODO - category info ...
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :job_positions, :created_at
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO job_positions (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM job_positions WHERE id = 1000")
    
    # job_targets table
    create_table :job_targets, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer
      t.column :company_id, :integer
      t.column :job_position_id, :integer
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :job_targets, :created_at
    add_index :job_targets, :updated_at
    add_index :job_targets, :account_id
    add_index :job_targets, :company_id
    add_index :job_targets, :job_position_id
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO job_targets (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM job_targets WHERE id = 1000")
    
    # job_processes table
    create_table :job_processes, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :name, :string
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :job_processes, :created_at
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO job_processes (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM job_processes WHERE id = 1000")
    
  end

  def self.down
    drop_table :job_processes
    drop_table :job_targets
    drop_table :job_positions
    drop_table :companies
  end
end
