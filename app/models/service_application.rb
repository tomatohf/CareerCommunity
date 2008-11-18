class ServiceApplication < ActiveRecord::Base
  
  validates_presence_of :service_id
  
  validates_presence_of :real_name, :message => "请输入 姓名"
  validates_presence_of :mobile, :message => "请输入 手机"
  validates_presence_of :email, :message => "请输入 邮箱"
  
end

