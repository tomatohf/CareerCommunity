class AddGoalPostFeedIndex < ActiveRecord::Migration
  def self.up
    
    add_index :goal_posts, [:goal_id, :responded_at]
    
  end

  def self.down
    
    remove_index :goal_posts, [:goal_id, :responded_at]
    
  end
end

