# The following code is a work-around for the Flash 8 bug that prevents our multiple file uploader
# from sending the _session_id_4_swf.
# Here, we use a middleware to prepare the session_id for flash



class FlashSessionCookieMiddleware

  def initialize(app)
    @app = app
    @swf_session_key = "_session_id_4_swf"
  end

  def call(env)
    if env["HTTP_USER_AGENT"] =~ /^(Adobe|Shockwave) Flash/
      params = Rack::Request.new(env).params
      unless params[@swf_session_key].nil?
        env["HTTP_COOKIE"] = "#{ActionController::Base.session_options[:key]}=#{params[@swf_session_key]}".freeze
      end
    end

    @app.call(env)
  end
  
end
