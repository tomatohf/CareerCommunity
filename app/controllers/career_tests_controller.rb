class CareerTestsController < ApplicationController
  
  
  Result_List_Size = 30
  
  Sales_Style_Names = ["鼓吹者", "执行", "大使", "顾问"]
  Sales_Style_Colors = %w{6C81B6 D843B3 5DBC5B FF6600}
  
  
  layout "community"
  
  before_filter :check_login_for_career_test, :only => [:show, :create_result, :result]
  before_filter :check_login, :only => [:history]
  before_filter :check_limited, :only => [:create_result]
  
  before_filter :check_result, :only => [:result]
  before_filter :check_history_owner, :only => [:history]

  
  
  def index
    @has_login = has_login?
  end
  
  def show
    @has_login = has_login?
    @test = CareerTest.get_test(@test_id)
  end
  
  def create_result
    return jump_to("/career_tests/show/#{@test_id}") unless request.post?
    
    
    @has_login = has_login?
    @test = CareerTest.get_test(@test_id)
    
    all_filled = true
    answers = {}
    @test.flatten_questions.each do |q|
      question_id = q[0]
      answers[question_id] = params["question_#{question_id}".to_sym]
      all_filled &&= (q[1].kind_of?(Hash) && q[1][:input_type] == :text) ||
                      (answers[question_id] && answers[question_id] != "")
    end
    
    unless all_filled
      flash.now[:answers] = answers
      
      return render(:action => "show")
    end
    
    
    # record the result
    result = CareerTestResult.new(
      :account_id => @has_login ? session[:account_id] : 0,
      :career_test_id => @test_id
    )
    result.fill_answer(answers)

    if result.save
      # record account action
      AccountAction.create_new(session[:account_id], "add_career_test_result", {
        :career_test_id => @test_id,
        :career_test_result_id => result.id,
        :answer => answers
      }) if @has_login
      
      jump_to("/career_tests/result/#{result.id}")    
    else
      flash.now[:answers] = answers
      flash.now[:error_msg] = "操作失败, 再试一次吧"
      
      return render(:action => "show")
    end
    
  end
  
  def result
    @has_login = has_login?
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
  
  
  def sales_style_chart
    chart_type = params[:chart_type]
    counts = params[:id].split("_")
    
    series = []
    categories = []
    colors = []
    
    styles = Sales_Style_Names
    1.upto(4) do |i|
      count = (counts[i-1].to_f)/100
      
      series << count
      
      # 65.chr = A
      categories << "#{(i - 1 + 65).chr}: #{count}"
      colors << Sales_Style_Colors[i-1]
    end
    
    graph  = get_graph(chart_type)
    graph.add(:axis_category_text, categories)
    graph.add(:series, "series legend label", series)
    graph.add(:theme, "vote")
    graph.add(:user_data, :colors, colors.join(","))
    graph.add(:user_data, :delay_count, series.size - 1)
    
    render(:xml => graph.to_xml)
  end
  
  
  
  private
  
  def check_login_for_career_test
    @test_id = if action_name == "result"
      @result = CareerTestResult.find(params[:id])
      @result.career_test_id
    else
      params[:id].to_i
    end
    
    t = CareerTest.find(@test_id)
    return jump_to("/career_tests") unless t
    
    check_login unless t[:hide]
  end
  
  def check_result
    jump_to("/errors/forbidden") unless @result.account_id == 0 ||
                                        @result.account_id == session[:account_id]
  end
  
  def check_history_owner
    jump_to("/errors/forbidden") unless session[:account_id].to_s == params[:id]
  end
  
  
  def get_graph(chart_type, chart_id = "vote_result")
    chart_title = "类型构成"
    case chart_type
      when "pie"
        graph = Ziya::Charts::Pie.new(nil, chart_title, chart_id)
      when "pie_3d"
        graph = Ziya::Charts::Pie3D.new(nil, chart_title, chart_id)
      else
        graph = Ziya::Charts::Pie.new(nil, chart_title, chart_id)
    end
    graph
  end
  
end