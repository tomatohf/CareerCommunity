module Intranet
  class SalesOpportunityStep < StaticModel::HashBase
  
    def self.data
      [
        {:id => 10, :name => "analysis", :label => "客户分析"},
        {:id => 20, :name => "relationship", :label => "建立关系"},
        {:id => 30, :name => "demand", :label => "探询需求"},
        {:id => 40, :name => "proposal", :label => "设计方案"},
        {:id => 50, :name => "contract", :label => "签订合同"},
        {:id => 60, :name => "payment", :label => "回款"}
      ]
    end
  
  end
end
