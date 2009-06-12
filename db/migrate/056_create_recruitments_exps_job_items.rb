class CreateRecruitmentsExpsJobItems < ActiveRecord::Migration
  def self.up
    
    # recruitments_companies table
    create_table :recruitments_companies, :id => false, :force => true do |t|
      t.column :recruitment_id, :integer
      t.column :company_id, :integer
    end
    add_index :recruitments_companies, [:recruitment_id, :company_id], :unique => true
    add_index :recruitments_companies, [:company_id, :recruitment_id], :unique => true
    
    # recruitments_job_positions table
    create_table :recruitments_job_positions, :id => false, :force => true do |t|
      t.column :recruitment_id, :integer
      t.column :job_position_id, :integer
    end
    add_index :recruitments_job_positions, [:recruitment_id, :job_position_id], 
              :name => :index_recruitments_job_positions_on_recruitment_position, 
              :unique => true
    add_index :recruitments_job_positions, [:job_position_id, :recruitment_id], 
              :name => :index_recruitments_job_positions_on_position_recruitment, 
              :unique => true
    
    
    # exps_companies table
    create_table :exps_companies, :id => false, :force => true do |t|
      t.column :exp_id, :integer
      t.column :company_id, :integer
    end
    add_index :exps_companies, [:exp_id, :company_id], :unique => true
    add_index :exps_companies, [:company_id, :exp_id], :unique => true
    
    # exps_job_positions table
    create_table :exps_job_positions, :id => false, :force => true do |t|
      t.column :exp_id, :integer
      t.column :job_position_id, :integer
    end
    add_index :exps_job_positions, [:exp_id, :job_position_id], :unique => true
    add_index :exps_job_positions, [:job_position_id, :exp_id], :unique => true
    
  end

  def self.down
    
    drop_table :exps_job_positions
    drop_table :exps_companies
    
    drop_table :recruitments_job_positions
    drop_table :recruitments_companies
    
  end
end

