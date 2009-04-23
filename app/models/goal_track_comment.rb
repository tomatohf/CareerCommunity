class GoalTrackComment < ActiveRecord::Base
  
  acts_as_trashable
  
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :goal_track, :class_name => "GoalTrack", :foreign_key => "goal_track_id"

  # ---

  validates_presence_of :account_id, :goal_track_id, :content
  
  validates_length_of :content, :maximum => 1000, :message => "评论内容 超过长度限制", :allow_nil => false
  
  
  
  CKP_count = :goal_track_comment_count
  Count_Cache_Group_Field = :goal_track_id
  include CareerCommunity::CountCacheable
  
end

