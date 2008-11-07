class JobStatus < ActiveRecord::Base
  
  has_many :steps, :class_name => "JobStep", :foreign_key => "job_status_id", :dependent => :nullify
  
  
  validates_presence_of :name
  
  validates_presence_of :name, :message => "请输入 名称"
  
  validates_length_of :name, :maximum => 250, :message => "名称 超过长度限制", :allow_nil => false
  
  
  
  CKP_system_statuses = :system_job_statuses
  
  after_destroy { |job_status|
  }
  
  after_save { |job_status|
  }
  
  
  
  def self.get_system_job_statuses
    
  end
  
  
end


