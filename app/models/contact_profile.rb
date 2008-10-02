class ContactProfile < ActiveRecord::Base
  
  include CareerCommunity::AccountBelongings

  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"

  # ---

  validates_presence_of :account_id
  
  validates_length_of :qq, :maximum => 20, :message => "QQ 超过长度限制", :allow_nil => true
  validates_length_of :mobile, :maximum => 25, :message => "手机 超过长度限制", :allow_nil => true
  validates_length_of :phone, :maximum => 25, :message => "电话 超过长度限制", :allow_nil => true
  
  
end
