class PointProfile < ActiveRecord::Base
  
  include CareerCommunity::AccountBelongings

  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"

  # ---

  validates_presence_of :account_id
  
  
  
  Action_Points = {
    :add_post => 20,
    :add_post_to_good => 50,
    :add_blog => 20
  }
  
  
  
  def self.get_account_points(account_id)
    point_profile = self.find(
      :first,
      :conditions => ["account_id = ?", account_id]
    )
    
    (point_profile && point_profile.points) || 0
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
  
end
