require 'cgi'

module Ziya
  module Helper  
        
    XML_SWF = "/charts/charts.swf?library_path=/charts/charts_library&xml_source=%s" unless defined? XML_SWF
      
    # -------------------------------------------------------------------------------------
    # Generates chart object tag with given url to fetch the xml data  
    # -------------------------------------------------------------------------------------            
    def ziya_chart( url, chart_options = {} )
      options = { :width          => "400",
                  :height         => "300",
                  :bgcolor        => "transparent",
                  :align          => "left",
                  :class          => "",
                  :id             => "ziya_chart",
                  :library_path   => "/charts/charts_library",
                  :charts_path    => "/charts/charts.swf",
                  :style          => "border: none; display: inline;"
                }.merge!(chart_options)

      # Escape url
      url = CGI.escape( url.gsub( /&amp;/, '&' ) )

      if options[:bgcolor] != 'transparent'
        color_param = content_tag( 'param', nil, :name => 'bgcolor', :value => options[:bgcolor] )
      else
        color_param = content_tag( 'param', nil, :name  => "wmode", :value => "transparent" )
      end

      content_tag( 'object',
        content_tag( 'param', nil,
         :name  => "movie",
         :value => XML_SWF % url ) +
        content_tag( 'param', nil,
         :name  => "quality",
         :value => "high" )  +
        color_param,
        :type => 'application/x-shockwave-flash',
        :data => XML_SWF % url,
        :width => options[:width], :height => options[:height], :id => options[:id] )
    end     
                        
    # -------------------------------------------------------------------------------------
    # Generate chart tag with given action name for fetch the xml data  
    # IMPORTANT THIS CALL WILL BE DEPRECATED - Use ziya_chart instead
    # -------------------------------------------------------------------------------------
    def gen_chart( id, source_name, bgcolor, width, height )
      RAILS_DEFAULT_LOGGER.error "WARNING !! gen_chart will be deprecated. Please use ziya_chart instead"
      
      source_name = CGI.escape( source_name.gsub( /&amp;/, '&' ) )
      content_tag( 'object', 
      content_tag( 'param', nil, 
       :name  => "movie", 
       :value => "/charts/charts.swf?library_path=/charts/charts_library&xml_source=#{source_name}" ) +
      content_tag( 'param', nil, 
         :name  => "quality", 
         :value => "high" ) +
      content_tag( 'param', nil, 
         :name  => "bgcolor", 
         :value => "#{bgcolor}" ) +
      content_tag( 'param', nil, 
         :name  => "border", 
         :value => "0px" ) +
      content_tag( 'embed', nil, 
       :src    => "/charts/charts.swf?library_path=/charts/charts_library&xml_source=#{source_name}",
       :quality       => 'high', 
       :bgcolor       => bgcolor, 
       :width         => "#{width}", 
       :height        => "#{height}", 
       :name          => id, 
       :swLiveConnect => "true", 
       :type          => "application/x-shockwave-flash",
       :pluginspage   => "http://www.macromedia.com/go/getflashplayer"),
       :classid       => "clsid:D27CDB6E-AE6D-11cf-96B8-444553540000",
       :codebase      => "http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0",
       :width         => "#{width}", 
       :height        => "#{height}", 
       :style         => "border:none;display:inline",
       :id            => id )
    end                                    
  end
end