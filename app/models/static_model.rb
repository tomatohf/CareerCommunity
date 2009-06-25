module StaticModel
  
  class StringBase
    
    def self.all
      []
    end

    def self.find(id)
      id ? ((id.to_s == "all") ? all : all[id-1]) : ""
    end
    
  end
  
  
  class OrderedStringBase < StringBase
    def self.find(id)
      id ? ((id.to_s == "all") ? all.sort{ |x, y| x[1] <=> y[1] }.collect{ |item| item[0] } : all[id-1][0]) : ""
    end
  end
  
end


