class JobStepRemindAt < ActiveRecord::Migration
  def self.up

    add_column :job_steps, :remind_at, :datetime
    
  end

  def self.down
    remove_column :job_steps, :remind_at
  end
end
