class CreateGoals < ActiveRecord::Migration
  def self.up
    
    # goals table
    create_table :goals, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer
      
      t.column :name, :string

      t.column :deprecated, :boolean, :default => false
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :goals, :created_at
    add_index :goals, :account_id
    add_index :goals, :name
    add_index :goals, :deprecated
    add_index :goals, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO goals (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM goals WHERE id = 1000")
    
    # goal_follows table
    create_table :goal_follows, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer
      t.column :goal_id, :integer
      
      t.column :private, :boolean, :default => false

      t.column :status_id, :integer, :limit => 2
      t.column :status_updated_at, :datetime
      
      t.column :type_id, :integer, :limit => 2
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :goal_follows, :created_at
    add_index :goal_follows, :updated_at
    add_index :goal_follows, :account_id
    add_index :goal_follows, :goal_id
    add_index :goal_follows, :private
    add_index :goal_follows, :status_id
    add_index :goal_follows, :status_updated_at
    add_index :goal_follows, :type_id
    add_index :goal_follows, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO goal_follows (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM goal_follows WHERE id = 1000")
    
    # goal_tracks table
    create_table :goal_tracks, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :goal_follow_id, :integer

      t.column :value, :decimal
      
      t.column :desc, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :goal_tracks, :created_at
    add_index :goal_tracks, :updated_at
    add_index :goal_tracks, :goal_follow_id
    add_index :goal_tracks, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO goal_tracks (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM goal_tracks WHERE id = 1000")
    
    # goal_track_comments table
    create_table :goal_track_comments, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :goal_track_id, :integer
      
      t.column :account_id, :integer
      t.column :content, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :goal_track_comments, :created_at
    add_index :goal_track_comments, :updated_at
    add_index :goal_track_comments, :goal_track_id
    add_index :goal_track_comments, :account_id
    add_index :goal_track_comments, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO goal_track_comments (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM goal_track_comments WHERE id = 1000")
    
    # goal_posts table
    create_table :goal_posts, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :goal_id, :integer
      t.column :account_id, :integer
      
      t.column :title, :string
      t.column :content, :text
      
      t.column :top, :boolean, :default => false
      t.column :responded_at, :datetime
      t.column :good, :boolean, :default => false
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :goal_posts, :created_at
    add_index :goal_posts, :goal_id
    add_index :goal_posts, :account_id
    add_index :goal_posts, :top
    add_index :goal_posts, :responded_at
    add_index :goal_posts, :good
    add_index :goal_posts, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO goal_posts (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM goal_posts WHERE id = 1000")
    
    # goal_post_comments table
    create_table :goal_post_comments, :force => true do |t|
      t.column :goal_post_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer
      t.column :content, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :goal_post_comments, :goal_post_id
    add_index :goal_post_comments, :account_id
    add_index :goal_post_comments, :created_at
    add_index :goal_post_comments, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO goal_post_comments (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM goal_post_comments WHERE id = 1000")
    
    # goal_post_attachments table
    create_table :goal_post_attachments, :force => true do |t|
      t.column :created_at, :datetime
      
      t.column :goal_post_id, :integer
      t.column :account_id, :integer
      
      t.column :desc, :string, :limit => 1000
      

      # for paperclip ...
      t.column :attachment_file_name, :string # Original filename
      t.column :attachment_content_type, :string # Mime type
      t.column :attachment_file_size, :integer # File size in bytes
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :goal_post_attachments, :created_at
    add_index :goal_post_attachments, :goal_post_id
    add_index :goal_post_attachments, :account_id
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO goal_post_attachments (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM goal_post_attachments WHERE id = 1000")
    
  end

  def self.down
    drop_table :goal_post_attachments
    drop_table :goal_post_comments
    drop_table :goal_posts
    drop_table :goal_track_comments
    drop_table :goal_tracks
    drop_table :goal_follows
    drop_table :goals
  end
end

