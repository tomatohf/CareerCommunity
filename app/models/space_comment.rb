class SpaceComment < ActiveRecord::Base
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :owner, :class_name => "Account", :foreign_key => "owner_id"

  # ---

  validates_presence_of :account_id, :owner_id, :content
  
  validates_length_of :content, :maximum => 1000, :message => "评论内容 超过长度限制", :allow_nil => false
  
end