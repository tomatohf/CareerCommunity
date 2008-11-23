class JobStep < ActiveRecord::Base
  
  include CareerCommunity::Util
  
  has_one :be_current_job_target, :class_name => "JobTarget", :foreign_key => "current_job_step_id", :dependent => :nullify
  
  belongs_to :job_target, :class_name => "JobTarget", :foreign_key => "job_target_id"
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :job_process, :class_name => "JobProcess", :foreign_key => "job_process_id"
  
  belongs_to :job_status, :class_name => "JobStatus", :foreign_key => "job_status_id"
  
  
  validates_presence_of :account_id, :job_target_id, :job_process_id
  
  
  
  CKP_step = :job_step
  
  after_save { |step|
    self.set_step_cache(step)
  }
  
  after_destroy { |step|
    self.clear_step_cache(step.id)
  }
  
  
  
  
  def self.get_step(step_id)
    s = Cache.get("#{CKP_step}_#{step_id}".to_sym)
    
    unless s
      s = self.find(step_id)
      
      self.set_step_cache(s)
    end
    s
  end
  
  def self.set_step_cache(step)
    Cache.set("#{CKP_step}_#{step.id}".to_sym, step.clear_association, Cache_TTL)
  end
  
  def self.clear_step_cache(step_id)
    Cache.delete("#{CKP_step}_#{step_id}".to_sym)
  end
  
  
  def clear_association
    copy = deep_copy(self)
    copy.clear_association_cache
    copy.clear_aggregation_cache
    copy
  end
  
end


