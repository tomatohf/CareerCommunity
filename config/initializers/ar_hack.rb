# added by Tomato
# to make active record to expose the method, which can clear the dirty(changed) attributes

module ActiveRecord

  module Dirty
    
    def clean_myself
      changed_attributes.clear
    end
    
  end
  
end