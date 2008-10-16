class CreateRecruitments < ActiveRecord::Migration
  def self.up
    
    # recruitments table
    create_table :recruitments, :force => true do |t|

      t.column :title, :string
      t.column :content, :text # HTML ...
      
      t.column :publish_time, :datetime # the time when this message is published
      t.column :location, :string
      t.column :recruitment_type, :string
      
      t.column :source_name, :string
      t.column :source_link, :string
      
      t.column :active, :boolean, :default => true

      t.column :created_at, :datetime # the time when this message is added to our database
      t.column :updated_at, :datetime
      
      # who adds this message
      # if collect automatically, set the value to -1
      t.column :account_id, :integer
      
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
      
    end
    add_index :recruitments, :publish_time
    add_index :recruitments, :location
    add_index :recruitments, :recruitment_type
    add_index :recruitments, :source_link
    add_index :recruitments, :active
    add_index :recruitments, :created_at
    add_index :recruitments, :updated_at
    add_index :recruitments, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO recruitments (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM recruitments WHERE id = 1000")
    
    
    
    # recruitment_tags table
    create_table :recruitment_tags, :force => true do |t|
      t.column :name, :string
      
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :recruitment_tags, :name
    add_index :recruitment_tags, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO recruitment_tags (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM recruitment_tags WHERE id = 1000")

    # recruitments_recruitment_tags table
    # create the relationship table
    create_table :recruitments_recruitment_tags, :id => false, :force => true do |t|
      t.column :recruitment_id, :integer
      t.column :recruitment_tag_id, :integer
    end
    add_index :recruitments_recruitment_tags, :recruitment_id
    add_index :recruitments_recruitment_tags, :recruitment_tag_id
    
  end

  def self.down
    drop_table :recruitments_recruitment_tags
    drop_table :recruitment_tags
    drop_table :recruitments
  end
end
