#
# Contributors:
#   Tom Fakes    - Initial simple implementation, plugin implementation
#   Dan Kubb     - Handle multiple encodings, correct response headers
#   Sebastian    - Handle component requests
#
begin
  require 'stringio'
  require 'zlib'
  COMPRESSION_DISABLED = false
rescue
  COMPRESSION_DISABLED = true
  RAILS_DEFAULT_LOGGER.info "Output Compression not available: " + $!
end

class OutputCompressionFilter

  def self.filter(controller)
    return if COMPRESSION_DISABLED ||
      controller.response.headers['Content-Encoding'] || 
      controller.request.env['HTTP_ACCEPT_ENCODING'].nil? 
      # Modified by Tomato
      # Comment the *component* related codes
      # to be compatible with Rails 2.3.4
      # ||
      # controller.request.is_component_request?
    begin
      controller.request.env['HTTP_ACCEPT_ENCODING'].split(/\s*,\s*/).each do |encoding|
        # TODO: use "q" values to determine user agent encoding preferences
        case encoding
          when /\Agzip\b/
            StringIO.open('', 'w') do |strio|
              begin
                gz = Zlib::GzipWriter.new(strio)
                gz.write(controller.response.body)
                controller.response.body = strio.string
              ensure
                gz.close if gz
              end
            end
          when /\Adeflate\b/
            controller.response.body = Zlib::Deflate.deflate(controller.response.body, Zlib::BEST_COMPRESSION)
          when /\Aidentity\b/
            # do nothing for identity
          else
            next # the encoding is not supported, try the next one
        end
        controller.logger.info "Response body was encoded with #{encoding}" 
        controller.response.headers['Content-Encoding'] = encoding
        break    # the encoding is supported, stop
      end
    end
    controller.response.headers['Content-Length'] = controller.response.body.length
    if controller.response.headers['Vary'] != '*'
      controller.response.headers['Vary'] = 
        controller.response.headers['Vary'].to_s.split(',').push('Accept-Encoding').uniq.join(',')
    end
    
    
    
    # Added by Tomato
    # to fix the "IE6 doesn't gracefully handle Rails' Cache-Control header ('no-cache') with gzipping" issue
    # See http://www.justsuppose.com/2007/09/more-flash-and-ie-6-gotchas-2032-error.html for more details
    if controller.response.headers['Cache-Control'] == 'no-cache'
      controller.response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate, max-age=-1'
    end
    
  end

end


# Modified by Tomato
# Comment the *component* related codes
# to be compatible with Rails 2.3.4

# # Handle component requests by not compressing the output from a component
# module ActionController
#   # These methods are available in both the production and test Request objects.
#   class AbstractRequest
#     def is_component_request=(val)  #:nodoc:
#       @is_component_request = val
#     end
# 
#     # Returns true when the request corresponds to a render_component call
#     def is_component_request?
#       @is_component_request
#     end
#   end
# end
# 
# # Mark the request as being a Component request
# module ActionController
#   module Components
#     protected
#       # Modified by Tomato
#       # alias :original_request_for_component :request_for_component
#       def request_for_component(options)
#         request_for_component = original_request_for_component(options)
#         request_for_component.is_component_request = true
#         return request_for_component
#       end
#       alias :original_request_for_component :request_for_component
#   end
# end
