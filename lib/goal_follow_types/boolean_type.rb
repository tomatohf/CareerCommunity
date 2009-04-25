module GoalFollowTypes
  
  class BooleanType < Base

    def get_name
      "Boolean"
    end
  
    def display_input(param_name, element_id, value = 1)
      element_id ||= param_name
      
      %Q{
          <input id="#{element_id}_checkbox" type="checkbox"#{" checked=\"checked\"" if value > 0} onclick="document.getElementById('#{element_id}').value = this.checked ? 1 : 0;" />
          <label for="#{element_id}_checkbox">
            我做到了
          </label>
          <input type="hidden" name="#{param_name}" id="#{element_id}" value="#{value}" />
        }
      end
    
      def display_show(value, options = {})
        %Q{
          <input type="checkbox" onclick="return false;"#{ " checked=\"true\"" if value > 0} />
        }
      end
  
  end
  
end

