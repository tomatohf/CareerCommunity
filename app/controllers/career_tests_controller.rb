class CareerTestsController < ApplicationController
  
  
  Result_List_Size = 30
  
  
  layout "community"
  
  before_filter :check_login, :only => [:show, :create_result, :result, :history]
  before_filter :check_limited, :only => [:create_result]
  
  before_filter :check_result_owner, :only => [:result]
  before_filter :check_history_owner, :only => [:history]

  
  
  def index
    return jump_to("/career_tests/show/1")
    
    @tests = CareerTest.find(:all)
    
    @has_login = has_login?
  end
  
  def show
    @test_id = params[:id].to_i
    @has_login = has_login?
    @test = CareerTest.get_test(@test_id)
    
    @result_count = CareerTestResult.get_count(@test_id)
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
  
  def history
    @test_id = params[:test_id] && params[:test_id] != "" && params[:test_id].to_i
    account_id = params[:id]
    
    conditions = ["account_id = ?", account_id]
    
    if @test_id && @test_id != ""
      @test = CareerTest.get_test(@test_id)
      conditions = ["account_id = ? and career_test_id = ?", account_id, @test_id]
    end
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @results = CareerTestResult.paginate(
      :page => page,
      :per_page => Result_List_Size,
      :conditions => conditions,
      :order => "created_at DESC"
    )
  end
  
  
  
  private
  
  def check_result_owner
    @result = CareerTestResult.find(params[:id])
    
    jump_to("/errors/forbidden") unless session[:account_id] == @result.account_id
  end
  
  def check_history_owner
    jump_to("/errors/forbidden") unless session[:account_id].to_s == params[:id]
  end
  
end