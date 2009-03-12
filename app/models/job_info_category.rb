class JobInfoCategory < ActiveRecord::Base
  
  has_and_belongs_to_many :job_infos,
                          :foreign_key => "job_info_category_id",
                          :association_foreign_key => "job_info_id",
                          :join_table => "job_infos_job_info_categories"
                          
                          
  
  validates_presence_of :name, :message => "请输入 名称"
  
  validates_uniqueness_of :name, :case_sensitive => false, :scope => :parent_category_id, :message => "名称 已经存在"
  
  validates_length_of :name, :maximum => 250, :message => "名称 超过长度限制", :allow_nil => false
  validates_length_of :desc, :maximum => 1000, :message => "描述 超过长度限制", :allow_nil => true
  
  
  
  CKP_all_categories = :all_job_info_categories
  CKP_category = :job_info_category
  
  after_destroy { |category|
    self.clear_category_cache(category.id)
    
    self.clear_all_categories_cache
  }
  
  after_save { |category|
    self.set_category_cache(category)
    
    self.clear_all_categories_cache
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


