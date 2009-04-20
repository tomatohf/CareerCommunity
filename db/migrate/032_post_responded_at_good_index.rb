class PostRespondedAtGoodIndex < ActiveRecord::Migration
  def self.up
    
    add_index :activities, :online
    
    add_index :group_posts, :responded_at
    add_index :activity_posts, :responded_at
    
    add_index :group_posts, :good
    add_index :activity_posts, :good
    
  end

  def self.down
    
    remove_index :activity_posts, :good
    remove_index :group_posts, :good
    
    remove_index :activity_posts, :responded_at
    remove_index :group_posts, :responded_at
    
    remove_index :activities, :online
    
  end
end

