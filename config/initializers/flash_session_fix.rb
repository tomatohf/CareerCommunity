# Flash does not send the cookie of session id to server
# which will fail the swf upload.
#
# Here, we hack the Rails session related code to work around the issue
# by sending session id via request parameter using the name "_session_id_4_swf"



module ActionController
  module Session
    class AbstractStore
      
      private
        
        # def load_session(env)
        #   request = Rack::Request.new(env)
        #   sid = request.cookies[@key]
        #   unless @cookie_only
        #     sid ||= request.params[@key]
        #   end
        #   sid, session = get_session(env, sid)
        #   [sid, session]
        # end
        
        alias original_load_session load_session
        
        def load_session(env)
          if env["HTTP_USER_AGENT"] =~ /Flash/
            request = Rack::Request.new(env)
            params = request.params
            session_id = params["_session_id_4_swf"]
            
            unless (session_id.nil? || session_id == "")
              env["HTTP_COOKIE"] ||= ""
              env["HTTP_COOKIE"] += ";" unless env["HTTP_COOKIE"] == ""
              
              env["HTTP_COOKIE"] += "#{@key}=#{session_id}"
            end
          end
          
          original_load_session(env)
        end
      
    end
  end
end