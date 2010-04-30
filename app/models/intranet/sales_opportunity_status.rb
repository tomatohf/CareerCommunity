module Intranet
  class SalesOpportunityStatus < StaticModel::HashBase
  
    def self.data
      [
        {:id => 10, :name => "ongoing", :label => "进行中"},
        {:id => 20, :name => "success", :label => "已成功"},
        {:id => 30, :name => "fail", :label => "已失败"}
      ]
    end
  
  end
end
