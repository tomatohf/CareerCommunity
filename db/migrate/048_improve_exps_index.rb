class ImproveExpsIndex < ActiveRecord::Migration
  def self.up
    
    # remove_index :exps, :publish_time
    # remove_index :exps, :source_link
    remove_index :exps, :active
    remove_index :exps, :created_at
    
  end

  def self.down
    
    # add_index :exps, :publish_time
    # add_index :exps, :source_link
    add_index :exps, :active
    add_index :exps, :created_at
    
  end
end

