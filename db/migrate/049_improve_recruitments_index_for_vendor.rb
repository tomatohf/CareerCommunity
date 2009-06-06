class ImproveRecruitmentsIndexForVendor < ActiveRecord::Migration
  def self.up
    
    add_index :recruitments, :source_link
    
  end

  def self.down
    
    remove_index :recruitments, :source_link
    
  end
end

