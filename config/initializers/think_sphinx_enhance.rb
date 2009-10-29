require "thinking_sphinx"


# added by Tomato
# 
# to make thinking sphinx recognize the parameter: charset_dictpath
# and build its value into sphinx configure file
# 
# we have to use this kind of *hack* way
# since *charset_dictpath* is not a sphinx parameter, but a Coreseek's
# for Chinese word segmentation

module Riddle
  class Configuration
    class Section
      
      alias original_settings_body settings_body
      
      private
      
      def settings_body
        charset_dictpath = if ThinkingSphinx::Configuration.environment == "production"
          "/home/tomato/websites/app/CareerCommunity/shared/sphinx/dict"
        else
          "/Users/tomato/Dev/git/projects/CareerCommunity/db/sphinx/dict"
        end
        
        if self.class.name == "Riddle::Configuration::Index"
          original_settings_body << "  charset_dictpath = #{charset_dictpath}"
        else
          original_settings_body
        end
      end
      
    end
  end
end


# added by Tomato
# 
# to expose the riddle client object

module ThinkingSphinx
  
  class Search
    
    public :client
    
    def get_client
      self.client
    end
    
  end
  
end


# added by Tomato
# 
# to prevent think sphinx creating singleton class for search resule object.
# it will break the Marshal.dump method,
# which is required by session and active record deep copy

module ThinkingSphinx
  
  class Search
    
    def add_excerpter
      # just do nothing ...
    end
    
    def add_sphinx_attributes
      # just do nothing ...
    end
    
  end
  
end
