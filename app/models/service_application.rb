class ServiceApplication < ActiveRecord::Base
  
  validates_presence_of :service_id
  
  validates_presence_of :real_name, :message => "请输入 姓名"
  validates_presence_of :mobile, :message => "请输入 手机"
  validates_presence_of :email, :message => "请输入 邮箱"
  
  
  
  named_scope :unclosed, :conditions => { :closed => false }
  named_scope :closed, :conditions => { :closed => true }
  
  
  
  CKP_to_be_notified = :to_be_notified_service_applications
  
  after_save { |service_application|
    applications = self.get_to_be_notified_service_applications
    applications << service_application
    Cache.set(CKP_to_be_notified, applications)
  }
  
  after_destroy { |service_application|
    applications = self.get_to_be_notified_service_applications
    applications.delete_if { |application| application.id == service_application.id }
    Cache.set(CKP_to_be_notified, applications)
  }
  
  
  
  def self.get_to_be_notified_service_applications
    Cache.get(CKP_to_be_notified) || []
  end
  
  def self.clear_to_be_notified_service_applications_cache
    Cache.delete(CKP_to_be_notified)
  end
  
  
end


