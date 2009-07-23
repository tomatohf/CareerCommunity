class CareerTest < StaticModel::OrderedStringBase
  
  def self.all
    [
      ["mbti", 10], # 1
      ["enneagram", 20] # 2
      #["sales_style", 20] # 3
    ]
  end
  
  
  
  def self.get_test(test_type_or_id)
    test_type = test_type_or_id.kind_of?(Integer) ? find(test_type_or_id) : test_type_or_id
    "CareerTests::#{test_type.camelize}".constantize.instance
  end
  
end
