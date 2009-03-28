class RecruitmentTypeStringToInt < ActiveRecord::Migration
  
  def self.up
    
    Recruitment.recruitment_types.each do |k, v|
      Recruitment.update_all(["recruitment_type = ?", k], ["recruitment_type = ?", v])
    end
    
    change_column :recruitments, :recruitment_type, :integer, :limit => 1
    
  end
  
  def self.down
    
    change_column :recruitments, :recruitment_type, :string
    
    Recruitment.recruitment_types.each do |k, v|
      Recruitment.update_all(["recruitment_type = ?", v], ["recruitment_type = ?", k])
    end
    
  end

end
