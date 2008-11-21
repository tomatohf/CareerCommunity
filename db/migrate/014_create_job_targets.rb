class CreateJobTargets < ActiveRecord::Migration
  def self.up
    
    # companies table
    create_table :companies, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer, :default => 0
      # set account_id to 0, meaning it is added by system
      
      t.column :name, :string
      # TODO - industry info ...
      
      t.column :desc, :string, :limit => 1000
      
      
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
      
      t.column :account_id, :integer, :default => 0
      # set account_id to 0, meaning it is added by system
      
      t.column :name, :string
      # TODO - category info ...
      
      t.column :desc, :string, :limit => 1000
      
      
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
      
      t.column :current_job_step_id, :integer
      
      t.column :closed, :boolean, :default => false
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :job_targets, :created_at
    add_index :job_targets, :updated_at
    add_index :job_targets, :account_id
    add_index :job_targets, :company_id
    add_index :job_targets, :job_position_id
    add_index :job_targets, :current_job_step_id
    add_index :job_targets, :closed
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO job_targets (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM job_targets WHERE id = 1000")
    
    # job_processes table
    create_table :job_processes, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer, :default => 0
      # set account_id to 0, meaning it is added by system
      
      t.column :name, :string
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :job_processes, :created_at
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO job_processes (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM job_processes WHERE id = 1000")
    [
      "求职信",
      "网申",
      "简历",
      "面试",
      "实习",
      "试用期",
      "转正后"
    ].each do |p|
      process = JobProcess.new(:name => p, :account_id => 0)
      process.save!
    end
    
    # job_statuses table
    create_table :job_statuses, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer, :default => 0
      # set account_id to 0, meaning it is added by system
      
      t.column :name, :string
      t.column :color, :string, :limit => 7
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :job_statuses, :created_at
    add_index :job_statuses, :account_id
    add_index :job_statuses, :color
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO job_statuses (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM job_statuses WHERE id = 1000")
    [
      ["尚未进行", "FFFFFF"],
      ["正在进行", "87CEEB"],
      ["顺利通过", "7CFC00"],
      ["不幸失败", "FF0000"],
      ["霸王参与", "2F4F4F"],
      ["等待结果", "00FFFF"]
    ].each do |s|
      status = JobStatus.new(:name => s[0], :color => s[1], :account_id => 0)
      status.save!
    end
    
    # job_steps table
    create_table :job_steps, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :job_target_id, :integer

      t.column :account_id, :integer
      t.column :job_process_id, :integer

      t.column :name, :string
      t.column :job_status_id, :integer
      
      t.column :begin_at, :datetime
      t.column :end_at, :datetime


      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :job_steps, :created_at
    add_index :job_steps, :job_target_id
    add_index :job_steps, :account_id
    add_index :job_steps, :job_process_id
    add_index :job_steps, :job_status_id
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO job_steps (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM job_steps WHERE id = 1000")
    
  end
  


  def self.down
    drop_table :job_steps
    drop_table :job_statuses
    drop_table :job_processes
    drop_table :job_targets
    drop_table :job_positions
    drop_table :companies
  end
end
