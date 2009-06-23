class CareerTestsController < ApplicationController
  
  
  layout "community"
  
  before_filter :check_login, :only => [:result]
  before_filter :check_limited, :only => [:result]

  
  
  def index
    @tests = CareerTest.find(:all)
  end
  
  def show
    @test_id = params[:id].to_i
    @has_login = has_login?
    @test = CareerTest.get_test(@test_id)
  end
  
  def result
    @test_id = params[:id]
    
    return jump_to("/career_tests/show/#{@test_id}") unless request.post?
    
    
  end
  
  
  
  private
  
  #def private_method
  #  
  #end
  
end