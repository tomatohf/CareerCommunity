class JobServiceFunction < ActiveRecord::Base
  
  acts_as_trashable
  
  
  
  has_and_belongs_to_many :job_services,
                          :foreign_key => "function_id",
                          :association_foreign_key => "job_service_id",
                          :join_table => "job_services_functions",
                          :class_name => "JobService"

  # ---

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false, :message => "名称 已经存在"
  
  validates_length_of :name, :maximum => 250, :message => "名称 超过长度限制", :allow_nil => false
  
  
  
end
