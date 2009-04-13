class VoteComment < ActiveRecord::Base
  
  acts_as_trashable
  
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :vote_topic, :class_name => "VoteTopic", :foreign_key => "vote_topic_id"
        

  # ---

  validates_presence_of :account_id, :vote_topic_id, :content
  
  validates_length_of :content, :maximum => 1000, :message => "评论内容 超过长度限制", :allow_nil => false
  
  
  
  CKP_count = :vote_comment_count
  Count_Cache_Group_Field = :vote_topic_id
  include CareerCommunity::CountCacheable
  
  
  
  after_destroy { |vote_comment|
    PointProfile.adjust_account_points_by_action(vote_comment.account_id, :add_vote_comment, false)
  }
  
  after_create { |vote_comment|
    PointProfile.adjust_account_points_by_action(vote_comment.account_id, :add_vote_comment, true)
  }
  
end