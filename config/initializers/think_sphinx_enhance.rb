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
  
end