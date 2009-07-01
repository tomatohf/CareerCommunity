class PointProfile < ActiveRecord::Base
  
  include CareerCommunity::AccountBelongings

  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"

  # ---

  validates_presence_of :account_id
  
  
  
  CKP_account_points = :account_profile_points
  
  after_save { |point_profile|
    self.set_account_points_cache(point_profile.account_id, (point_profile.points || 0))
  }
  
  after_destroy { |point_profile|
    self.clear_account_points_cache(point_profile.account_id)
  }
  
  
  
  Action_Points = {
    :add_post => 20,
    :add_post_to_good => 50,
    :add_blog => 20,
    :add_vote_topic => 20,
    :add_vote_comment => 10,
    :add_post_comment => 10,
    :add_talk_comment => 20,
    :create_pic_profile => 100,
    :add_job_service => 30,
    :add_job_service_evaluation => 20
  }
  
  
  
  def self.get_account_points(account_id)
    point = Cache.get("#{CKP_account_points}_#{account_id}".to_sym)
    
    unless point
      point_profile = self.find(
        :first,
        :conditions => ["account_id = ?", account_id]
      )

      point = (point_profile && point_profile.points) || 0
      
      self.set_account_points_cache(account_id, point)
    end
    point
  end
  
  def self.set_account_points_cache(account_id, point)
    Cache.set("#{CKP_account_points}_#{account_id}".to_sym, point, Cache_TTL)
  end
  
  def self.clear_account_points_cache(account_id)
    Cache.delete("#{CKP_account_points}_#{account_id}".to_sym)
  end
  
  
  def self.adjust_account_points(account_id, point)
    point_profile = self.find(
      :first,
      :conditions => ["account_id = ?", account_id]
    ) || self.new(:account_id => account_id)
    
    point_profile.points = (point_profile.points || 0) + point
    
    point_profile.save
  end
  
  def self.adjust_account_points_by_action(account_id, action, increase = true)
    point = Action_Points[action]
    point = 0 - point unless increase
    self.adjust_account_points(account_id, point)
  end
  
  
  def self.calculate_level(point)
    point ||= 0
    
    thresholds = [
      100,    # 100
      
      300,    # 200 100
      700,    # 400 200
      1400,   # 700 300
      2500,   # 1100 400
      4100,   # 1600 500
      6300,   # 2200 600
      9200,   # 2900 700
      12900,  # 3700 800
      17500,  # 4600 900
      
      23100,  # 5600 1000
      30700,  # 7600 2000
      41300,  # 10600 3000
      55900,  # 14600 4000
      75500,  # 19600 5000
      101100,  # 25600 6000
      133700,  # 32600 7000
      174300,  # 40600 8000
      # 223900,  # 49600 9000
      300000
    ]
    
    thresholds.each_index do |i|
      return (i+1) if point < thresholds[i]
    end
    
    thresholds.size+1
  end
  
end
