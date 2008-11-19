class JobTarget < ActiveRecord::Base
  
  has_many :steps, :class_name => "JobStep", :foreign_key => "job_target_id", :dependent => :destroy
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :company, :class_name => "Company", :foreign_key => "company_id"
  belongs_to :job_position, :class_name => "JobPosition", :foreign_key => "job_position_id"
  
  belongs_to :current_step, :class_name => "JobStep", :foreign_key => "current_job_step_id"
  
  
  validates_presence_of :account_id, :company_id, :job_position_id
  
  
  
  named_scope :unclosed, :conditions => { :closed => false }
  named_scope :closed, :conditions => { :closed => true }
  
  
  
  # CKP_
  
  after_destroy { |job_target|
  }
  
  after_save { |job_target|
  }
  
  
  
  
end


