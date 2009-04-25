module StaticModel
  
  class StringBase
    
    def self.all
      []
    end

    def self.find(id)
      id ? ((id.to_s == "all") ? all : all[id-1]) : ""
    end
    
  end
  
end


