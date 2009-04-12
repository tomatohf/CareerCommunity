class GroupPostComment < ActiveRecord::Base
  
  acts_as_trashable
  
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :group_post, :class_name => "GroupPost", :foreign_key => "group_post_id"

  # ---

  validates_presence_of :account_id, :group_post_id, :content
  
  validates_length_of :content, :maximum => 1000, :message => "回帖内容 超过长度限制", :allow_nil => false
  
  
  
  CKP_count = :group_post_comment_count
  Count_Cache_Group_Field = :group_post_id
  include CareerCommunity::CountCacheable
  
end