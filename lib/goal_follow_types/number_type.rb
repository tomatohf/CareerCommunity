module GoalFollowTypes

  class NumberType < Base

    def get_name
      "Numerical"
    end
    
    
    def display_input(param_name, element_id, value = 3)
      element_id ||= param_name
      
      %Q!
        <input type="text" id="#{element_id}" name="#{param_name}" value="#{value}" size="5" class="text_field" style="padding: 2px 5px; margin-right: 10px;" />
        (填写完成的数量, 只能输入 <b>数字</b>)
      !
    end
    
    def display_show(value, options = {})
      small = options[:small] && true
      
      %Q!
        <span class="point_number">
  				#{sprintf("%.2f", value).gsub(/^([0-9])/, small ? "<span style='font-size: 16px;'>\\1</span>" : "<strong>\\1</strong>")}
  			</span>
      !
    end
  
  end
  
end

