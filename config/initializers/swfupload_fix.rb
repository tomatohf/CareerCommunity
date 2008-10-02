# The following code is a work-around for the Flash 8 bug that prevents our multiple file uploader
# from sending the _session_id_4_swf.  Here, we hack the Session#initialize method and force the session_id



class CGI::Session
  alias original_initialize initialize
  def initialize(request, option = {})
    session_key = "_session_id_4_swf" #option['session_key'] || '_session_id_4_swf'
    query_string = if (qs = request.env_table["QUERY_STRING"]) and qs != ""
      qs
    elsif (ru = request.env_table["REQUEST_URI"][0..-1]).include?("?")
      ru[(ru.index("?") + 1)..-1]
    end
    if query_string and query_string.include?(session_key)
      option["session_id"] = query_string.scan(/#{session_key}=(.*?)(&.*?)*$/).flatten.first
      #option['session_data'] = option["session_id"]
    end
    original_initialize(request, option)
  end
end
