class CreateFriends < ActiveRecord::Migration
  def self.up
    
    # space_comments table
    create_table :space_comments, :force => true do |t|
      t.column :owner_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer
      t.column :content, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :space_comments, :owner_id
    add_index :space_comments, :account_id
    add_index :space_comments, :created_at
    add_index :space_comments, :delta
    
    # friends table
    create_table :friends, :force => true do |t|
      t.column :created_at, :datetime
      t.column :account_id, :integer
      t.column :friend_id, :integer
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :friends, :account_id
    add_index :friends, :friend_id
    add_index :friends, [:account_id, :friend_id]
    add_index :friends, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO friends (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM friends WHERE id = 1000")
    
    # account_actions table
    create_table :account_actions, :force => true do |t|
      t.column :account_id, :integer
      t.column :created_at, :datetime
      
      t.column :action_type, :string, :limit => 30
      t.column :raw_data, :text
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :account_actions, :account_id
    add_index :account_actions, :created_at
    add_index :account_actions, :action_type
    add_index :account_actions, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO account_actions (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM account_actions WHERE id = 1000")
    
    # messages table
    create_table :messages, :force => true do |t|
      t.column :created_at, :datetime
      
      t.column :receiver_id, :integer
      t.column :sender_id, :integer
      
      t.column :content, :string, :limit => 1000
      
      t.column :has_read, :boolean, :default => false
      t.column :reply_to_id, :integer
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :messages, :created_at
    add_index :messages, :receiver_id
    add_index :messages, :sender_id
    add_index :messages, :has_read
    add_index :messages, :reply_to_id
    add_index :messages, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO messages (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM messages WHERE id = 1000")
    
    # sent_messages table
    create_table :sent_messages, :force => true do |t|
      t.column :created_at, :datetime
      
      t.column :sender_id, :integer
      t.column :receiver_id, :integer
      
      t.column :content, :string, :limit => 1000
      
      t.column :reply_to_id, :integer
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :sent_messages, :created_at
    add_index :sent_messages, :sender_id
    add_index :sent_messages, :receiver_id
    add_index :sent_messages, :reply_to_id
    add_index :sent_messages, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO sent_messages (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM sent_messages WHERE id = 1000")
    
    # sys_messages table
    create_table :sys_messages, :force => true do |t|
      t.column :account_id, :integer
      t.column :created_at, :datetime
      
      t.column :has_read, :boolean, :default => false
      
      t.column :msg_type, :string, :limit => 30
      t.column :raw_data, :text
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :sys_messages, :account_id
    add_index :sys_messages, :created_at
    add_index :sys_messages, :has_read
    add_index :sys_messages, :msg_type
    add_index :sys_messages, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO sys_messages (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM sys_messages WHERE id = 1000")
    
  end

  def self.down
    drop_table :sys_messages
    drop_table :sent_messages
    drop_table :messages
    drop_table :account_actions
    drop_table :friends
    drop_table :space_comments
  end
end
