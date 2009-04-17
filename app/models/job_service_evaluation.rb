class JobServiceEvaluation < ActiveRecord::Base
  
  acts_as_trashable


  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :job_service, :class_name => "JobService", :foreign_key => "job_service_id"

  # ---

  validates_presence_of :job_service_id, :account_id, :point, :content
  
  validates_numericality_of :point, :message => "评分 必须是正整数", :allow_nil => false, :greater_than => 0, :only_integer => true
  
  validates_length_of :content, :maximum => 1000, :message => "评价内容 超过长度限制", :allow_nil => false
  
  
  
  CKP_count = :job_service_evaluation_count
  Count_Cache_Group_Field = :job_service_id
  include CareerCommunity::CountCacheable
  
  
  
  after_destroy { |evaluation|
    PointProfile.adjust_account_points_by_action(evaluation.account_id, :add_job_service_evaluation, false)
    
    JobService.clear_top_services_cache(JobService.get_job_service(evaluation.job_service_id).category_id)
  }
  
  after_create { |evaluation|
    PointProfile.adjust_account_points_by_action(evaluation.account_id, :add_job_service_evaluation, true)
  }
  
  after_save { |evaluation|
    JobService.clear_top_services_cache(JobService.get_job_service(evaluation.job_service_id).category_id)
  }
  
  
  
end
