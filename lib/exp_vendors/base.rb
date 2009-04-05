module ExpVendor
  
  @@vendors = {
    # "file_name_without_rb" => "class name"
    
    # "esojob" => "Esojob",
    "mianjing51" => "Mianjing51"
  }
  
  
  def self.vendor_classess
    @@vendors.values.collect { |value| "ExpVendor::#{value}" }
  end
  
  module Base
    include RecruitmentVendor::Base
    
    def filter_match_rules
      [
        # sample ...
        #{
          # :all => [/regexp1/, /regexp2/]
          # :content => [/regexp1/, /regexp2/]
        #}
        
        :all => Exp::Filter_Out_Key_Words
      ]
    end
    
    def all_fields
      [:title, :content]
    end
    
  end
  
  
  @@vendors.keys.each { |file| require_dependency "exp_vendors/#{file}" }
  
end
