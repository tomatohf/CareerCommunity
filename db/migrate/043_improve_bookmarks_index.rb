class ImproveBookmarksIndex < ActiveRecord::Migration
  def self.up
    
    remove_index :personal_bookmarks, :created_at
    remove_index :personal_bookmarks, :account_id
    
    add_index :personal_bookmarks, [:account_id, :created_at]
    
    
    # remove_index :group_bookmarks, :created_at
    remove_index :group_bookmarks, :account_id
    remove_index :group_bookmarks, :group_id
    
    add_index :group_bookmarks, [:group_id, :created_at]
    
  end

  def self.down
    
    remove_index :group_bookmarks, [:group_id, :created_at]
    
    # add_index :group_bookmarks, :created_at
    add_index :group_bookmarks, :account_id
    add_index :group_bookmarks, :group_id
    
    
    remove_index :personal_bookmarks, [:account_id, :created_at]
    
    add_index :personal_bookmarks, :created_at
    add_index :personal_bookmarks, :account_id
    
  end
end

