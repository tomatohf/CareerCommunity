class GoalFollowStatus < StaticModel::StringBase
  
  @@all = [
          "active", # 1
          "cancelled", # 2
          "finished" # 3
        ]
  
  
  
  def self.active
    [1, "正在做"]
  end
  
  def self.cancelled
    [2, "已终止"]
  end
  
  def self.finished
    [3, "已完成"]
  end
  
  
  def self.get_follow_status(id)
    self.send(self.find(id))
  end
  
end
