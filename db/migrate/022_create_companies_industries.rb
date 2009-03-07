class CreateCompaniesIndustries < ActiveRecord::Migration
  def self.up
    
    # companies_industries table
    create_table :companies_industries, :id => false, :force => true do |t|
      t.column :company_id, :integer
      t.column :industry_id, :integer
    end
    add_index :companies_industries, :company_id
    add_index :companies_industries, :industry_id
    
  end

  def self.down
    drop_table :companies_industries
  end
end
