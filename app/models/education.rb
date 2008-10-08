class Education < ActiveRecord::Base
  
  def self.find(id)
    id ? id.to_s == "all" ? @@all : @@all[id-1] : ""
  end

  @@all = [
          "其它", # 1
          "初中及以下", # 2
          "高中", # 3
          "大专", # 4
          "本科", # 5
          "硕士", # 6
          "博士及以上", # 7
          "认证/证书" # 8
        ]
        
end
