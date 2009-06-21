module CareerTests
  
  class Base
    include Singleton
    
    def name
      ""
    end
    
    def questions
      # array as the container hold the items in their display order ...
      
      # category item format => [category_title, category_desc, questions_in_this_category]
      # question item format => [internal_id, question_title, question_options_array]
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
    
    def display_title(index, title)
      "#{index+1} - #{title}"
    end
    
  end
  
  CareerTest.find(:all).each { |file| require_dependency "career_tests/#{file}" }

end

