class TalkComment < ActiveRecord::Base
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :talk, :class_name => "Talk", :foreign_key => "talk_id"

  # ---

  validates_presence_of :account_id, :talk_id, :content
  
  validates_length_of :content, :maximum => 1000, :message => "评论内容 超过长度限制", :allow_nil => false
  
  
  
  CKP_count = :talk_comment_count
  Count_Cache_Group_Field = :talk_id
  include CareerCommunity::CountCacheable
  
end

