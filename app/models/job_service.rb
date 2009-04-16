class JobService < ActiveRecord::Base
  
  acts_as_trashable
  
  
  
  include CareerCommunity::Util
  
  
  
  has_and_belongs_to_many :functions,
                          :foreign_key => "job_service_id",
                          :association_foreign_key => "function_id",
                          :join_table => "job_services_functions",
                          :class_name => "JobServiceFunction"
  
  
  
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
  
  
  
  FCKP_top_services = :fc_top_services
  
  after_destroy { |job_service|
    PointProfile.adjust_account_points_by_action(job_service.creator_id, :add_job_service, false)
    
    self.clear_top_services_cache(job_service.category_id)
  }
  
  after_create { |job_service|
    PointProfile.adjust_account_points_by_action(job_service.creator_id, :add_job_service, true)
  }
  
  after_save { |job_service|
    self.clear_top_services_cache(job_service.category_id)
  }
  
  def self.clear_top_services_cache(category_id)
    Cache.delete(expand_cache_key("#{FCKP_top_services}_#{category_id}"))
  end
 
end


