class ImproveJobInfosIndex < ActiveRecord::Migration
  def self.up
    
    remove_index :job_infos, :created_at
    remove_index :job_infos, :updated_at
    remove_index :job_infos, :creator_id
    remove_index :job_infos, :updater_id
    
    
    remove_index :job_infos_industries, :job_info_id
    remove_index :job_infos_industries, :industry_id
    
    add_index :job_infos_industries, [:job_info_id, :industry_id], :unique => true
    
    
    remove_index :job_infos_companies, :job_info_id
    remove_index :job_infos_companies, :company_id
    
    add_index :job_infos_companies, [:job_info_id, :company_id], :unique => true
    
    
    remove_index :job_infos_job_positions, :job_info_id
    remove_index :job_infos_job_positions, :job_position_id
    
    add_index :job_infos_job_positions, [:job_info_id, :job_position_id], :unique => true
    
    
    remove_index :job_infos_job_processes, :job_info_id
    remove_index :job_infos_job_processes, :job_process_id
    
    add_index :job_infos_job_processes, [:job_info_id, :job_process_id], :unique => true
    
    
    remove_index :job_info_categories, :created_at
    remove_index :job_info_categories, :updated_at
    remove_index :job_info_categories, :parent_category_id
    
    
    remove_index :job_infos_job_info_categories, :job_info_id
    remove_index :job_infos_job_info_categories, :job_info_category_id
    
    add_index :job_infos_job_info_categories, [:job_info_id, :job_info_category_id], 
              :name => :index_job_infos_job_info_categories_on_info_category, 
              :unique => true
              
              
    remove_index :industry_infos, :created_at
    remove_index :industry_infos, :updated_at
    remove_index :industry_infos, :creator_id
    remove_index :industry_infos, :updater_id
    # remove_index :industry_infos, :industry_id
    
    
    remove_index :company_infos, :created_at
    remove_index :company_infos, :updated_at
    remove_index :company_infos, :creator_id
    remove_index :company_infos, :updater_id
    # remove_index :company_infos, :company_id
    
    
    remove_index :job_position_infos, :created_at
    remove_index :job_position_infos, :updated_at
    remove_index :job_position_infos, :creator_id
    remove_index :job_position_infos, :updater_id
    # remove_index :job_position_infos, :job_position_id
    
    
    remove_index :job_position_infos_industries, :job_position_info_id
    remove_index :job_position_infos_industries, :industry_id
    
    add_index :job_position_infos_industries, [:job_position_info_id, :industry_id], 
              :name => :index_job_position_infos_industries_on_info_industry, 
              :unique => true
    
    
    remove_index :job_position_infos_companies, :job_position_info_id
    remove_index :job_position_infos_companies, :company_id
    
    add_index :job_position_infos_companies, [:job_position_info_id, :company_id], 
              :name => :index_job_position_infos_industries_on_info_company, 
              :unique => true
    
  end

  def self.down
    
    remove_index :job_position_infos_companies, 
                :name => :index_job_position_infos_industries_on_info_company
    
    add_index :job_position_infos_companies, :job_position_info_id
    add_index :job_position_infos_companies, :company_id
    
    
    remove_index :job_position_infos_industries, 
                :name => :index_job_position_infos_industries_on_info_industry
    
    add_index :job_position_infos_industries, :job_position_info_id
    add_index :job_position_infos_industries, :industry_id
    
    
    add_index :job_position_infos, :created_at
    add_index :job_position_infos, :updated_at
    add_index :job_position_infos, :creator_id
    add_index :job_position_infos, :updater_id
    # add_index :job_position_infos, :job_position_id
    
    
    add_index :company_infos, :created_at
    add_index :company_infos, :updated_at
    add_index :company_infos, :creator_id
    add_index :company_infos, :updater_id
    # add_index :company_infos, :company_id
    
    
    add_index :industry_infos, :created_at
    add_index :industry_infos, :updated_at
    add_index :industry_infos, :creator_id
    add_index :industry_infos, :updater_id
    # add_index :industry_infos, :industry_id
    
    
    remove_index :job_infos_job_info_categories, 
                :name => :index_job_infos_job_info_categories_on_info_category
    
    add_index :job_infos_job_info_categories, :job_info_id
    add_index :job_infos_job_info_categories, :job_info_category_id
    
    
    add_index :job_info_categories, :created_at
    add_index :job_info_categories, :updated_at
    add_index :job_info_categories, :parent_category_id
    
    
    remove_index :job_infos_job_processes, [:job_info_id, :job_process_id]
    
    add_index :job_infos_job_processes, :job_info_id
    add_index :job_infos_job_processes, :job_process_id
    
    
    remove_index :job_infos_job_positions, [:job_info_id, :job_position_id]
    
    add_index :job_infos_job_positions, :job_info_id
    add_index :job_infos_job_positions, :job_position_id
    
    
    remove_index :job_infos_companies, [:job_info_id, :company_id]
    
    add_index :job_infos_companies, :job_info_id
    add_index :job_infos_companies, :company_id
    
    
    remove_index :job_infos_industries, [:job_info_id, :industry_id]
    
    add_index :job_infos_industries, :job_info_id
    add_index :job_infos_industries, :industry_id
    
    
    add_index :job_infos, :created_at
    add_index :job_infos, :updated_at
    add_index :job_infos, :creator_id
    add_index :job_infos, :updater_id
    
  end
end

