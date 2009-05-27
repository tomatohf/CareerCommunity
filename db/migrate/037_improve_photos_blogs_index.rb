class ImprovePhotosBlogsIndex < ActiveRecord::Migration
  def self.up
    
    remove_index :albums, :account_id
    remove_index :albums, :created_at
    remove_index :albums, :updated_at
    
    add_index :albums, [:account_id, :created_at]
    
    
    remove_index :photos, :account_id
    # remove_index :photos, :album_id
    remove_index :photos, :created_at
    
    add_index :photos, [:account_id, :created_at]
    
    
    remove_index :photo_comments, :photo_id
    remove_index :photo_comments, :account_id
    remove_index :photo_comments, :created_at
    
    add_index :photo_comments, [:photo_id, :created_at]
    
    
    remove_index :blogs, :account_id
    # remove_index :blogs, :created_at
    
    add_index :blogs, [:account_id, :created_at]
    
    
    remove_index :blog_comments, :blog_id
    remove_index :blog_comments, :account_id
    remove_index :blog_comments, :created_at
    
    add_index :blog_comments, [:blog_id, :created_at]
    
  end

  def self.down
    
    remove_index :blog_comments, [:blog_id, :created_at]
    
    add_index :blog_comments, :blog_id
    add_index :blog_comments, :account_id
    add_index :blog_comments, :created_at
    
    
    remove_index :blogs, [:account_id, :created_at]
    
    add_index :blogs, :account_id
    # add_index :blogs, :created_at
    
    
    remove_index :photo_comments, [:photo_id, :created_at]
    
    add_index :photo_comments, :photo_id
    add_index :photo_comments, :account_id
    add_index :photo_comments, :created_at
    
    
    remove_index :photos, [:account_id, :created_at]
    
    add_index :photos, :account_id
    # add_index :photos, :album_id
    add_index :photos, :created_at
    
    
    remove_index :albums, [:account_id, :created_at]
    
    add_index :albums, :account_id
    add_index :albums, :created_at
    add_index :albums, :updated_at
    
  end
end

