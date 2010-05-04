module Intranet
  class SalesOpportunity < ActiveRecord::Base
  
    acts_as_trashable
  
  
    belongs_to :contact, :class_name => "SalesContact", :foreign_key => "contact_id"
  
    has_many :step_records, :class_name => "SalesOpportunityStepRecord", :foreign_key => "opportunity_id", :dependent => :destroy
    has_many :records, :class_name => "SalesOpportunityRecord", :foreign_key => "opportunity_id", :dependent => :destroy
  
  
    validates_presence_of :status_id
    
    validates_presence_of :contact_id, :message => "请输入 客户"
  
    validates_length_of :title, :maximum => 50, :message => "标题 超过长度限制", :allow_nil => true
  
  
  end
end
