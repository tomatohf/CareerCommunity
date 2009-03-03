class JobProcess < ActiveRecord::Base
  
  has_many :steps, :class_name => "JobStep", :foreign_key => "job_process_id", :dependent => :destroy
  
  
  validates_presence_of :name, :message => "请输入 名称"
  
  validates_uniqueness_of :name, :case_sensitive => false, :message => "名称 已经存在"
  
  validates_length_of :name, :maximum => 250, :message => "名称 超过长度限制", :allow_nil => false
  
  
  
  named_scope :system, :conditions => ["account_id = ? or account_id = ?", 0, nil]
  
  
  
  CKP_system_processes = :system_job_processes
  CKP_account_processes = :account_job_processes
  CKP_process = :job_process
  
  after_destroy { |process|
    if process.account_id && process.account_id > 0
      self.clear_account_processes_cache(process.account_id)
    else
      self.clear_system_processes_cache
    end
    
    self.clear_process_cache(process.id)
  }
  
  after_save { |process|
    if process.account_id && process.account_id > 0
      self.clear_account_processes_cache(process.account_id)
    else
      self.clear_system_processes_cache
    end
    
    self.set_process_cache(process)
  }
  
  
  
  def self.get_system_processes
    s_p = Cache.get(CKP_system_processes)
    
    unless s_p
      s_p = self.system.find(:all)
      
      # set individual job process cache
      s_p.each { |p| self.set_process_cache(p) }
      
      Cache.set(CKP_system_processes, s_p, Cache_TTL)
    end
    s_p
  end
  
  def self.clear_system_processes_cache
    Cache.delete(CKP_system_processes)
  end
  
  
  def self.get_account_processes(account_id)
    a_p = Cache.get("#{CKP_account_processes}_#{account_id}".to_sym)
    
    unless a_p
      a_p = self.find(:all, :conditions => ["account_id = ?", account_id], :order => "created_at DESC")
      
      # set individual job process cache
      a_p.each { |p| self.set_process_cache(p) }
      
      Cache.set("#{CKP_account_processes}_#{account_id}".to_sym, a_p, Cache_TTL)
    end
    a_p
  end
  
  def self.clear_account_processes_cache(account_id)
    Cache.delete("#{CKP_account_processes}_#{account_id}".to_sym)
  end
  
  require_dependency "account"
  def self.get_process(process_id)
    p = Cache.get("#{CKP_process}_#{process_id}".to_sym)
    
    unless p
      p = self.find(process_id)
      
      self.set_process_cache(p)
    end
    p
  end
  
  def self.set_process_cache(process)
    Cache.set("#{CKP_process}_#{process.id}".to_sym, process, Cache_TTL)
  end
  
  def self.clear_process_cache(process_id)
    Cache.delete("#{CKP_process}_#{process_id}".to_sym)
  end
  
  
end


