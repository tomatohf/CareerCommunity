class JobTargetNote < ActiveRecord::Base
  
  belongs_to :job_target, :class_name => "JobTarget", :foreign_key => "job_target_id"
  
  
  validates_presence_of :job_target_id
  
  
end


