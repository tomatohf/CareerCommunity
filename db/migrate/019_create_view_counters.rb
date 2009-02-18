class CreateViewCounters < ActiveRecord::Migration
  def self.up
    
    # view_counters table
    create_table :view_counters, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :counter_key, :integer
      
      t.column :view_count, :integer
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :view_counters, :updated_at
    add_index :view_counters, :created_at
    add_index :view_counters, :counter_key
    add_index :view_counters, :view_count
    add_index :view_counters, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO view_counters (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM view_counters WHERE id = 1000")
    
  end

  def self.down
    drop_table :view_counters
  end
end
