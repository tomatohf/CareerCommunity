class CreateJobTargetNotes < ActiveRecord::Migration
  def self.up
    
    # job_target_notes table
    create_table :job_target_notes, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime

      t.column :content, :text
      
      t.column :job_target_id, :integer
      
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
      
    end
    add_index :job_target_notes, :job_target_id
    add_index :job_target_notes, :updated_at
    add_index :job_target_notes, :created_at
    add_index :job_target_notes, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO job_target_notes (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM job_target_notes WHERE id = 1000")
    
  end

  def self.down
    drop_table :job_target_notes
  end
end
