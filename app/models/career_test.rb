class CareerTest < StaticModel::StringBase
  
  def self.all
    [
      "mbti" # 1
      #"sales_style" # 2
    ]
  end
  
  
  
  def self.get_test(test_type_or_id)
    test_type = test_type_or_id.kind_of?(Integer) ? find(test_type_or_id) : test_type_or_id
    "CareerTests::#{test_type.camelize}".constantize.instance
  end
  
end
