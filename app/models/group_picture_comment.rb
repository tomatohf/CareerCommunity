class GroupPictureComment < ActiveRecord::Base
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :group_picture, :class_name => "GroupPicture", :foreign_key => "group_picture_id"

  # ---

  validates_presence_of :account_id, :group_picture_id, :content
  
  validates_length_of :content, :maximum => 1000, :message => "评论内容 超过长度限制", :allow_nil => false
  
  
  
  CKP_count = :group_picture_comment_count
  Count_Cache_Group_Field = :group_picture_id
  include CareerCommunity::CountCacheable
  
end


