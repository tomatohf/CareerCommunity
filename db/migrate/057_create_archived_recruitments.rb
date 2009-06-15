class CreateArchivedRecruitments < ActiveRecord::Migration
  def self.up
    
    # archived_recruitments table
    # archived table whose id will be set everytime it's being inserted
    create_table :archived_recruitments, :force => true do |t|

      t.column :title, :string
      t.column :content, :text
      
      t.column :publish_time, :datetime
      t.column :location, :string
      t.column :recruitment_type, :integer, :limit => 1
      
      t.column :source_name, :string
      t.column :source_link, :string
      
      t.column :active, :boolean #, :default => true

      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer
      
      t.column :delta, :boolean
      
    end

    # archived_recruitments_recruitment_tags table
    # create the relationship table
    create_table :archived_recruitments_recruitment_tags, :id => false, :force => true do |t|
      t.column :archived_recruitment_id, :integer
      t.column :recruitment_tag_id, :integer
    end
    
    # archived_recruitments_companies table
    create_table :archived_recruitments_companies, :id => false, :force => true do |t|
      t.column :archived_recruitment_id, :integer
      t.column :company_id, :integer
    end
    
    # archived_recruitments_job_positions table
    create_table :archived_recruitments_job_positions, :id => false, :force => true do |t|
      t.column :archived_recruitment_id, :integer
      t.column :job_position_id, :integer
    end
    
  end

  def self.down
    drop_table :archived_recruitments_job_positions
    drop_table :archived_recruitments_companies
    drop_table :archived_recruitments_recruitment_tags
    drop_table :archived_recruitments
  end
end
