class JobService < ActiveRecord::Base
  
  acts_as_trashable
  
  
  
  include CareerCommunity::Util
  
  
  
  belongs_to :creator, :class_name => "Account", :foreign_key => "creator_id"
  belongs_to :updater, :class_name => "Account", :foreign_key => "updater_id"
  
  belongs_to :category, :class_name => "JobServiceCategory", :foreign_key => "category_id"
  
  has_many :evaluations, :class_name => "JobServiceEvaluation", :foreign_key => "job_service_id", :dependent => :destroy
  
  
  
  validates_presence_of :name, :message => "请输入 名称"
  validates_presence_of :category_id, :message => "请选择 分类"
  
  validates_length_of :name, :maximum => 250, :message => "名称 超过长度限制", :allow_nil => false
  
  validates_length_of :url, :maximum => 250, :message => "链接 超过长度限制", :allow_nil => true
  validates_length_of :place, :maximum => 250, :message => "地点 超过长度限制", :allow_nil => true
  validates_length_of :desc, :maximum => 1000, :message => "简介 超过长度限制", :allow_nil => true
  validates_length_of :phone, :maximum => 250, :message => "电话 超过长度限制", :allow_nil => true
  validates_length_of :scope, :maximum => 250, :message => "服务范围 超过长度限制", :allow_nil => true
  
  validates_numericality_of :cost, :message => "价位 必须是大于等于0的数字", :allow_nil => true, :greater_than_or_equal_to => 0
  
  
  
  named_scope :free, :conditions => ["cost <= ?", 0]
  
  
  
  CKP_job_service = :job_service
  
  CKP_place_point = :job_service_place_point
  
  FCKP_top_services = :fc_top_services
  
  after_destroy { |job_service|
    self.clear_job_service_cache(job_service.id)
    
    PointProfile.adjust_account_points_by_action(job_service.creator_id, :add_job_service, false)
    
    self.clear_top_services_cache(job_service.category_id)
    
    self.clear_place_point_cache(job_service.id)
  }
  
  after_create { |job_service|
    PointProfile.adjust_account_points_by_action(job_service.creator_id, :add_job_service, true)
  }
  
  after_save { |job_service|
    self.clear_top_services_cache(job_service.category_id)
    
    self.clear_place_point_cache(job_service.id) if job_service.place_changed?
    
    # clear changed attributes, before we cache it ...
    job_service.clean_myself
    self.set_job_service_cache(job_service)
  }
  
  def self.clear_top_services_cache(category_id)
    Cache.delete(expand_cache_key("#{FCKP_top_services}_#{category_id}"))
  end
  
  
  
  def self.get_job_services_by_category_with_order(category_id)
    query = "SELECT job_services.id, name, url, AVG(job_service_evaluations.point) as average, COUNT(*) as count"
    query << " FROM job_services LEFT OUTER JOIN job_service_evaluations"
    query << " ON job_services.id = job_service_evaluations.job_service_id"
    query << " WHERE job_services.category_id = #{category_id}"
    query << " GROUP BY job_services.id"
    # query << " ORDER BY average DESC, count DESC"
    # do the sort in rails, but not mysql(DB)
    
    self.find_by_sql(query).sort { |x, y|
      x_avg = (x.average || 0).to_f
      y_avg = (y.average || 0).to_f
      
      x_count = (x.count || 0).to_f
      y_count = (y.count || 0).to_f
      
      (x_avg == y_avg) ? (y_count <=> x_count) : (y_avg <=> x_avg)
    }
  end
  
  def self.get_job_service(job_service_id)
    js = Cache.get("#{CKP_job_service}_#{job_service_id}".to_sym)
    
    unless js
      js = self.find(job_service_id)
      
      self.set_job_service_cache(js)
    end
    js
  end
  
  def self.set_job_service_cache(job_service)
    Cache.set("#{CKP_job_service}_#{job_service.id}".to_sym, job_service.clear_association, Cache_TTL)
  end
  
  def self.clear_job_service_cache(job_service_id)
    Cache.delete("#{CKP_job_service}_#{job_service_id}".to_sym)
  end
  
  
  def self.get_place_point(job_service_id)
    Cache.get("#{CKP_place_point}_#{job_service_id}".to_sym)
  end
  
  def self.set_place_point(job_service_id, point_x, point_y)
    Cache.set("#{CKP_place_point}_#{job_service_id}".to_sym, [point_x, point_y])
  end
  
  def self.clear_place_point_cache(job_service_id)
    Cache.delete("#{CKP_place_point}_#{job_service_id}".to_sym)
  end
  
  
  def clear_association
    copy = deep_copy(self)
    copy.clear_association_cache
    copy.clear_aggregation_cache
    copy
  end
 
end


