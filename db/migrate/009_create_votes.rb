class CreateVotes < ActiveRecord::Migration
  def self.up

    # vote_categories table
    create_table :vote_categories, :force => true do |t|
      t.column :name, :string
      
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :vote_categories, :name
    add_index :vote_categories, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO vote_categories (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM vote_categories WHERE id = 1000")
    
    # vote_topics table
    create_table :vote_topics, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :title, :string
      t.column :desc, :string, :limit => 1000
      
      t.column :account_id, :integer

      t.column :category_id, :integer
      
      t.column :multiple, :boolean, :default => false
      t.column :allow_add_option, :boolean, :default => false
      t.column :allow_clear_record, :boolean, :default => false
      
      t.column :group_id, :integer, :default => 0
      # = 0 -> overall vote topic
      # > 0 -> single group vote topic, it's the group id
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :vote_topics, :created_at
    add_index :vote_topics, :account_id
    add_index :vote_topics, :category_id
    add_index :vote_topics, :multiple
    add_index :vote_topics, :allow_add_option
    add_index :vote_topics, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO vote_topics (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM vote_topics WHERE id = 1000")
    
    # vote_images table
    create_table :vote_images, :force => true do |t|
      t.column :vote_topic_id, :integer
      t.column :updated_at, :datetime
      
      t.column :photo_id, :integer
      t.column :pic_url, :string
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :vote_images, :vote_topic_id
    add_index :vote_images, :photo_id
    add_index :vote_images, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO vote_images (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM vote_images WHERE id = 1000")
    
    # vote_options table
    create_table :vote_options, :force => true do |t|
      t.column :created_at, :datetime
      t.column :account_id, :integer
      
      t.column :vote_topic_id, :integer
      t.column :title, :string
      t.column :color, :string, :limit => 7
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :vote_options, :created_at
    add_index :vote_options, :account_id
    add_index :vote_options, :vote_topic_id
    add_index :vote_options, :color
    add_index :vote_options, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO vote_options (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM vote_options WHERE id = 1000")
    
    # vote_options table
    create_table :vote_records, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer
      
      t.column :vote_topic_id, :integer
      t.column :vote_option_id, :integer
      
      t.column :voter_ip, :string, :limit => 40
      # to be compatible with IPv6, IP v6 will have 39 chars
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :vote_records, :created_at
    add_index :vote_records, :updated_at
    add_index :vote_records, :account_id
    add_index :vote_records, :vote_topic_id
    add_index :vote_records, :vote_option_id
    add_index :vote_records, :voter_ip
    add_index :vote_records, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO vote_records (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM vote_records WHERE id = 1000")
    
    # vote_comments table
    create_table :vote_comments, :force => true do |t|
      t.column :vote_topic_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer
      t.column :content, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :vote_comments, :vote_topic_id
    add_index :vote_comments, :account_id
    add_index :vote_comments, :created_at
    add_index :vote_comments, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO vote_comments (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM vote_comments WHERE id = 1000")
    
    
    
    [
      "其它",
      "征求意见",
      "纯属搞笑",
      "诚心调查",
      "偶很好奇",
      "一决雌雄"
    ].each do |c|
      category = VoteCategory.new(:name => c)
      category.save!
    end
    
  end

  def self.down
    drop_table :vote_comments
    drop_table :vote_records
    drop_table :vote_options
    drop_table :vote_images
    drop_table :vote_topics
    drop_table :vote_categories
  end
end
