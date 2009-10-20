class Service < StaticModel::StringBase
  
  def self.all
    [
      "咨询详情", # 1
      "申请 乔布堂求职顾问", # 2
      "报名 职业决策研讨班", # 3
      "报名 简历网申求职信特训", # 4
      "报名 面试和职场礼仪模拟训练", # 5
      "报名 销售精英启航班", # 6
      "报名 求职精品班", # 7
      "报名 求职拓展班", # 8
      "参加 医药行业精品班", # 9
      "参加 医药行业拓展班", # 10
      "报名 销售实习生计划 (STP)", # 11
      "申请试听 销售实习生计划 (STP)" # 12
    ]
  end
  
  
  def self.avaliable?(sid)
    sid < 3 || sid > 10
  end
  
        
end
