class JobServiceCategoriesDeltaIndex < ActiveRecord::Migration
  def self.up
    
    add_index :job_service_categories, :delta
    
  end

  def self.down
    
    remove_index :job_service_categories, :delta
    
  end
end

