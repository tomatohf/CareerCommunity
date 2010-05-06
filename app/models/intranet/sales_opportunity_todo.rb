module Intranet
  class SalesOpportunityTodo < ActiveRecord::Base
    
    belongs_to :opportunity, :class_name => "SalesOpportunity", :foreign_key => "opportunity_id"
  
  
    validates_presence_of :opportunity_id
    
    validates_presence_of :title, :message => "请输入 事项"
    validates_length_of :title, :maximum => 100, :message => "事项 超过长度限制", :allow_nil => false
    
    
  end
end
