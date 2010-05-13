module Intranet
  class Employee < StaticModel::HashBase
  
    def self.data
      [
        {:id => 10, :name => "何帆", :account_id => 1001, :manager => false},
        {:id => 20, :name => "马晓", :account_id => 1002, :manager => true},
        {:id => 30, :name => "沈锴", :account_id => 1019, :manager => false},
        
        {:id => 40, :name => "顾艳", :account_id => 1422, :manager => false, :email => "guyan@woshiyanzijie"},
        {:id => 50, :name => "陈松凤", :account_id => 6401, :manager => false, :email => "debbychen@36915105"},
        {:id => 60, :name => "吴诺威", :account_id => 6402, :manager => false, :email => "wunuowei@wunuowei1021"},
        {:id => 70, :name => "王佳俊", :account_id => 6398, :manager => false, :email => "leowang@80525361"}
      ]
    end
  
  end
end
