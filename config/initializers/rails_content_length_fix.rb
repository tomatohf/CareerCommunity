# fix rails X-sendfile bug!  

module ActionController
  class CgiResponse
    def set_content_length!
      @headers["Content-Length"] = @body.size unless @body.respond_to?(:call) || @headers["X-LIGHTTPD-send-file"]
      # @headers["Content-Length"] = @body.size unless @body.respond_to?(:call) || @headers["X-sendfile"]
    end  
  end  
end


