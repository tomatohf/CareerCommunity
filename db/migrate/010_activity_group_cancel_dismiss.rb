class ActivityGroupCancelDismiss < ActiveRecord::Migration
  def self.up

    # to make an activity can be cancelled
    add_column :activities, :cancelled, :boolean, :default => false
    
    # to make a group can be dismissed
    add_column :groups, :dismissed, :boolean, :default => false
    
  end

  def self.down
    remove_column :groups, :dismissed
    remove_column :activities, :cancelled
  end
end
