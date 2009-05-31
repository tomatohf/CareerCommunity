class ImproveActivitiesIndex < ActiveRecord::Migration
  def self.up
    
    remove_index :activities, :online
    
    remove_index :activities, :created_at
    remove_index :activities, :creator_id
    remove_index :activities, :master_id
    remove_index :activities, :begin_at
    remove_index :activities, :end_at
    remove_index :activities, :application_deadline
    remove_index :activities, :cost
    remove_index :activities, :member_limit
    remove_index :activities, :in_group
    
    add_index :activities, [:cancelled, :created_at]
    add_index :activities, [:cancelled, :begin_at]
    add_index :activities, [:cancelled, :creator_id, :created_at]
    add_index :activities, [:cancelled, :in_group, :begin_at]
    
  end

  def self.down
    
    remove_index :activities, [:cancelled, :in_group, :begin_at]
    remove_index :activities, [:cancelled, :creator_id, :created_at]
    remove_index :activities, [:cancelled, :begin_at]
    remove_index :activities, [:cancelled, :created_at]
    
    add_index :activities, :created_at
    add_index :activities, :creator_id
    add_index :activities, :master_id
    add_index :activities, :begin_at
    add_index :activities, :end_at
    add_index :activities, :application_deadline
    add_index :activities, :cost
    add_index :activities, :member_limit
    add_index :activities, :in_group
    
    add_index :activities, :online
    
  end
end

