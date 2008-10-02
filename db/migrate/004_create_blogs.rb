class CreateBlogs < ActiveRecord::Migration
  def self.up
    
    # blogs table
    create_table :blogs, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :account_id, :integer
      
      t.column :title, :string
      t.column :content, :text
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :blogs, :account_id
    add_index :blogs, :created_at
    add_index :blogs, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO blogs (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM blogs WHERE id = 1000")
    
    # blog_comments table
    create_table :blog_comments, :force => true do |t|
      t.column :blog_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer
      t.column :content, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :blog_comments, :blog_id
    add_index :blog_comments, :account_id
    add_index :blog_comments, :created_at
    add_index :blog_comments, :delta
    
  end

  def self.down
    drop_table :blog_comments
    drop_table :blogs
  end
end
