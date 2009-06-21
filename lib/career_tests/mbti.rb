module CareerTests
  
  class Mbti < Base
    
    def name
      "MBTI 行为风格测试"
    end
    
    def questions
      
    end
    
    def display_title(index, title)
      %Q!
        <b>#{index+1}.</b>
        #{title}
      !
    end
    
  end

end

