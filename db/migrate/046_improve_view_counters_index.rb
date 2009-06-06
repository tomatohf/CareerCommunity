class ImproveViewCountersIndex < ActiveRecord::Migration
  def self.up
    
    remove_index :view_counters, :updated_at
    remove_index :view_counters, :created_at
    # remove_index :view_counters, :counter_key
    remove_index :view_counters, :view_count
    
  end

  def self.down
    
    add_index :view_counters, :updated_at
    add_index :view_counters, :created_at
    # add_index :view_counters, :counter_key
    add_index :view_counters, :view_count
    
  end
end

