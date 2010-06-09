module StaticModel
  
  class StringBase
    
    def self.all
      []
    end

    def self.find(id)
      id ? ((id.to_s == "all") ? all : all[id-1]) : ""
    end
    
  end
  
  
  
  
  class HashBase
    
    def self.select_one(array, field, value)
      (array || []).detect do |record|
        record[field] == value
      end
    end
    
    
    def self.find(id)
      self.find_by(:id, id)
    end
    
    def self.find_by(field, value)
      self.select_one(self.data, field, value)
    end
    
    def self.data
      [
        # {id => 10000, attr1 => value1, attr2 => value2, ...}
      ]
    end
    
  end
  
end


