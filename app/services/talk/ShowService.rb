require "weborb/context"
require "rbconfig"

class ShowService
  
  def show(talk_id)
    talk= Talk.get_talk(talk_id)
    
    talk_content = {}
    
    talk_content[:title] = talk.title
    talk_content[:desc] = talk.get_info[:desc]
    
    talk_content
    
  end
  
end


