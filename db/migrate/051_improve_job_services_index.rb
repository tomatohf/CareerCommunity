class ImproveJobServicesIndex < ActiveRecord::Migration
  def self.up
    
    remove_index :job_service_categories, :created_at
    remove_index :job_service_categories, :updated_at
    
    
    remove_index :job_services, :created_at
    remove_index :job_services, :updated_at
    remove_index :job_services, :creator_id
    remove_index :job_services, :updater_id
    # remove_index :job_services, :category_id
    remove_index :job_services, :cost
    
    
    remove_index :job_service_evaluations, :created_at
    remove_index :job_service_evaluations, :updated_at
    remove_index :job_service_evaluations, :job_service_id
    remove_index :job_service_evaluations, :account_id
    remove_index :job_service_evaluations, :point
    
    add_index :job_service_evaluations, [:job_service_id, :updated_at]
    add_index :job_service_evaluations, [:job_service_id, :account_id]
    add_index :job_service_evaluations, [:job_service_id, :point]
    
  end

  def self.down
    
    remove_index :job_service_evaluations, [:job_service_id, :point]
    remove_index :job_service_evaluations, [:job_service_id, :account_id]
    remove_index :job_service_evaluations, [:job_service_id, :updated_at]
    
    add_index :job_service_evaluations, :created_at
    add_index :job_service_evaluations, :updated_at
    add_index :job_service_evaluations, :job_service_id
    add_index :job_service_evaluations, :account_id
    add_index :job_service_evaluations, :point
    
    
    add_index :job_services, :created_at
    add_index :job_services, :updated_at
    add_index :job_services, :creator_id
    add_index :job_services, :updater_id
    # add_index :job_services, :category_id
    add_index :job_services, :cost
    
    
    add_index :job_service_categories, :created_at
    add_index :job_service_categories, :updated_at
    
  end
end

