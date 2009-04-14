class JobServiceComment < ActiveRecord::Base
  
  acts_as_trashable
  
  
  include CareerCommunity::Util
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :job_service, :class_name => "JobService", :foreign_key => "job_service_id"

  # ---

  validates_presence_of :account_id, :job_service_id, :content
  
  validates_length_of :content, :maximum => 1000, :message => "评价内容 超过长度限制", :allow_nil => false
  
  
  
  CKP_count = :job_service_comment_count
  Count_Cache_Group_Field = :job_service_id
  include CareerCommunity::CountCacheable
  
  
  
  after_destroy { |comment|
    PointProfile.adjust_account_points_by_action(comment.account_id, :add_job_service_comment, false)
  }
  
  after_create { |comment|
    PointProfile.adjust_account_points_by_action(comment.account_id, :add_job_service_comment, true)
  }
  
end

