class GroupPost < ActiveRecord::Base
  
  include CareerCommunity::AccountBelongings
  
  has_many :comments, :class_name => "GroupPostComment", :foreign_key => "group_post_id", :dependent => :destroy
  
  belongs_to :group, :class_name => "Group", :foreign_key => "group_id"
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  
  
  validates_presence_of :account_id, :group_id
  
  validates_presence_of :title, :message => "请输入 标题"
  validates_presence_of :content, :message => "请输入 内容"
  
  validates_length_of :title, :maximum => 256, :message => "标题 超过长度限制", :allow_nil => false
  
end