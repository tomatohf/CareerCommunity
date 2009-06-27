class AddPostsRespondedBy < ActiveRecord::Migration
  def self.up
    
    add_column :group_posts, :responded_by, :integer
    add_column :activity_posts, :responded_by, :integer
    add_column :goal_posts, :responded_by, :integer
    
  end

  def self.down
    
    remove_column :goal_posts, :responded_by
    remove_column :activity_posts, :responded_by
    remove_column :group_posts, :responded_by
    
  end
end

