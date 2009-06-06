class GoalFollow < ActiveRecord::Base
  
  acts_as_trashable

  
  
  has_many :tracks, :class_name => "GoalTrack", :foreign_key => "goal_follow_id", :dependent => :destroy
  
  belongs_to :goal, :class_name => "Goal", :foreign_key => "goal_id"
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  
  
  validates_presence_of :account_id, :goal_id, :status_id, :type_id
  
  
  
  # named_scope :private, :conditions => ["private = ?", true]
  
  
end

