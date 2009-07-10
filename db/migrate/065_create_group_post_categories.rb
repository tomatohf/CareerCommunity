class CreateGroupPostCategories < ActiveRecord::Migration
  def self.up

    # group_post_categories table
    create_table :group_post_categories, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :group_id, :integer
      
      t.column :name, :string
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :group_post_categories, :group_id
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO group_post_categories (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM group_post_categories WHERE id = 1000")
    
    
    add_column :group_posts, :category_id, :integer, :default => 0
    # set category_id to 0, meaning it doesn't belong to any category
    add_index :group_posts, [:category_id, :top, :responded_at]
    
  end

  def self.down
    
    remove_index :group_posts, [:category_id, :top, :responded_at]
    remove_column :group_posts, :category_id
    
    drop_table :group_post_categories
    
  end
end
