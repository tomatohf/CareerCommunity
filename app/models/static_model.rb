module StaticModel
  
  class StringBase
    
    @@all = []

    def self.find(id)
      id ? ((id.to_s == "all") ? @@all : @@all[id-1]) : ""
    end
    
  end
  
end


