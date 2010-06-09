class CareerTest < StaticModel::HashBase
  
  def self.data
    [
      {:id => 1, :name => "mbti", :hide => false},
      {:id => 2, :name => "enneagram", :hide => false},
      {:id => 3, :name => "sales_style", :hide => false}
    ]
  end
  
  
  
  def self.get_test(test_type_or_id)
    test_type = test_type_or_id.kind_of?(Integer) ? find(test_type_or_id)[:name] : test_type_or_id
    "CareerTests::#{test_type.camelize}".constantize.instance
  end
  
end
