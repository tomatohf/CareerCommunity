class GroupBookmark < ActiveRecord::Base
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :group, :class_name => "Group", :foreign_key => "group_id"
  
  
  validates_presence_of :account_id, :group_id
  
  validates_presence_of :title, :message => "请输入 标题"
  validates_presence_of :url, :message => "请输入 地址"
  
  validates_length_of :title, :maximum => 250, :message => "标题 超过长度限制", :allow_nil => false
  
  validates_length_of :desc, :maximum => 1000, :message => "描述 超过长度限制", :allow_nil => true
  
  
  
end


