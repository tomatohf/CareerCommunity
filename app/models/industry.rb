class Industry < ActiveRecord::Base
  
  define_index do
    # fields
    indexes :name, :desc

    # attributes
    has :created_at, :updated_at, :account_id
    
    set_property :delta => true
    
    # set_property :field_weights => {:field => number}
  end
  
  
  
  has_and_belongs_to_many :talks,
                          :foreign_key => "industry_id",
                          :association_foreign_key => "talk_id",
                          :join_table => "talks_industries",
                          #:order => "created_at DESC",
                          :after_add => Proc.new { |industry, talk| Industry.clear_talk_industries_cache(talk.id) },
                          :after_remove => Proc.new { |industry, talk| Industry.clear_talk_industries_cache(talk.id) }
  
  
  
  validates_presence_of :name, :message => "请输入 名称"
  
  validates_uniqueness_of :name, :case_sensitive => false, :scope => :account_id, :message => "名称 已经存在"
  
  validates_length_of :name, :maximum => 256, :message => "名称 超过长度限制", :allow_nil => false
  validates_length_of :desc, :maximum => 1000, :message => "别名或其他常用名 超过长度限制", :allow_nil => true
  
  
  
  named_scope :system, :conditions => ["account_id = ? or account_id = ?", 0, nil]
  
  
  
  CKP_account_industries = :account_industries
  CKP_industry = :industry
  
  CKP_talk_industries = :talk_industries
  
  after_save { |industry|
    self.clear_talk_related_cache(industry.id)
    
    self.clear_account_industries_cache(industry.account_id) if industry.account_id && industry.account_id > 0
    
    self.set_industry_cache(industry)
  }
  
  after_destroy { |industry|
    self.clear_talk_related_cache(industry.id)
    
    self.clear_account_industries_cache(industry.account_id) if industryindustry.account_id && industry.account_id > 0
    
    self.clear_industry_cache(industry.id)
  }
  
  def self.clear_talk_related_cache(industry_id)
    industry = self.get_industry(industry_id)
    industry.talks.each do |talk|
      self.clear_talk_industries_cache(talk.id)
    end
  end
  
  
  
  
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
  
  
  def self.get_talk_industries(talk_id)
    is = Cache.get("#{CKP_talk_industries}_#{talk_id}".to_sym)
    
    unless is
      talk = Talk.get_talk(talk_id)
      
      is = []
      talk.industries.each { |i|
        self.set_industry_cache(i)
        is << i
      }
      
      Cache.set("#{CKP_talk_industries}_#{talk_id}".to_sym, is, Cache_TTL)
    end
    is
  end
  
  def self.clear_talk_industries_cache(talk_id)
    Cache.delete("#{CKP_talk_industries}_#{talk_id}".to_sym)
  end
  
  
end


