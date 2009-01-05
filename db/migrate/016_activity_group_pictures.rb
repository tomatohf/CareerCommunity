class ActivityGroupPictures < ActiveRecord::Migration
  def self.up
    
    # activity_pictures table
    create_table :activity_pictures, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :activity_id, :integer
      t.column :account_id, :integer
      
      t.column :title, :string, :limit => 1000
      
      t.column :top, :boolean, :default => false
      t.column :good, :boolean, :default => false
      t.column :responded_at, :datetime
      
      
      # for paperclip ...
      t.column :image_file_name, :string # Original filename
      t.column :image_content_type, :string # Mime type
      t.column :image_file_size, :integer # File size in bytes
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :activity_pictures, :created_at
    add_index :activity_pictures, :activity_id
    add_index :activity_pictures, :account_id
    add_index :activity_pictures, :top
    add_index :activity_pictures, :good
    add_index :activity_pictures, :responded_at
    add_index :activity_pictures, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO activity_pictures (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM activity_pictures WHERE id = 1000")
    
    # activity_picture_comments table
    create_table :activity_picture_comments, :force => true do |t|
      t.column :activity_picture_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer
      t.column :content, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :activity_picture_comments, :activity_picture_id
    add_index :activity_picture_comments, :account_id
    add_index :activity_picture_comments, :created_at
    add_index :activity_picture_comments, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO activity_picture_comments (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM activity_picture_comments WHERE id = 1000")
    
    
    
    # group_pictures table
    create_table :group_pictures, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :group_id, :integer
      t.column :account_id, :integer
      
      t.column :title, :string, :limit => 1000
      
      t.column :top, :boolean, :default => false
      t.column :good, :boolean, :default => false
      t.column :responded_at, :datetime
      
      
      # for paperclip ...
      t.column :image_file_name, :string # Original filename
      t.column :image_content_type, :string # Mime type
      t.column :image_file_size, :integer # File size in bytes
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :group_pictures, :created_at
    add_index :group_pictures, :group_id
    add_index :group_pictures, :account_id
    add_index :group_pictures, :top
    add_index :group_pictures, :good
    add_index :group_pictures, :responded_at
    add_index :group_pictures, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO group_pictures (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM group_pictures WHERE id = 1000")
    
    # group_picture_comments table
    create_table :group_picture_comments, :force => true do |t|
      t.column :group_picture_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer
      t.column :content, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :group_picture_comments, :group_picture_id
    add_index :group_picture_comments, :account_id
    add_index :group_picture_comments, :created_at
    add_index :group_picture_comments, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO group_picture_comments (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM group_picture_comments WHERE id = 1000")
    
  end

  def self.down
    drop_table :group_picture_comments
    drop_table :group_pictures
    drop_table :activity_picture_comments
    drop_table :activity_pictures
  end
end
