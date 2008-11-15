class CreateBookmarks < ActiveRecord::Migration
  def self.up
    
    # personal_bookmarks table
    create_table :personal_bookmarks, :force => true do |t|
      t.column :created_at, :datetime
      
      t.column :account_id, :integer
      
      t.column :title, :string
      t.column :url, :string
      
      t.column :desc, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :personal_bookmarks, :created_at
    add_index :personal_bookmarks, :account_id
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO personal_bookmarks (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM personal_bookmarks WHERE id = 1000")
    
    # group_bookmarks table
    create_table :group_bookmarks, :force => true do |t|
      t.column :created_at, :datetime
      
      t.column :account_id, :integer
      t.column :group_id, :integer
      
      t.column :title, :string
      t.column :url, :string
      
      t.column :desc, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :group_bookmarks, :created_at
    add_index :group_bookmarks, :account_id
    add_index :group_bookmarks, :group_id
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO group_bookmarks (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM group_bookmarks WHERE id = 1000")
    
  end
  


  def self.down
    drop_table :group_bookmarks
    drop_table :personal_bookmarks
  end
end
