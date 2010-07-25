module Intranet
  class Employee < StaticModel::HashBase
  
    def self.data
      [
        {:id => 10, :name => "何帆", :account_id => 1001, :manager => true, :email => "hefan@"},
        {:id => 20, :name => "马晓", :account_id => 1002, :manager => true, :email => "rick@"},
        {:id => 30, :name => "沈锴", :account_id => 1019, :manager => true, :email => "shenkai@"},
        
        {:id => 40, :name => "顾艳", :account_id => 1422, :manager => false, :email => "guyan@woshiyanzijie"},
        # {:id => 50, :name => "陈松凤", :account_id => 6401, :manager => false, :email => "debbychen@36915105"},
        {:id => 70, :name => "王佳俊", :account_id => 6398, :manager => false, :email => "leowang@80525361"},
        {:id => 80, :name => "张杰", :account_id => 1074, :manager => false, :email => "zhangjie@iamzj"}
      ]
    end
  
  end
end
