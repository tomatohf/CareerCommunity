class SeekjobController < ApplicationController
  
  def index
    jump_to("/seekjob/pharmaceutical")
  end
  
  def pharmaceutical
    @industry_name = "医药行业"
    dispatch_action
  end
  
  
  
  private
  
  def dispatch_action
    @perspective = params[:id]
    @perspective ||= "company"
    
    render :action => "industry"
  end
  
end
