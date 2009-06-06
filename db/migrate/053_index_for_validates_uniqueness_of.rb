class IndexForValidatesUniquenessOf < ActiveRecord::Migration
  def self.up
    
    add_index :industries, [:name, :account_id], :unique => true
    
    
    remove_index :exps, :source_link
    add_index :exps, :source_link, :unique => true
    
    
    remove_index :recruitment_tags, :name
    add_index :recruitment_tags, :name, :unique => true
    
    
    remove_index :job_tags, :name
    add_index :job_tags, :name, :unique => true
    
    
    remove_index :recruitments, :source_link
    add_index :recruitments, :source_link, :unique => true
    
    
    add_index :job_info_categories, :name, :unique => true
    
    
    add_index :job_service_categories, :name, :unique => true
    
  end

  def self.down
    
    remove_index :job_service_categories, :name
    
    
    remove_index :job_info_categories, :name
    
    
    # remove_index :recruitments, :source_link
    # add_index :recruitments, :source_link
    
    
    # remove_index :job_tags, :name
    # add_index :job_tags, :name
    
    
    # remove_index :recruitment_tags, :name
    # add_index :recruitment_tags, :name
    
    
    # remove_index :exps, :source_link
    # add_index :exps, :source_link
    
    
    remove_index :industries, [:name, :account_id]
    
  end
end

