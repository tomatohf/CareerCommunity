class GoalTrack < ActiveRecord::Base
  
  acts_as_trashable

  
  
  has_many :comments, :class_name => "GoalTrackComment", :foreign_key => "goal_track_id", :dependent => :destroy
  
  belongs_to :goal_follow, :class_name => "GoalFollow", :foreign_key => "goal_follow_id"
  
  
  validates_presence_of :goal_follow_id, :goal_id
  
  validates_presence_of :value, :message => "请输入 完成情况"
  validates_presence_of :desc, :message => "请输入 进度描述"
  
  validates_numericality_of :value, :message => "完成情况 必须是数字", :allow_nil => false, :only_integer => false
  
  validates_length_of :desc, :maximum => 1000, :message => "进度描述 超过长度限制", :allow_nil => false
  
  
end

