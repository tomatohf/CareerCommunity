class CreateCustomerPosts < ActiveRecord::Migration
  def self.up
    
    # customer_posts table
    create_table :customer_posts, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :customer_id, :integer
      t.column :account_id, :integer
      
      t.column :title, :string
      t.column :content, :text
      
      t.column :top, :boolean, :default => false
      t.column :good, :boolean, :default => false
      
      t.column :responded_at, :datetime
      t.column :responded_by, :integer
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :customer_posts, :responded_at
    add_index :customer_posts, [:customer_id, :responded_at]
    add_index :customer_posts, [:customer_id, :top, :responded_at]
    add_index :customer_posts, [:customer_id, :good, :top, :responded_at],
              :name => :index_customer_posts_on_customer_good_top_responded
    add_index :customer_posts, [:account_id, :responded_at]
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO customer_posts (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM customer_posts WHERE id = 1000")
    
    # customer_post_comments table
    create_table :customer_post_comments, :force => true do |t|
      t.column :customer_post_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer
      t.column :content, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :customer_post_comments, [:customer_post_id, :created_at]
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO customer_post_comments (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM customer_post_comments WHERE id = 1000")
    
    # customer_post_attachments table
    create_table :customer_post_attachments, :force => true do |t|
      t.column :created_at, :datetime
      
      t.column :customer_post_id, :integer
      t.column :account_id, :integer
      
      t.column :desc, :string, :limit => 1000
      

      # for paperclip ...
      t.column :attachment_file_name, :string # Original filename
      t.column :attachment_content_type, :string # Mime type
      t.column :attachment_file_size, :integer # File size in bytes
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :customer_post_attachments, :customer_post_id
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO customer_post_attachments (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM customer_post_attachments WHERE id = 1000")
    
  end

  def self.down
    drop_table :customer_post_attachments
    drop_table :customer_post_comments
    drop_table :customer_posts
  end
end

