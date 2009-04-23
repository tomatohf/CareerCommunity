module GoalFollowTypes
  
  class BooleanType < Base

    def get_name
      "Boolean"
    end
  
    def display_input(param_name, element_id, value = 1)
      element_id ||= param_name
      
      %Q{
          <input type="checkbox" id="#{element_id}" name="#{param_name}" value="1"#{" checked=\"checked\"" if value > 0} />
          <label for="#{element_id}">
            我做到了
          </label>
        }
      end
    
      def display_show(value)
        %Q{
          <input type="checkbox" onclick="return false;"#{ " checked=\"true\"" if value > 0} />
        }
      end
  
  end
  
end

