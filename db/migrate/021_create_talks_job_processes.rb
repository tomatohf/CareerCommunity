class CreateTalksJobProcesses < ActiveRecord::Migration
  def self.up
    
    # talks_job_processes table
    create_table :talks_job_processes, :id => false, :force => true do |t|
      t.column :talk_id, :integer
      t.column :job_process_id, :integer
    end
    add_index :talks_job_processes, :talk_id
    add_index :talks_job_processes, :job_process_id
    
  end

  def self.down
    drop_table :talks_job_processes
  end
end
