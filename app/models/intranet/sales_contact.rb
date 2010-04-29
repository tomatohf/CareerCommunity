module Intranet
  class SalesContact < ActiveRecord::Base
  
    acts_as_trashable
  
  
    belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
    belongs_to :account, :class_name => "Account", :foreign_key => "updated_by"
  
    has_many :opportunities, :class_name => "SalesOpportunity", :foreign_key => "contact_id", :dependent => :destroy
  
  
    define_index do
      # fields
      indexes name, company, title, mobile, phone, fax, email, address, zip, notes

      # attributes
      has gender
    
      set_property :delta => true
    
      # set_property :field_weights => {:field => number}
    end
  
  
    validates_presence_of :account_id, :updated_by
  
    validates_presence_of :name, :message => "请输入 姓名"
    validates_length_of :name, :maximum => 25, :message => "姓名 超过长度限制", :allow_nil => false
  
    validates_length_of :company, :maximum => 50, :message => "公司 超过长度限制", :allow_nil => true
    validates_length_of :title, :maximum => 25, :message => "职位 超过长度限制", :allow_nil => true
  
    validates_length_of :mobile, :maximum => 20, :message => "手机 超过长度限制", :allow_nil => true
    validates_length_of :phone, :maximum => 20, :message => "电话 超过长度限制", :allow_nil => true
    validates_length_of :fax, :maximum => 20, :message => "传真 超过长度限制", :allow_nil => true
    validates_length_of :email, :maximum => 250, :message => "电子邮件 超过长度限制", :allow_nil => true
  
    validates_length_of :address, :maximum => 250, :message => "地址 超过长度限制", :allow_nil => true
    validates_length_of :zip, :maximum => 10, :message => "邮编 超过长度限制", :allow_nil => true
  
    validates_length_of :notes, :maximum => 1000, :message => "备注 超过长度限制", :allow_nil => true
  
  
  end
end
