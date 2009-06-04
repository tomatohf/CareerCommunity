class ImproveJobTargetsIndex < ActiveRecord::Migration
  def self.up
    
    remove_index :companies, :created_at
    
    add_index :companies, [:account_id, :created_at]
    add_index :companies, [:name, :account_id], :unique => true
    
    
    remove_index :job_positions, :created_at
    
    add_index :job_positions, [:account_id, :created_at]
    add_index :job_positions, [:name, :account_id], :unique => true
    
    
    remove_index :industries, :created_at
    remove_index :industries, :account_id
    
    add_index :industries, [:account_id, :created_at]
    
    
    remove_index :companies_industries, :company_id
    remove_index :companies_industries, :industry_id
    
    add_index :companies_industries, [:company_id, :industry_id], :unique => true
    add_index :companies_industries, [:industry_id, :company_id], :unique => true
    
    
    remove_index :job_targets, :created_at
    remove_index :job_targets, :updated_at
    remove_index :job_targets, :account_id
    # remove_index :job_targets, :company_id
    # remove_index :job_targets, :job_position_id
    remove_index :job_targets, :current_job_step_id
    remove_index :job_targets, :closed
    
    add_index :job_targets, [:closed, :account_id, :created_at]
    
    
    remove_index :job_processes, :created_at
    
    add_index :job_processes, [:account_id, :created_at]
    add_index :job_processes, [:name, :account_id], :unique => true
    
    
    remove_index :job_statuses, :created_at
    remove_index :job_statuses, :account_id
    remove_index :job_statuses, :color
    
    add_index :job_statuses, [:account_id, :created_at]
    
    
    remove_index :job_steps, :created_at
    remove_index :job_steps, :job_target_id
    remove_index :job_steps, :account_id
    remove_index :job_steps, :job_process_id
    remove_index :job_steps, :job_status_id
    
    add_index :job_steps, :remind_at
    add_index :job_steps, [:account_id, :end_at]
    
  end

  def self.down
    
    remove_index :job_steps, [:account_id, :end_at]
    remove_index :job_steps, :remind_at
    
    add_index :job_steps, :created_at
    add_index :job_steps, :job_target_id
    add_index :job_steps, :account_id
    add_index :job_steps, :job_process_id
    add_index :job_steps, :job_status_id
    
    
    remove_index :job_statuses, [:account_id, :created_at]
    
    add_index :job_statuses, :created_at
    add_index :job_statuses, :account_id
    add_index :job_statuses, :color
    
    
    remove_index :job_processes, [:name, :account_id], :unique => true
    remove_index :job_processes, [:account_id, :created_at]
    
    add_index :job_processes, :created_at
    
    
    remove_index :job_targets, [:closed, :account_id, :created_at]
    
    add_index :job_targets, :created_at
    add_index :job_targets, :updated_at
    add_index :job_targets, :account_id
    # add_index :job_targets, :company_id
    # add_index :job_targets, :job_position_id
    add_index :job_targets, :current_job_step_id
    add_index :job_targets, :closed
    
    
    remove_index :companies_industries, [:industry_id, :company_id]
    remove_index :companies_industries, [:company_id, :industry_id]
    
    add_index :companies_industries, :company_id
    add_index :companies_industries, :industry_id
    
    
    remove_index :industries, [:account_id, :created_at]
    
    add_index :industries, :created_at
    add_index :industries, :account_id
    
    
    remove_index :job_positions, [:name, :account_id]
    remove_index :job_positions, [:account_id, :created_at]
    
    add_index :job_positions, :created_at
    
    
    remove_index :companies, [:name, :account_id]
    remove_index :companies, [:account_id, :created_at]
    
    add_index :companies, :created_at
    
  end
end

