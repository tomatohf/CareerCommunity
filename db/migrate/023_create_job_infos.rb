class CreateJobInfos < ActiveRecord::Migration
  def self.up
    
    # job_infos table
    create_table :job_infos, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :creator_id, :integer
      t.column :updater_id, :integer
      
      t.column :title, :string
      t.column :content, :text
      
      t.column :general, :boolean, :default => false
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :job_infos, :created_at
    add_index :job_infos, :updated_at
    add_index :job_infos, :creator_id
    add_index :job_infos, :updater_id
    add_index :job_infos, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO job_infos (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM job_infos WHERE id = 1000")
    
    # job_infos_industries table
    create_table :job_infos_industries, :id => false, :force => true do |t|
      t.column :job_info_id, :integer
      t.column :industry_id, :integer
    end
    add_index :job_infos_industries, :job_info_id
    add_index :job_infos_industries, :industry_id
    
    # job_infos_companies table
    create_table :job_infos_companies, :id => false, :force => true do |t|
      t.column :job_info_id, :integer
      t.column :company_id, :integer
    end
    add_index :job_infos_companies, :job_info_id
    add_index :job_infos_companies, :company_id
    
    # job_infos_job_positions table
    create_table :job_infos_job_positions, :id => false, :force => true do |t|
      t.column :job_info_id, :integer
      t.column :job_position_id, :integer
    end
    add_index :job_infos_job_positions, :job_info_id
    add_index :job_infos_job_positions, :job_position_id
    
    # job_infos_job_processes table
    create_table :job_infos_job_processes, :id => false, :force => true do |t|
      t.column :job_info_id, :integer
      t.column :job_process_id, :integer
    end
    add_index :job_infos_job_processes, :job_info_id
    add_index :job_infos_job_processes, :job_process_id
    
    # job_info_categories table
    create_table :job_info_categories, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :creator_id, :integer
      t.column :updater_id, :integer
      
      t.column :name, :string
      t.column :desc, :string, :limit => 1000
      
      t.column :parent_category_id, :integer
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :job_info_categories, :created_at
    add_index :job_info_categories, :updated_at
    add_index :job_info_categories, :creator_id
    add_index :job_info_categories, :updater_id
    add_index :job_info_categories, :parent_category_id
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO job_info_categories (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM job_info_categories WHERE id = 1000")
    
    # job_infos_job_info_categories table
    create_table :job_infos_job_info_categories, :id => false, :force => true do |t|
      t.column :job_info_id, :integer
      t.column :job_info_category_id, :integer
    end
    add_index :job_infos_job_info_categories, :job_info_id
    add_index :job_infos_job_info_categories, :job_info_category_id
    
    
    # industry_infos table
    create_table :industry_infos, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :creator_id, :integer
      t.column :updater_id, :integer
      
      t.column :title, :string
      t.column :content, :text
      
      t.column :industry_id, :integer
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :industry_infos, :created_at
    add_index :industry_infos, :updated_at
    add_index :industry_infos, :creator_id
    add_index :industry_infos, :updater_id
    add_index :industry_infos, :industry_id
    add_index :industry_infos, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO industry_infos (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM industry_infos WHERE id = 1000")
    
    # company_infos table
    create_table :company_infos, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :creator_id, :integer
      t.column :updater_id, :integer
      
      t.column :title, :string
      t.column :content, :text
      
      t.column :company_id, :integer
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :company_infos, :created_at
    add_index :company_infos, :updated_at
    add_index :company_infos, :creator_id
    add_index :company_infos, :updater_id
    add_index :company_infos, :company_id
    add_index :company_infos, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO company_infos (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM company_infos WHERE id = 1000")
    
    # job_position_infos table
    create_table :job_position_infos, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :creator_id, :integer
      t.column :updater_id, :integer
      
      t.column :title, :string
      t.column :content, :text
      
      t.column :job_position_id, :integer
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :job_position_infos, :created_at
    add_index :job_position_infos, :updated_at
    add_index :job_position_infos, :creator_id
    add_index :job_position_infos, :updater_id
    add_index :job_position_infos, :job_position_id
    add_index :job_position_infos, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO job_position_infos (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM job_position_infos WHERE id = 1000")
    
    # job_position_infos_industries table
    create_table :job_position_infos_industries, :id => false, :force => true do |t|
      t.column :job_position_info_id, :integer
      t.column :industry_id, :integer
    end
    add_index :job_position_infos_industries, :job_position_info_id
    add_index :job_position_infos_industries, :industry_id
    
    # job_position_infos_companies table
    create_table :job_position_infos_companies, :id => false, :force => true do |t|
      t.column :job_position_info_id, :integer
      t.column :company_id, :integer
    end
    add_index :job_position_infos_companies, :job_position_info_id
    add_index :job_position_infos_companies, :company_id
    
  end

  def self.down
    drop_table :job_position_infos_companies
    drop_table :job_position_infos_industries
    drop_table :job_position_infos
    drop_table :company_infos
    drop_table :industry_infos
    drop_table :job_infos_job_info_categories
    drop_table :job_info_categories
    drop_table :job_infos_job_processes
    drop_table :job_infos_job_positions
    drop_table :job_infos_companies
    drop_table :job_infos_industries
    drop_table :job_infos
  end
end
