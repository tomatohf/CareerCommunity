class Company < ActiveRecord::Base
  
  define_index do
    # fields
    indexes :name, :desc

    # attributes
    has :created_at, :updated_at, :account_id
    
    set_property :delta => true
    
    # set_property :field_weights => {:field => number}
  end
  
  
  
  has_and_belongs_to_many :talks,
                          :foreign_key => "company_id",
                          :association_foreign_key => "talk_id",
                          :join_table => "talks_companies",
                          #:order => "created_at DESC",
                          :after_add => Proc.new { |company, talk| Company.clear_talk_companies_cache(talk.id) },
                          :after_remove => Proc.new { |company, talk| Company.clear_talk_companies_cache(talk.id) }

  has_and_belongs_to_many :industries,
                          :foreign_key => "company_id",
                          :association_foreign_key => "industry_id",
                          :join_table => "companies_industries",
                          #:order => "created_at DESC",
                          :after_add => Proc.new { |company, industry|
                            Company.clear_industry_companies_cache(industry.id)
                            Industry.clear_company_industries_cache(company.id)
                          },
                          :after_remove => Proc.new { |company, industry|
                            Company.clear_industry_companies_cache(industry.id)
                            Industry.clear_company_industries_cache(company.id)
                          }
  has_and_belongs_to_many :job_position_infos,
                          :foreign_key => "company_id",
                          :association_foreign_key => "job_position_info_id",
                          :join_table => "job_position_infos_companies"
  
  
  
  validates_presence_of :name, :message => "请输入 名称"
  
  validates_uniqueness_of :name, :case_sensitive => false, :scope => :account_id, :message => "名称 已经存在"
  
  validates_length_of :name, :maximum => 256, :message => "名称 超过长度限制", :allow_nil => false
  validates_length_of :desc, :maximum => 1000, :message => "别名或其他常用名 超过长度限制", :allow_nil => true
  
  
  
  named_scope :system, :conditions => ["account_id = ? or account_id = ?", 0, nil]
  
  
  
  CKP_account_companies = :account_companies
  CKP_company = :company
  
  CKP_talk_companies = :talk_companies
  
  CKP_industry_companies = :industry_companies
  
  after_save { |company|
    self.set_company_cache(company)
    
    self.clear_talk_related_cache(company)
    self.clear_industry_related_cache(company)
    
    self.clear_account_companies_cache(company.account_id) if company.account_id && company.account_id > 0
  }
  
  after_destroy { |company|
    self.clear_company_cache(company.id)
    
    self.clear_talk_related_cache(company)
    self.clear_industry_related_cache(company)
    
    self.clear_account_companies_cache(company.account_id) if company.account_id && company.account_id > 0
  }
  
  def self.clear_talk_related_cache(company)
    company.talks.each do |talk|
      self.clear_talk_companies_cache(talk.id)
    end
  end
  
  def self.clear_industry_related_cache(company)
    company.industries.each do |industry|
      self.clear_industry_companies_cache(industry.id)
    end
  end
  
  
  
  
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
  
  
  def self.get_talk_companies(talk_id)
    cs = Cache.get("#{CKP_talk_companies}_#{talk_id}".to_sym)
    
    unless cs
      talk = Talk.get_talk(talk_id)
      
      cs = []
      talk.companies.each { |c|
        self.set_company_cache(c)
        cs << c
      }
      
      Cache.set("#{CKP_talk_companies}_#{talk_id}".to_sym, cs, Cache_TTL)
    end
    cs
  end
  
  def self.clear_talk_companies_cache(talk_id)
    Cache.delete("#{CKP_talk_companies}_#{talk_id}".to_sym)
  end
  
  
  # there might be a large amount of companies belongs to one industry ...
  # so be careful to use this method, since it maybe cache a huge of data in memory
  def self.get_industry_companies(industry_id)
    cs = Cache.get("#{CKP_industry_companies}_#{industry_id}".to_sym)
    
    unless cs
      industry = Industry.get_industry(industry_id)
      
      cs = []
      industry.companies.each { |c|
        self.set_company_cache(c)
        cs << c
      }
      
      Cache.set("#{CKP_industry_companies}_#{industry_id}".to_sym, cs, Cache_TTL)
    end
    cs
  end
  
  def self.clear_industry_companies_cache(industry_id)
    Cache.delete("#{CKP_industry_companies}_#{industry_id}".to_sym)
  end
  
  
end


