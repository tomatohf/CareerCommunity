class Industry < ActiveRecord::Base
  
  define_index do
    # fields
    indexes :name, :desc

    # attributes
    has :created_at, :updated_at, :account_id
    
    set_property :delta => true
    
    # set_property :field_weights => {:field => number}
  end
  
  
  
  validates_presence_of :name, :message => "请输入 名称"
  
  validates_uniqueness_of :name, :case_sensitive => false, :scope => :account_id, :message => "名称 已经存在"
  
  validates_length_of :name, :maximum => 256, :message => "名称 超过长度限制", :allow_nil => false
  validates_length_of :desc, :maximum => 1000, :message => "别名或其他常用名 超过长度限制", :allow_nil => true
  
  
  
  named_scope :system, :conditions => ["account_id = ? or account_id = ?", 0, nil]
  
  
  
  CKP_account_industries = :account_industries
  CKP_industry = :industry
  
  after_save { |industry|
    self.clear_account_industries_cache(industry.account_id) if industry.account_id && industry.account_id > 0
    self.set_industry_cache(industry)
  }
  
  after_destroy { |industry|
    self.clear_account_industries_cache(industry.account_id) if industryindustry.account_id && industry.account_id > 0
    self.clear_industry_cache(industry.id)
  }
  
  
  
  
  def self.get_account_industries(account_id)
    a_c = Cache.get("#{CKP_account_industries}_#{account_id}".to_sym)
    
    unless a_c
      a_c = self.find(:all, :conditions => ["account_id = ?", account_id], :order => "created_at DESC")
      
      # set individual industry cache
      a_c.each { |c| self.set_industry_cache(c) }
      
      Cache.set("#{CKP_account_industries}_#{account_id}".to_sym, a_c, Cache_TTL)
    end
    a_c
  end
  
  def self.clear_account_industries_cache(account_id)
    Cache.delete("#{CKP_account_industries}_#{account_id}".to_sym)
  end
  
  
  require_dependency "job_target"
  require_dependency "job_step"
  require_dependency "job_position"
  def self.get_industry(industry_id)
    c = Cache.get("#{CKP_industry}_#{industry_id}".to_sym)
    
    unless c
      c = self.find(industry_id)
      
      self.set_industry_cache(c)
    end
    c
  end
  
  def self.set_industry_cache(industry)
    Cache.set("#{CKP_industry}_#{industry.id}".to_sym, industry, Cache_TTL)
  end
  
  def self.clear_industry_cache(industry_id)
    Cache.delete("#{CKP_industry}_#{industry_id}".to_sym)
  end
  
  
end


