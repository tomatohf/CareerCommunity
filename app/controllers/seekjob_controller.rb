class SeekjobController < ApplicationController
  
  def index
    jump_to("/seekjob/pharmaceutical")
  end
  
  def pharmaceutical
    @industry_name = "医药行业"
    
    @recruitments = Recruitment.search(
      "医药 | 医疗 | 制药 | 医 | 药",
      :page => 1,
      :per_page => 30,
      :match_mode => :extended,
      :order => "publish_time DESC, @relevance DESC",
      :field_weights => {
        :title => 8,
        :content => 8,
        :location => 6,
        :recruitment_type => 6,
        :recruitment_tags_name => 8
      }
    ) if params[:id] == "recruitment"
    
    dispatch_action
  end
  
  
  
  private
  
  def dispatch_action
    @perspective = params[:id]
    @perspective ||= "industry"
    
    render :action => "industry"
  end
  
end
