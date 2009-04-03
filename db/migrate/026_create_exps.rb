class CreateExps < ActiveRecord::Migration
  def self.up
    
    # exps table
    create_table :exps, :force => true do |t|

      t.column :title, :string
      t.column :content, :text # HTML ...
      
      t.column :publish_time, :datetime # the time when this message is published
      
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
    add_index :exps, :publish_time
    add_index :exps, :source_link
    add_index :exps, :active
    add_index :exps, :created_at
    add_index :exps, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO exps (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM exps WHERE id = 1000")
    
    
    
    # exp_tags table
    create_table :exp_tags, :force => true do |t|
      t.column :name, :string
      
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :exp_tags, :name
    add_index :exp_tags, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO exp_tags (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM exp_tags WHERE id = 1000")

    # exps_exp_tags table
    # create the relationship table
    create_table :exps_exp_tags, :id => false, :force => true do |t|
      t.column :exp_id, :integer
      t.column :exp_tag_id, :integer
    end
    add_index :exps_exp_tags, :exp_id
    add_index :exps_exp_tags, :exp_tag_id
    
  end

  def self.down
    drop_table :exps_exp_tags
    drop_table :exp_tags
    drop_table :exps
  end
end
