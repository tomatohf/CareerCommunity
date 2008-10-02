class JobProfile < ActiveRecord::Base
  
  include CareerCommunity::AccountBelongings

  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"

  # ---

  validates_presence_of :account_id

  validates_presence_of :job_name, :message => "请输入 公司或者职业经历名称"
  
  validates_length_of :description, :maximum => 1000, :message => "职责与成就描述 超过长度限制", :allow_nil => true
  
  
  
  def self.get_all_job_names
    all_job_names = Cache.get(:all_job_names)
    unless all_job_names
      all_job_names = self.find(:all, :select => "DISTINCT job_name").collect {|jp| jp.job_name }
      
      self.set_all_job_names_cache(all_job_names)
    end
    all_job_names
  end
  
  def self.clear_all_job_names_cache
    Cache.delete(:all_job_names)
  end
  
  def self.set_all_job_names_cache(all_job_names)
    Cache.set(:all_job_names, all_job_names, Cache_TTL)
  end
  
  def self.get_by_partial_job_name(partial_job_name)
    self.get_all_job_names.select {|job_name| job_name.include?(partial_job_name) }
  end
  
  
  
  def add_to_cache
    all_job_names = Cache.get(:all_job_names)
    if job_name && job_name != "" && (!all_job_names.include?(job_name))
      all_job_names << job_name
      self.class.set_all_job_names_cache(all_job_names)
    end
  end
  
end
