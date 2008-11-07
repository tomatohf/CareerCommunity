class JobProcess < ActiveRecord::Base
  
  has_many :steps, :class_name => "JobStep", :foreign_key => "job_process_id", :dependent => :destroy
  
  
  validates_presence_of :name
  
  validates_presence_of :name, :message => "请输入 名称"
  
  validates_length_of :name, :maximum => 250, :message => "名称 超过长度限制", :allow_nil => false
  
  
  
  CKP_system_processes = :system_job_processes
  
  after_destroy { |job_process|
  }
  
  after_save { |job_process|
  }
  
  
  
  def self.get_system_job_processes
    
  end
  
  
end


