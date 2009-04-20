class RankType < GoalFollowType::Base
  
  def get_name
    "Rank"
  end
  
  def display_input(param_name, element_id= nil, value = 3)
    element_id ||= param_name
    
    lis = ""
    5.times do |i|
      num = i+1
      lis += %Q!
        <li>
          <a href="#" class="star_#{num}" onclick="document.getElementById('#{element_id}').value=#{num}; document.getElementById('#{element_id}_current').style.width='#{num*100/5}%'; return false;">
            #{num}</a>
        </li>
      !
    end
    
    
      
    %Q!
        <a href="#" onclick="document.getElementById('#{element_id}').value=0; document.getElementById('#{element_id}_current').style.width='0%';">
          <img src="/images/leftest_arrow.jpg" border="0" /></a>
        <span class="inline-rating">
    		  <ul class="star-rating">
    			  <li class="current-rating" id="#{element_id}_current" style="width:#{value*100/5}%;">当前: #{value}</li>
    			  #{lis}
    		  </ul>
    		</span>
    		<input type="hidden" name="#{param_name}" id="#{element_id}" value="#{value}" />
      !
  end
    
  def display_show(value, small = false)
    ApplicationController.helpers.rank(value, :readonly => true, :small => small)
  end
  
end

