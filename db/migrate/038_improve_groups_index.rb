class ImproveGroupsIndex < ActiveRecord::Migration
  def self.up
    
    # remove_index :groups, :created_at
    # remove_index :groups, :creator_id
    remove_index :groups, :master_id
    
    
    remove_index :group_members, :created_at
    remove_index :group_members, :updated_at
    remove_index :group_members, :join_at
    remove_index :group_members, :group_id
    remove_index :group_members, :account_id
    remove_index :group_members, :accepted
    remove_index :group_members, :approved
    remove_index :group_members, :admin
    remove_index :group_members, [:group_id, :account_id]
    
    add_index :group_members, [:account_id, :accepted, :approved, :admin, :join_at], 
              :name => :index_group_members_on_account_accepted_approved_admin_join
    add_index :group_members, [:group_id, :accepted, :approved, :join_at], 
              :name => :index_group_members_on_group_accepted_approved_join
    add_index :group_members, [:group_id, :accepted, :approved, :admin, :join_at], 
              :name => :index_group_members_on_group_accepted_approved_admin_join
    add_index :group_members, [:group_id, :account_id, :accepted, :approved, :admin], 
              :name => :index_group_members_on_group_account_accepted_approved_admin
    
    
    # remove_index :group_images, :group_id
    remove_index :group_images, :photo_id
    
    
    remove_index :group_posts, :created_at
    remove_index :group_posts, :group_id
    remove_index :group_posts, :account_id
    remove_index :group_posts, :top
    
    add_index :group_posts, [:responded_at, :created_at]
    add_index :group_posts, [:group_id, :responded_at, :created_at]
    add_index :group_posts, [:group_id, :top, :responded_at, :created_at], 
              :name => :index_group_posts_on_group_top_responded_created
    add_index :group_posts, [:group_id, :good, :top, :responded_at, :created_at], 
              :name => :index_group_posts_on_group_good_top_responded_created
    add_index :group_posts, [:account_id, :responded_at, :created_at]
    
    
    remove_index :group_post_comments, :group_post_id
    remove_index :group_post_comments, :account_id
    remove_index :group_post_comments, :created_at
    
    add_index :group_post_comments, [:group_post_id, :created_at]
    add_index :group_post_comments, [:account_id, :created_at]
    
    
    remove_index :group_photos, :group_id
    remove_index :group_photos, :photo_id
    remove_index :group_photos, :account_id
    
    add_index :group_photos, :created_at
    add_index :group_photos, [:group_id, :created_at]
    
    
    remove_index :group_post_attachments, :created_at
    # remove_index :group_post_attachments, :group_post_id
    remove_index :group_post_attachments, :account_id
    
    
    remove_index :group_pictures, :created_at
    remove_index :group_pictures, :group_id
    remove_index :group_pictures, :account_id
    remove_index :group_pictures, :top
    remove_index :group_pictures, :good
    remove_index :group_pictures, :responded_at
    
    add_index :group_pictures, [:responded_at, :created_at]
    add_index :group_pictures, [:group_id, :responded_at, :created_at]
    add_index :group_pictures, [:group_id, :good, :responded_at, :created_at], 
              :name => :index_group_pictures_on_group_good_responded_created
    
    
    remove_index :group_picture_comments, :group_picture_id
    remove_index :group_picture_comments, :account_id
    remove_index :group_picture_comments, :created_at
    
    add_index :group_picture_comments, [:group_picture_id, :created_at]
    
  end

  def self.down
    
    remove_index :group_picture_comments, [:group_picture_id, :created_at]
    
    add_index :group_picture_comments, :group_picture_id
    add_index :group_picture_comments, :account_id
    add_index :group_picture_comments, :created_at
    
    
    remove_index :group_pictures, :name => :index_group_pictures_on_group_good_responded_created
    remove_index :group_pictures, [:group_id, :responded_at, :created_at]
    remove_index :group_pictures, [:responded_at, :created_at]
    
    add_index :group_pictures, :created_at
    add_index :group_pictures, :group_id
    add_index :group_pictures, :account_id
    add_index :group_pictures, :top
    add_index :group_pictures, :good
    add_index :group_pictures, :responded_at
    
    
    add_index :group_post_attachments, :created_at
    # add_index :group_post_attachments, :group_post_id
    add_index :group_post_attachments, :account_id
    
    
    remove_index :group_photos, [:group_id, :created_at]
    remove_index :group_photos, :created_at
    
    add_index :group_photos, :group_id
    add_index :group_photos, :photo_id
    add_index :group_photos, :account_id
    
    
    remove_index :group_post_comments, [:account_id, :created_at]
    remove_index :group_post_comments, [:group_post_id, :created_at]
    
    add_index :group_post_comments, :group_post_id
    add_index :group_post_comments, :account_id
    add_index :group_post_comments, :created_at
    
    
    remove_index :group_posts, [:account_id, :responded_at, :created_at]
    remove_index :group_posts, :name => :index_group_posts_on_group_good_top_responded_created
    remove_index :group_posts, :name => :index_group_posts_on_group_top_responded_created
    remove_index :group_posts, [:group_id, :responded_at, :created_at]
    remove_index :group_posts, [:responded_at, :created_at]
    
    add_index :group_posts, :created_at
    add_index :group_posts, :group_id
    add_index :group_posts, :account_id
    add_index :group_posts, :top
    
    
    # add_index :group_images, :group_id
    add_index :group_images, :photo_id
    
    
    remove_index :group_members, :name => :index_group_members_on_group_account_accepted_approved_admin
    remove_index :group_members, :name => :index_group_members_on_group_accepted_approved_admin_join
    remove_index :group_members, :name => :index_group_members_on_group_accepted_approved_join
    remove_index :group_members, :name => :index_group_members_on_account_accepted_approved_admin_join
    
    add_index :group_members, :created_at
    add_index :group_members, :updated_at
    add_index :group_members, :join_at
    add_index :group_members, :group_id
    add_index :group_members, :account_id
    add_index :group_members, :accepted
    add_index :group_members, :approved
    add_index :group_members, :admin
    add_index :group_members, [:group_id, :account_id]
    
    
    # add_index :groups, :created_at
    # add_index :groups, :creator_id
    add_index :groups, :master_id
    
  end
end

