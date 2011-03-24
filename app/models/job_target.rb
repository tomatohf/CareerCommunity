class JobTarget < ActiveRecord::Base
  
  acts_as_trashable
  
  
  include CareerCommunity::Util
  
  has_many :steps, :class_name => "JobStep", :foreign_key => "job_target_id", :dependent => :destroy
  
  has_one :note, :class_name => "JobTargetNote", :foreign_key => "job_target_id", :dependent => :destroy
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :company, :class_name => "Company", :foreign_key => "company_id"
  belongs_to :job_position, :class_name => "JobPosition", :foreign_key => "job_position_id"
  
  belongs_to :current_step, :class_name => "JobStep", :foreign_key => "current_job_step_id"
  
  
  validates_presence_of :account_id, :company_id, :job_position_id
  
  
  
  named_scope :unclosed, :conditions => { :closed => false }
  named_scope :closed, :conditions => { :closed => true }
  
  
  
  CKP_target = :job_target
  
  after_save { |target|
    self.set_target_cache(target)
  }
  
  after_destroy { |target|
    self.clear_target_cache(target.id)
  }
  
  
  
  
  def self.get_target(target_id)
    t = Cache.get("#{CKP_target}_#{target_id}".to_sym)
    
    unless t
      t = self.find(target_id)
      
      self.set_target_cache(t)
    end
    t
  end
  
  def self.set_target_cache(target)
    Cache.set("#{CKP_target}_#{target.id}".to_sym, target.clear_association, Cache_TTL)
  end
  
  def self.clear_target_cache(target_id)
    Cache.delete("#{CKP_target}_#{target_id}".to_sym)
  end
  
  
  def get_company_name
    Company.get_company(self.company_id).name
  end
  
  def get_position_name
    JobPosition.get_position(self.job_position_id).name
  end
  
  
  def get_info
    (eval(self.info || "") || {}) rescue {}
  end
  
  def fill_info(hash_info)
    self.info = hash_info.inspect
  end
  
  def update_info(hash_info)
    new_info = self.get_info.merge(hash_info)
    self.fill_info(new_info)
  end
  
  
  def clear_association
    copy = deep_copy(self)
    copy.clear_association_cache
    copy.clear_aggregation_cache
    copy
  end
  
end


