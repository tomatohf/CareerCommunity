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
# to fix the boolean not being converted to int bug,
# the boolean value true/false can NOT be used to pack

module Riddle
  class Client
    class Message
      
      alias original_append_int append_int
      
      def append_int(int)
        int = int.to_i rescue (int ? 1 : 0)
        
        original_append_int(int)
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


# added by Tomato
# 
# to set "SET NAMES utf8" sql_query_pre for delta index
#
# and remove the sql_query_info value from config file,
# since it's just used for CLI and debug
# and would increase db SQL queries during indexing

module ThinkingSphinx
  class Source
    module SQL

      alias original_sql_query_pre_for_delta sql_query_pre_for_delta
      
      def sql_query_pre_for_delta
        original_sql_query_pre_for_delta << "SET NAMES utf8"
      end
      
      
      def to_sql_query_info(offset)
        nil
      end
      
    end
  end
end
