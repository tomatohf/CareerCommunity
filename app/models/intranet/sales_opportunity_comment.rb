module Intranet
  class SalesOpportunityComment < ActiveRecord::Base
    
    acts_as_trashable
    
  
    belongs_to :opportunity, :class_name => "SalesOpportunity", :foreign_key => "opportunity_id"
    belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  
  
    validates_presence_of :opportunity_id, :account_id
    
    validates_presence_of :content, :message => "请输入 内容"
    validates_length_of :content, :maximum => 1000, :message => "内容 超过长度限制", :allow_nil => false
    
    
  end
end
