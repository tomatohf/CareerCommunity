class JobServiceEvaluation < ActiveRecord::Base

  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :job_service, :class_name => "JobService", :foreign_key => "job_service_id"

  # ---

  validates_presence_of :job_service_id, :account_id, :point
  
  validates_numericality_of :point, :message => "评分 必须是正整数", :allow_nil => false, :greater_than => 0, :only_integer => true
  
end
