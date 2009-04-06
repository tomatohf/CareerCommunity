class AddNullCompanyJobPositionRecord < ActiveRecord::Migration
  def self.up
    
    now = DateTime.now
    
    ActiveRecord::Base.connection.execute("INSERT INTO companies (id) VALUES (1000)")
    company = Company.find(1000)
    company.name = "未设置"
    company.desc = ""
    company.account_id = 0
    company.created_at = now
    company.updated_at = now
    company.save!
    
    ActiveRecord::Base.connection.execute("INSERT INTO job_positions (id) VALUES (1000)")
    position = JobPosition.find(1000)
    position.name = "未设置"
    position.desc = ""
    position.account_id = 0
    position.created_at = now
    position.updated_at = now
    position.save!
    
  end

  def self.down
    
    ActiveRecord::Base.connection.execute("DELETE FROM companies WHERE id = 1000")
    
    ActiveRecord::Base.connection.execute("DELETE FROM job_positions WHERE id = 1000")
    
  end
end
