module Intranet
  class SalesOpportunityRecord < ActiveRecord::Base
    
    acts_as_trashable
    
  
    belongs_to :opportunity, :class_name => "SalesOpportunity", :foreign_key => "opportunity_id"
  
  
    validates_presence_of :opportunity_id
    
    validates_presence_of :occur_at, :message => "请输入 时间"
    
    validates_presence_of :notes, :message => "请输入 内容"
    validates_length_of :notes, :maximum => 1000, :message => "内容 超过长度限制", :allow_nil => false
    
    
  end
end
