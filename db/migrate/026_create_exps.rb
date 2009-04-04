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
    
  end

  def self.down
    drop_table :exps
  end
end
