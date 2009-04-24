module GoalFollowTypes
  
  @@types = [
    "boolean_type",
    "number_type",
    "rank_type"
  ]
  
  

  class TypeFactory
    # it should be a singleton class, only one copy of instance can exist
    # And get the only instance by invoking class method instance(), for example: TypeFactory.instance
    include Singleton
    
    def get_type(key)
      "GoalFollowTypes::#{key.to_s.capitalize}Type".constantize.new
    end    
  end
  
  
  
  def self.get_factory
    TypeFactory.instance
  end
  
  def self.get_type(key)
    get_factory.get_type(key)
  end
  
  
  
  # Please ensure all its sub-classes are named as following pattern:
  # <key_name> + "Type"
  # Then it can be found out by TypeFactory.
  # For example, if you want assign the key "rank" to your type implementation class,
  # you should name your class as "RankType".
  # Refer to the get_type method of TypeModule::TypeFactory class
  # to get detail information
  class Base
  
    def get_name
      self.class
    end
    
    def display_input(param_name, element_id, value = nil)
      element_id ||= param_name
      
      %Q!
        <input type="text" id="#{element_id}" name="#{param_name}" value="#{value}" class="text_field" />
      !
    end
    
    def display_show(value, options = {})
      value
    end
  
  end
  
  
  @@types.each { |file| require_dependency "goal_follow_types/#{file}" }

end

