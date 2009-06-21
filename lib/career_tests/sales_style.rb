module CareerTests
  
  class SalesStyle < CareerTests::Base
    
    def name
      "销售风格测试"
    end
    
    def questions
      
    end
    
    def display_title(index, title)
      %Q!
        <b>情景 #{index+1}</b>
        -
        #{title}
      !
    end
    
  end

end

