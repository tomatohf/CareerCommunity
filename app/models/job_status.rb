class JobStatus < ActiveRecord::Base
  
  has_many :steps, :class_name => "JobStep", :foreign_key => "job_status_id", :dependent => :nullify
  
  
  validates_presence_of :name, :message => "请输入 名称"
  
  validates_length_of :name, :maximum => 250, :message => "名称 超过长度限制", :allow_nil => false
  
  
  
  named_scope :system, :conditions => ["account_id = ? or account_id = ?", 0, nil]
  
  
  
  CKP_system_statuses = :system_job_statuses
  CKP_account_statuses = :account_job_statuses
  CKP_status = :job_status
  
  after_destroy { |status|
    if status.account_id && status.account_id > 0
      self.clear_account_statuses_cache(status.account_id)
    else
      self.clear_system_statuses_cache
    end
    
    self.clear_status_cache(status.id)
  }
  
  after_save { |status|
    if status.account_id && status.account_id > 0
      self.clear_account_statuses_cache(status.account_id)
    else
      self.clear_system_statuses_cache
    end
    
    self.set_status_cache(status)
  }
  
  
  
  def self.get_system_statuses
    s_s = Cache.get(CKP_system_statuses)
    
    unless s_s
      s_s = self.system.find(:all)
      
      # set individual job status cache
      s_s.each { |s| self.set_status_cache(s) }
      
      Cache.set(CKP_system_statuses, s_s, Cache_TTL)
    end
    s_s
  end
  
  def self.clear_system_statuses_cache
    Cache.delete(CKP_system_statuses)
  end
  
  
  def self.get_account_statuses(account_id)
    a_s = Cache.get("#{CKP_account_statuses}_#{account_id}".to_sym)
    
    unless a_s
      a_s = self.find(:all, :conditions => ["account_id = ?", account_id], :order => "created_at DESC")
      
      # set individual job status cache
      a_s.each { |s| self.set_status_cache(s) }
      
      Cache.set("#{CKP_account_statuses}_#{account_id}".to_sym, a_s, Cache_TTL)
    end
    a_s
  end
  
  def self.clear_account_statuses_cache(account_id)
    Cache.delete("#{CKP_account_statuses}_#{account_id}".to_sym)
  end
  
  
  def self.get_status(status_id)
    s = Cache.get("#{CKP_status}_#{status_id}".to_sym)
    
    unless s
      s = self.find(status_id)
      
      self.set_status_cache(s)
    end
    s
  end
  
  def self.set_status_cache(status)
    Cache.set("#{CKP_status}_#{status.id}".to_sym, status, Cache_TTL)
  end
  
  def self.clear_status_cache(status_id)
    Cache.delete("#{CKP_status}_#{status_id}".to_sym)
  end
  
  
end


