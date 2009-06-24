class CareerTestsController < ApplicationController
  
  
  layout "community"
  
  before_filter :check_login, :only => [:create_result, :result]
  before_filter :check_limited, :only => [:create_result]
  
  before_filter :check_result_owner, :only => [:result]

  
  
  def index
    @tests = CareerTest.find(:all)
  end
  
  def show
    @test_id = params[:id].to_i
    @has_login = has_login?
    # TODO - handle whether the user has loged in ...
    @test = CareerTest.get_test(@test_id)
  end
  
  def create_result
    @test_id = params[:id].to_i
    
    return jump_to("/career_tests/show/#{@test_id}") unless request.post?
    
    
    @test = CareerTest.get_test(@test_id)
    
    all_filled = true
    answers = {}
    @test.question_ids.each do |question_id|
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

    if result.save
      # record account action
      AccountAction.create_new(session[:account_id], "add_career_test_result", {
        :career_test_id => @test_id,
        :career_test_result_id => result.id,
        :answer => answers
      })
      
      jump_to("/career_tests/result/#{result.id}")    
    else
      flash.now[:answers] = answers
      flash.now[:error_msg] = "操作失败, 再试一次吧"
      
      @has_login = has_login?
      
      return render(:action => "show")
    end
    
  end
  
  def result
    @test = CareerTest.get_test(@result.career_test_id)
    @result_info = @test.process_answer(@result.get_answer)
  end
  
  
  
  private
  
  def check_result_owner
    @result = CareerTestResult.find(params[:id])
    
    jump_to("/errors/forbidden") unless session[:account_id] == @result.account_id
  end
  
end