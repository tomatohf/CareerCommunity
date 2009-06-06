class ImproveJobTargetNotesIndex < ActiveRecord::Migration
  def self.up
    
    # remove_index :job_target_notes, :job_target_id
    remove_index :job_target_notes, :updated_at
    remove_index :job_target_notes, :created_at
    
  end

  def self.down
    
    # add_index :job_target_notes, :job_target_id
    add_index :job_target_notes, :updated_at
    add_index :job_target_notes, :created_at
    
  end
end

