class ImproveRecruitmentsIndex < ActiveRecord::Migration
  def self.up
    
    remove_index :recruitments, :publish_time
    # remove_index :recruitments, :location
    remove_index :recruitments, :recruitment_type
    remove_index :recruitments, :source_link
    remove_index :recruitments, :active
    remove_index :recruitments, :created_at
    remove_index :recruitments, :updated_at
    
    add_index :recruitments, [:recruitment_type, :publish_time]
    
    
    remove_index :recruitments_recruitment_tags, :recruitment_id
    remove_index :recruitments_recruitment_tags, :recruitment_tag_id
    
    add_index :recruitments_recruitment_tags, 
              [:recruitment_id, :recruitment_tag_id], 
              :unique => true, 
              :name => :recruitments_recruitment_tags_id
    
  end

  def self.down
    
    remove_index :recruitments_recruitment_tags, :name => :recruitments_recruitment_tags_id
    
    add_index :recruitments_recruitment_tags, :recruitment_id
    add_index :recruitments_recruitment_tags, :recruitment_tag_id
    
    
    remove_index :recruitments, [:recruitment_type, :publish_time]
    
    add_index :recruitments, :publish_time
    # add_index :recruitments, :location
    add_index :recruitments, :recruitment_type
    add_index :recruitments, :source_link
    add_index :recruitments, :active
    add_index :recruitments, :created_at
    add_index :recruitments, :updated_at
    
  end
end

