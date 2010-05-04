module Intranet
  class SalesOpportunityStepRecord < ActiveRecord::Base
  
    belongs_to :opportunity, :class_name => "SalesOpportunity", :foreign_key => "opportunity_id"
  
  
    validates_presence_of :opportunity_id, :step_id
    
    validates_length_of :notes, :maximum => 1000, :message => "备注 超过长度限制", :allow_nil => true
  
  
    def get_record(opportunity_id, step_id)
      self.find(
        :first,
        :conditions => ["opportunity_id = ? and step_id = ?", opportunity_id, step_id]
      ) || self.new(
        :opportunity_id => opportunity_id,
        :step_id => step_id
      )
    end
    
  end
end
