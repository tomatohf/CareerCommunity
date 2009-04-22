class GoalFollowType < StaticModel::StringBase
  
  @@all = [
          "number", # 1
          "rank", # 2
          "boolean" # 3
        ]
  
  
  
  def self.number
    [1, "数字的", "/images/goals/number_type_icon.png"]
  end
  
  def self.rank
    [2, "级别的", "/images/goals/rank_type_icon.png"]
  end
  
  def self.boolean
    [3, "是否的", "/images/goals/boolean_type_icon.png"]
  end
  
  
  def self.get_follow_type(id)
    self.send(self.find(id))
  end
  
end
