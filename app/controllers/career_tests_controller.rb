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
    # TODO - handle whether the user has loged in ...
    @test = CareerTest.get_test(@test_id)
  end
  
  def result
    @test_id = params[:id].to_i
    
    return jump_to("/career_tests/show/#{@test_id}") unless request.post?
    
    
    @test = CareerTest.get_test(@test_id)
    
    question_ids = []
    @test.questions.each do |category|
      category[2..-1].each do |question|
        question_ids << question[0]
      end
    end
    
    all_filled = true
    answers = {}
    question_ids.each do |question_id|
      answers[question_id] = params["question_#{question_id}".to_sym]
      all_filled &&= answers[question_id] && answers[question_id] != ""
    end
    
    unless all_filled
      flash.now[:answers] = answers
      
      @has_login = has_login?
      
      return render(:action => "show")
    end
    
    
    # record the result
    result = CareerTestResult.new(
      :account_id => session[:account_id],
      :career_test_id => @test_id
    )
    result.fill_answer(answers)
    result.save
    
    
    # record account action
    AccountAction.create_new(session[:account_id], "add_career_test_result", {
      :career_test_id => @test_id
    })
    
  end
  
  
  
  private
  
  #def private_method
  #  
  #end
  
end