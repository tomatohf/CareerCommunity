class TalksController < ApplicationController
  
  layout "community"
  before_filter :check_login, :only => []
  before_filter :check_limited, :only => []
  
  
  
  def index
    
  end
  
end

