# added by Tomato
# to make thinking sphinx recognize the parameter: charset_dictpath
# and build its value into sphinx configure file

module ThinkingSphinx
  
  class Configuration
    attr_accessor :charset_dictpath
    
    alias original_core_index_for_model core_index_for_model
    alias original_distributed_index_for_model distributed_index_for_model
    
    private
    def core_index_for_model(model, sources)
      output = original_core_index_for_model(model, sources)
      
      insert_parameter_by_tomato(output, :charset_dictpath)
    end
    
    def distributed_index_for_model(model)
      output = original_distributed_index_for_model(model)
      
      insert_parameter_by_tomato(output, :charset_dictpath)
    end
    
    def insert_parameter_by_tomato(output, param, before = "}")
      position = output.rindex(before)
      output.insert(position, "#{param} = #{self.send(param)}\n")
    end
    
  end
  
  # to fix the "sql_query_pre = SET NAMES utf8" issue
  class Index
    
    alias original_to_config to_config

    def to_config(index, database_conf, charset_type)
      config = original_to_config(index, database_conf, charset_type)
      config.gsub!("#", "\\#")
      
      insert_value_by_tomato(config, "sql_query_pre = SET NAMES utf8\n") if charset_type =~ /utf-8/
    end

    def insert_value_by_tomato(config, value, before = "}")
      config.gsub(before, "#{value}\n#{before}")
    end
    
  end
  
end