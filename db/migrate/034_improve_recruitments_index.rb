class ImproveRecruitmentsIndex < ActiveRecord::Migration
  def self.up
    
    remove_index :recruitments, :publish_time
    remove_index :recruitments, :location
    remove_index :recruitments, :recruitment_type
    remove_index :recruitments, :source_link
    remove_index :recruitments, :active
    remove_index :recruitments, :created_at
    remove_index :recruitments, :updated_at
    
    add_index :recruitments, [:recruitment_type, :publish_time]
    
  end

  def self.down
    
    add_index :recruitments, :publish_time
    add_index :recruitments, :location
    add_index :recruitments, :recruitment_type
    add_index :recruitments, :source_link
    add_index :recruitments, :active
    add_index :recruitments, :created_at
    add_index :recruitments, :updated_at
    
  end
end

