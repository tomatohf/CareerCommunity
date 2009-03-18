class BlogComment < ActiveRecord::Base
  
  acts_as_trashable
  
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :blog, :class_name => "Blog", :foreign_key => "blog_id"

  # ---

  validates_presence_of :account_id, :blog_id, :content
  
  validates_length_of :content, :maximum => 1000, :message => "评论内容 超过长度限制", :allow_nil => false
  
  
  
  CKP_count = :blog_comment_count
  Count_Cache_Group_Field = :blog_id
  include CareerCommunity::CountCacheable
  
end