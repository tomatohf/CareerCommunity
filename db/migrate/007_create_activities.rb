class CreateActivities < ActiveRecord::Migration
  def self.up
    
    # activities table
    create_table :activities, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :creator_id, :integer
      t.column :master_id, :integer
      
      t.column :title, :string
      # put desc to setting column

      t.column :begin_at, :datetime
      t.column :end_at, :datetime
      t.column :application_deadline, :datetime
      
      t.column :place, :string
      
      t.column :cost, :decimal
      t.column :member_limit, :integer
      
      t.column :in_group, :integer
      # < 0 -> multiple groups activity, need to refer to group_activities table
      # = 0 -> overall activity
      # > 0 -> single group activity, it's the group id
      
      t.column :setting, :text
      # setting column includes:
      #   desc
      #   contact
      #   need_approve
      #
      #   check_<profile>
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :activities, :created_at
    add_index :activities, :creator_id
    add_index :activities, :master_id
    add_index :activities, :begin_at
    add_index :activities, :end_at
    add_index :activities, :application_deadline
    add_index :activities, :cost
    add_index :activities, :member_limit
    add_index :activities, :in_group
    add_index :activities, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO activities (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM activities WHERE id = 1000")
    
    # group_activities table
    create_table :group_activities, :force => true do |t|
      t.column :created_at, :datetime
      
      t.column :activity_id, :integer
      t.column :account_id, :integer
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :group_activities, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO group_activities (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM group_activities WHERE id = 1000")
    
    # activity_members table
    create_table :activity_members, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :join_at, :datetime
      
      t.column :activity_id, :integer
      t.column :account_id, :integer
      
      t.column :accepted, :boolean, :default => false
      t.column :approved, :boolean, :default => false
      
      t.column :absent, :boolean, :default => false
      
      t.column :admin, :boolean, :default => false
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :activity_members, :created_at
    add_index :activity_members, :updated_at
    add_index :activity_members, :join_at
    add_index :activity_members, :activity_id
    add_index :activity_members, :account_id
    add_index :activity_members, :accepted
    add_index :activity_members, :approved
    add_index :activity_members, :absent
    add_index :activity_members, [:activity_id, :account_id]
    add_index :activity_members, :admin
    add_index :activity_members, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO activity_members (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM activity_members WHERE id = 1000")
    
    # activity_interests table
    create_table :activity_interests, :force => true do |t|
      t.column :created_at, :datetime
      
      t.column :activity_id, :integer
      t.column :account_id, :integer
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :activity_interests, :created_at
    add_index :activity_interests, :activity_id
    add_index :activity_interests, :account_id
    add_index :activity_interests, [:activity_id, :account_id]
    add_index :activity_interests, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO activity_interests (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM activity_interests WHERE id = 1000")
    
    # activity_images table
    create_table :activity_images, :force => true do |t|
      t.column :activity_id, :integer
      t.column :updated_at, :datetime
      
      t.column :photo_id, :integer
      t.column :pic_url, :string
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :activity_images, :activity_id
    add_index :activity_images, :photo_id
    add_index :activity_images, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO activity_images (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM activity_images WHERE id = 1000")
    
    
    
    # activity_posts table
    create_table :activity_posts, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :activity_id, :integer
      t.column :account_id, :integer
      
      t.column :title, :string
      t.column :content, :text
      
      t.column :top, :boolean, :default => false
      t.column :responded_at, :datetime
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :activity_posts, :created_at
    add_index :activity_posts, :activity_id
    add_index :activity_posts, :account_id
    add_index :activity_posts, :top
    add_index :activity_posts, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO activity_posts (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM activity_posts WHERE id = 1000")
    
    # activity_post_comments table
    create_table :activity_post_comments, :force => true do |t|
      t.column :activity_post_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer
      t.column :content, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :activity_post_comments, :activity_post_id
    add_index :activity_post_comments, :account_id
    add_index :activity_post_comments, :created_at
    add_index :activity_post_comments, :delta
    
    
    
    # activity_photos table
    create_table :activity_photos, :force => true do |t|
      t.column :created_at, :datetime
      
      t.column :activity_id, :integer
      
      t.column :photo_id, :integer
      t.column :account_id, :integer
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :activity_photos, :activity_id
    add_index :activity_photos, :photo_id
    add_index :activity_photos, :account_id
    add_index :activity_photos, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO activity_photos (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM activity_photos WHERE id = 1000")
    
  end

  def self.down
    drop_table :activity_photos
    drop_table :activity_post_comments
    drop_table :activity_posts
    drop_table :activity_images
    drop_table :activity_interests
    drop_table :activity_members
    drop_table :group_activities
    drop_table :activities
  end
end
