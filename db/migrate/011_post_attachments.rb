class PostAttachments < ActiveRecord::Migration
  def self.up
    
    # group_post_attachments table
    create_table :group_post_attachments, :force => true do |t|
      t.column :created_at, :datetime
      
      t.column :group_post_id, :integer
      t.column :account_id, :integer
      
      t.column :desc, :string, :limit => 1000
      

      # for paperclip ...
      t.column :attachment_file_name, :string # Original filename
      t.column :attachment_content_type, :string # Mime type
      t.column :attachment_file_size, :integer # File size in bytes
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :group_post_attachments, :created_at
    add_index :group_post_attachments, :group_post_id
    add_index :group_post_attachments, :account_id
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO group_post_attachments (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM group_post_attachments WHERE id = 1000")

    # activity_post_attachments table
    create_table :activity_post_attachments, :force => true do |t|
      t.column :created_at, :datetime
      
      t.column :activity_post_id, :integer
      t.column :account_id, :integer
      
      t.column :desc, :string, :limit => 1000
      

      # for paperclip ...
      t.column :attachment_file_name, :string # Original filename
      t.column :attachment_content_type, :string # Mime type
      t.column :attachment_file_size, :integer # File size in bytes
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :activity_post_attachments, :created_at
    add_index :activity_post_attachments, :activity_post_id
    add_index :activity_post_attachments, :account_id
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO activity_post_attachments (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM activity_post_attachments WHERE id = 1000")
    
  end

  def self.down
    drop_table :activity_post_attachments
    drop_table :group_post_attachments
  end
end
