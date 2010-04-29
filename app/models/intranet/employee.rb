module Intranet
  class Employee < StaticModel::HashBase
  
    def self.data
      [
        {:id => 10, :name => "托马托", :account_id => 1001, :manager => true},
        {:id => 20, :name => "娃哈哈", :account_id => 1002, :manager => false}
      ]
    end
  
  end
end
