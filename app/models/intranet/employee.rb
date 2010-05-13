module Intranet
  class Employee < StaticModel::HashBase
  
    def self.data
      [
        {:id => 10, :name => "何帆", :account_id => 1001, :manager => false},
        {:id => 20, :name => "马晓", :account_id => 1002, :manager => true},
        {:id => 30, :name => "沈锴", :account_id => 1019, :manager => false},
        
        {:id => 40, :name => "顾艳", :account_id => 1422, :manager => false, :email => "guyan@woshiyanzijie"},
        {:id => 50, :name => "陈松凤", :account_id => 6401, :manager => false, :email => "debbychen@36915105"}
      ]
    end
  
  end
end
