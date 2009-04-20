class BooleanType < GoalFollowType::Base

  def get_name
    "Boolean"
  end
  
  def display_input(param_name, element_id, value = 1)
    element_id ||= param_name
      
    %Q{
        <input type="checkbox" id="#{element_id}" name="#{param_name}" value="1"#{" checked=\"checked\"" if value > 0} />
      }
    end
    
    def display_show(value)
      if value > 0
        %Q{
          <input type="checkbox" onclick="return false;" checked="true" />
        }
      else
        %Q{
          <input type="checkbox" onclick="return false;" />
        }
      end
    end
  
end

