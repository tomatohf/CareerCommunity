class CreateCompanyPosts < ActiveRecord::Migration
  def self.up
    
    # company_posts table
    create_table :company_posts, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :company_id, :integer
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
    add_index :company_posts, :responded_at
    add_index :company_posts, [:company_id, :responded_at]
    add_index :company_posts, [:company_id, :top, :responded_at]
    add_index :company_posts, [:company_id, :good, :top, :responded_at],
              :name => :index_company_posts_on_company_good_top_responded
    add_index :company_posts, [:account_id, :responded_at]
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO company_posts (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM company_posts WHERE id = 1000")
    
    # company_post_comments table
    create_table :company_post_comments, :force => true do |t|
      t.column :company_post_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer
      t.column :content, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :company_post_comments, [:company_post_id, :created_at]
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO company_post_comments (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM company_post_comments WHERE id = 1000")
    
    # company_post_attachments table
    create_table :company_post_attachments, :force => true do |t|
      t.column :created_at, :datetime
      
      t.column :company_post_id, :integer
      t.column :account_id, :integer
      
      t.column :desc, :string, :limit => 1000
      

      # for paperclip ...
      t.column :attachment_file_name, :string # Original filename
      t.column :attachment_content_type, :string # Mime type
      t.column :attachment_file_size, :integer # File size in bytes
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :company_post_attachments, :company_post_id
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO company_post_attachments (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM company_post_attachments WHERE id = 1000")
    
  end

  def self.down
    drop_table :company_post_attachments
    drop_table :company_post_comments
    drop_table :company_posts
  end
end

