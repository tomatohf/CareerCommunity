class EducationProfile < ActiveRecord::Base
  
  include CareerCommunity::AccountBelongings

  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"

  # ---

  validates_presence_of :account_id

  validates_presence_of :edu_name, :message => "请输入 学校或者相关教育培训名称"
  
  
  
  def self.get_all_edu_names
    all_edu_names = Cache.get(:all_edu_names)
    unless all_edu_names
      all_edu_names = self.find(:all, :select => "DISTINCT edu_name").collect {|ep| ep.edu_name }
      
      self.set_all_edu_names_cache(all_edu_names)
    end
    all_edu_names
  end
  
  def self.clear_all_edu_names_cache
    Cache.delete(:all_edu_names)
  end
  
  def self.set_all_edu_names_cache(all_edu_names)
    Cache.set(:all_edu_names, all_edu_names, Cache_TTL)
  end
  
  def self.get_by_partial_edu_name(partial_edu_name)
    self.get_all_edu_names.select {|edu_name| edu_name.include?(partial_edu_name) }
  end
  
  
  
  def add_to_cache
    all_edu_names = Cache.get(:all_edu_names)
    if edu_name && edu_name != "" && (!all_edu_names.include?(edu_name))
      all_edu_names << edu_name
      self.class.set_all_edu_names_cache(all_edu_names)
    end
  end
  
end
