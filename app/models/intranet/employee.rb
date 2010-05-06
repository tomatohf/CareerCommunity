module Intranet
  class Employee < StaticModel::HashBase
  
    def self.data
      [
        {:id => 10, :name => "何帆", :account_id => 1001, :manager => false},
        {:id => 20, :name => "马晓", :account_id => 1002, :manager => true}
      ]
    end
  
  end
end
