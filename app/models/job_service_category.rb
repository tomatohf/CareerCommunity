class JobServiceCategory < ActiveRecord::Base
  
  acts_as_trashable
  
  
  
  validates_presence_of :name, :message => "请输入 名称"
  
  validates_uniqueness_of :name, :case_sensitive => false, :message => "名称 已经存在"
  
  validates_length_of :name, :maximum => 250, :message => "名称 超过长度限制", :allow_nil => false
  validates_length_of :desc, :maximum => 1000, :message => "描述 超过长度限制", :allow_nil => true
  
  
  
  CKP_all_categories = :all_job_service_categories
  CKP_category = :job_service_category
  
  after_destroy { |category|
    self.clear_category_cache(category.id)
    
    self.clear_all_categories_cache
    
    JobService.clear_top_services_cache(category.id)
  }
  
  after_save { |category|
    self.set_category_cache(category)
    
    self.clear_all_categories_cache
    
    JobService.clear_top_services_cache(category.id)
  }
  
  
  
  def self.get_all_categories
    a_c = Cache.get(CKP_all_categories)
    
    unless a_c
      a_c = self.find(:all)
      
      a_c.each { |c| self.set_category_cache(c) }
      
      Cache.set(CKP_all_categories, a_c, Cache_TTL)
    end
    a_c
  end
  
  def self.clear_all_categories_cache
    Cache.delete(CKP_all_categories)
  end
  
  
  def self.get_category(category_id)
    c = Cache.get("#{CKP_category}_#{category_id}".to_sym)
    
    unless c
      c = self.find(category_id)
      
      self.set_category_cache(c)
    end
    c
  end
  
  def self.set_category_cache(category)
    Cache.set("#{CKP_category}_#{category.id}".to_sym, category, Cache_TTL)
  end
  
  def self.clear_category_cache(category_id)
    Cache.delete("#{CKP_category}_#{category_id}".to_sym)
  end
  
  
end


