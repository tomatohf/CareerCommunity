class CreateGroups < ActiveRecord::Migration
  def self.up
    
    # groups table
    create_table :groups, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :creator_id, :integer
      t.column :master_id, :integer
      
      t.column :name, :string
      t.column :desc, :string, :limit => 1000
      
      t.column :setting, :text
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :groups, :created_at
    add_index :groups, :creator_id
    add_index :groups, :master_id
    add_index :groups, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO groups (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM groups WHERE id = 1000")
    
    # group_members table
    create_table :group_members, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :join_at, :datetime
      
      t.column :group_id, :integer
      t.column :account_id, :integer
      
      t.column :accepted, :boolean, :default => false
      t.column :approved, :boolean, :default => false
      
      t.column :admin, :boolean, :default => false
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :group_members, :created_at
    add_index :group_members, :updated_at
    add_index :group_members, :join_at
    add_index :group_members, :group_id
    add_index :group_members, :account_id
    add_index :group_members, :accepted
    add_index :group_members, :approved
    add_index :group_members, :admin
    add_index :group_members, [:group_id, :account_id]
    add_index :group_members, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO group_members (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM group_members WHERE id = 1000")
    
    # group_images table
    create_table :group_images, :force => true do |t|
      t.column :group_id, :integer
      t.column :updated_at, :datetime
      
      t.column :photo_id, :integer
      t.column :pic_url, :string
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :group_images, :group_id
    add_index :group_images, :photo_id
    add_index :group_images, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO group_images (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM group_images WHERE id = 1000")
    
    
    
    # group_posts table
    create_table :group_posts, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :group_id, :integer
      t.column :account_id, :integer
      
      t.column :title, :string
      t.column :content, :text
      
      t.column :top, :boolean, :default => false
      t.column :responded_at, :datetime
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :group_posts, :created_at
    add_index :group_posts, :group_id
    add_index :group_posts, :account_id
    add_index :group_posts, :top
    add_index :group_posts, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO group_posts (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM group_posts WHERE id = 1000")
    
    # group_post_comments table
    create_table :group_post_comments, :force => true do |t|
      t.column :group_post_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer
      t.column :content, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :group_post_comments, :group_post_id
    add_index :group_post_comments, :account_id
    add_index :group_post_comments, :created_at
    add_index :group_post_comments, :delta
    
    
    
    # group_photos table
    create_table :group_photos, :force => true do |t|
      t.column :created_at, :datetime
      
      t.column :group_id, :integer
      
      t.column :photo_id, :integer
      t.column :account_id, :integer
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :group_photos, :group_id
    add_index :group_photos, :photo_id
    add_index :group_photos, :account_id
    add_index :group_photos, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO group_photos (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM group_photos WHERE id = 1000")
    
  end

  def self.down
    drop_table :group_photos
    drop_table :group_post_comments
    drop_table :group_posts
    drop_table :group_images
    drop_table :group_members
    drop_table :groups
  end
end
