class VotesController < ApplicationController
  
  layout "community"
  before_filter :check_login, :only => []
  before_filter :check_limited, :only => []
  
  
  
  def index
    jump_to("/votes/latest")
  end
  
  def latest
    @page_title = "最新投票话题"
    
    render :action => "topic_list"
  end
  
  def hotest
    @page_title = "最热投票话题"
    
    render :action => "topic_list"
  end
  
  
  
end  
  
  