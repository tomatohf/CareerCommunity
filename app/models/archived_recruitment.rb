class ArchivedRecruitment < ActiveRecord::Base
  
  has_and_belongs_to_many :recruitment_tags,
                          :foreign_key => "archived_recruitment_id",
                          :association_foreign_key => "recruitment_tag_id",
                          :join_table => "archived_recruitments_recruitment_tags"
  has_and_belongs_to_many :companies,
                          :foreign_key => "archived_recruitment_id",
                          :association_foreign_key => "company_id",
                          :join_table => "archived_recruitments_companies"
  has_and_belongs_to_many :job_positions,
                          :foreign_key => "archived_recruitment_id",
                          :association_foreign_key => "job_position_id",
                          :join_table => "archived_recruitments_job_positions"
  
  
  
end
