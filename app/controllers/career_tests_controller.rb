class CareerTestsController < ApplicationController
  
  
  layout "community"
  
  before_filter :check_login, :only => []
  before_filter :check_limited, :only => []

  
  
  def index
    @tests = CareerTest.find(:all)
  end
  
  def show
    
  end
  
  
  
  private
  
  def private_method
    
  end
  
end