class Company < ActiveRecord::Base
  
#  define_index do
#    # fields
#    indexes :name, :desc

#    # attributes
#    has :created_at, :updated_at, :account_id
    
#    set_property :delta => true
    
#    # set_property :field_weights => {:field => number}
#  end
  
  
  
  validates_presence_of :name, :message => "请输入 名称"
  
  validates_uniqueness_of :name, :case_sensitive => false, :scope => :account_id, :message => "名称 已经存在"
  
  validates_length_of :name, :maximum => 256, :message => "名称 超过长度限制", :allow_nil => false
  validates_length_of :desc, :maximum => 1000, :message => "别名或其他常用名 超过长度限制", :allow_nil => true
  
  
  
  named_scope :system, :conditions => ["account_id = ? or account_id = ?", 0, nil]
  
  
  
  CKP_account_companies = :account_companies
  CKP_company = :company
  
  after_save { |company|
    self.clear_account_companies_cache(company.account_id) if company.account_id && company.account_id > 0
    self.set_company_cache(company)
  }
  
  after_destroy { |company|
    self.clear_account_companies_cache(company.account_id) if company.account_id && company.account_id > 0
    self.clear_company_cache(company.id)
  }
  
  
  
  
  def self.get_account_companies(account_id)
    a_c = Cache.get("#{CKP_account_companies}_#{account_id}".to_sym)
    
    unless a_c
      a_c = self.find(:all, :conditions => ["account_id = ?", account_id], :order => "created_at DESC")
      
      # set individual company cache
      a_c.each { |c| self.set_company_cache(c) }
      
      Cache.set("#{CKP_account_companies}_#{account_id}".to_sym, a_c, Cache_TTL)
    end
    a_c
  end
  
  def self.clear_account_companies_cache(account_id)
    Cache.delete("#{CKP_account_companies}_#{account_id}".to_sym)
  end
  
  
  require_dependency "job_target"
  require_dependency "job_step"
  require_dependency "job_position"
  def self.get_company(company_id)
    c = Cache.get("#{CKP_company}_#{company_id}".to_sym)
    
    unless c
      c = self.find(company_id)
      
      self.set_company_cache(c)
    end
    c
  end
  
  def self.set_company_cache(company)
    Cache.set("#{CKP_company}_#{company.id}".to_sym, company, Cache_TTL)
  end
  
  def self.clear_company_cache(company_id)
    Cache.delete("#{CKP_company}_#{company_id}".to_sym)
  end
  
  
end


