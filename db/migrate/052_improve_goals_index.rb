class ImproveGoalsIndex < ActiveRecord::Migration
  def self.up
    
    remove_index :goals, :created_at
    remove_index :goals, :account_id
    # remove_index :goals, :name
    remove_index :goals, :deprecated
    
    
    remove_index :goal_follows, :created_at
    remove_index :goal_follows, :updated_at
    remove_index :goal_follows, :account_id
    remove_index :goal_follows, :goal_id
    remove_index :goal_follows, :private
    remove_index :goal_follows, :status_id
    remove_index :goal_follows, :status_updated_at
    remove_index :goal_follows, :type_id
    
    add_index :goal_follows, [:account_id, :created_at]
    add_index :goal_follows, [:account_id, :status_id, :created_at]
    add_index :goal_follows, [:goal_id, :account_id]
    add_index :goal_follows, [:goal_id, :status_id, :created_at]
    
    
    remove_index :goal_tracks, :created_at
    remove_index :goal_tracks, :updated_at
    remove_index :goal_tracks, :goal_follow_id
    remove_index :goal_tracks, :goal_id
    
    add_index :goal_tracks, [:goal_id, :created_at]
    add_index :goal_tracks, [:goal_follow_id, :created_at]
    
    
    remove_index :goal_track_comments, :created_at
    remove_index :goal_track_comments, :updated_at
    remove_index :goal_track_comments, :goal_track_id
    remove_index :goal_track_comments, :account_id
    
    add_index :goal_track_comments, [:goal_track_id, :created_at]
    
    
    remove_index :goal_posts, :created_at
    remove_index :goal_posts, :goal_id
    remove_index :goal_posts, :account_id
    remove_index :goal_posts, :top
    # remove_index :goal_posts, :responded_at
    remove_index :goal_posts, :good
    
    add_index :goal_posts, [:goal_id, :top, :responded_at]
    add_index :goal_posts, [:goal_id, :good, :top, :responded_at]
    add_index :goal_posts, [:account_id, :responded_at]
    
    
    remove_index :goal_post_comments, :goal_post_id
    remove_index :goal_post_comments, :account_id
    remove_index :goal_post_comments, :created_at
    
    add_index :goal_post_comments, [:goal_post_id, :created_at]
    
    
    remove_index :goal_post_attachments, :created_at
    # remove_index :goal_post_attachments, :goal_post_id
    remove_index :goal_post_attachments, :account_id
    
  end

  def self.down
    
    add_index :goal_post_attachments, :created_at
    # add_index :goal_post_attachments, :goal_post_id
    add_index :goal_post_attachments, :account_id
    
    
    remove_index :goal_post_comments, [:goal_post_id, :created_at]
    
    add_index :goal_post_comments, :goal_post_id
    add_index :goal_post_comments, :account_id
    add_index :goal_post_comments, :created_at
    
    
    remove_index :goal_posts, [:account_id, :responded_at]
    remove_index :goal_posts, [:goal_id, :good, :top, :responded_at]
    remove_index :goal_posts, [:goal_id, :top, :responded_at]
    
    add_index :goal_posts, :created_at
    add_index :goal_posts, :goal_id
    add_index :goal_posts, :account_id
    add_index :goal_posts, :top
    # add_index :goal_posts, :responded_at
    add_index :goal_posts, :good
    
    
    remove_index :goal_track_comments, [:goal_track_id, :created_at]
    
    add_index :goal_track_comments, :created_at
    add_index :goal_track_comments, :updated_at
    add_index :goal_track_comments, :goal_track_id
    add_index :goal_track_comments, :account_id
    
    
    remove_index :goal_tracks, [:goal_follow_id, :created_at]
    remove_index :goal_tracks, [:goal_id, :created_at]
    
    add_index :goal_tracks, :created_at
    add_index :goal_tracks, :updated_at
    add_index :goal_tracks, :goal_follow_id
    add_index :goal_tracks, :goal_id
    
    
    remove_index :goal_follows, [:goal_id, :status_id, :created_at]
    remove_index :goal_follows, [:goal_id, :account_id]
    remove_index :goal_follows, [:account_id, :status_id, :created_at]
    remove_index :goal_follows, [:account_id, :created_at]
    
    add_index :goal_follows, :created_at
    add_index :goal_follows, :updated_at
    add_index :goal_follows, :account_id
    add_index :goal_follows, :goal_id
    add_index :goal_follows, :private
    add_index :goal_follows, :status_id
    add_index :goal_follows, :status_updated_at
    add_index :goal_follows, :type_id
    
    
    add_index :goals, :created_at
    add_index :goals, :account_id
    # add_index :goals, :name
    add_index :goals, :deprecated
    
  end
end

