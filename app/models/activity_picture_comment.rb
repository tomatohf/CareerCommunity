class ActivityPictureComment < ActiveRecord::Base
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :activity_picture, :class_name => "ActivityPicture", :foreign_key => "activity_picture_id"

  # ---

  validates_presence_of :account_id, :activity_picture_id, :content
  
  validates_length_of :content, :maximum => 1000, :message => "评论内容 超过长度限制", :allow_nil => false
  
  
  
  CKP_count = :activity_picture_comment_count
  Count_Cache_Group_Field = :activity_picture_id
  include CareerCommunity::CountCacheable
  
end


