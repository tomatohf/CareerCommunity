class CreatePhotos < ActiveRecord::Migration
  def self.up
    
    # albums table
    create_table :albums, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :account_id, :integer
      
      t.column :name, :string
      t.column :description, :string, :limit => 1000

      t.column :cover_photo_id, :integer
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :albums, :account_id
    add_index :albums, :created_at
    add_index :albums, :updated_at
    add_index :albums, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO albums (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM albums WHERE id = 1000")
    
    # photos table
    create_table :photos, :force => true do |t|
      t.column :album_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :account_id, :integer
      
      t.column :title, :string

      # for paperclip ...
      t.column :image_file_name, :string # Original filename
      t.column :image_content_type, :string # Mime type
      t.column :image_file_size, :integer # File size in bytes
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :photos, :account_id
    add_index :photos, :album_id
    add_index :photos, :created_at
    add_index :photos, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO photos (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM photos WHERE id = 1000")
    
    # photo_comments table
    create_table :photo_comments, :force => true do |t|
      t.column :photo_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer
      t.column :content, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :photo_comments, :photo_id
    add_index :photo_comments, :account_id
    add_index :photo_comments, :created_at
    add_index :photo_comments, :delta
    
  end

  def self.down
    drop_table :photo_comments
    drop_table :photos
    drop_table :albums
  end
end
