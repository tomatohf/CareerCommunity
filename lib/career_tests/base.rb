module CareerTests
  
  class Base
    include Singleton
    
    def name
      ""
    end
    
    def desc
      ""
    end
    
    def questions
      # array as the container hold the items in their display order ...
      
      # category item format => [category_title, category_desc, questions_in_this_category]
      # question item format => [internal_id, question_title, options_of_this_question]
      # question option item format => [internal_id, option_title]
      
      [
        [
          "",
          "",
          [
            10, # use 10, 20, 30 ...
            "",
            [
              10,
              ""
            ]
          ]
        ]
      ]
    end
    
    def display_question_title(index, title)
      "#{index+1} - #{title}"
    end
    
    def display_category_title(index, title)
      display_question_title(index, title)
    end
    
    def category_title_bg_color
      "FFFFFF"
    end
    
    def display_option_title(index, title)
      title
    end
    
  end
  
  CareerTest.find(:all).each { |file| require_dependency "career_tests/#{file}" }

end

