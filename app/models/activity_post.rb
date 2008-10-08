class ActivityPost < ActiveRecord::Base
  
  define_index do
    # fields
    indexes :title, :content
    indexes account.nick, :as => :account_nick
    indexes activity.title, :as => :activity_title
    indexes comments.content, :as => :comments_content
    indexes comments.account.nick, :as => :comments_account_nick

    # attributes
    has :created_at, :updated_at, :responded_at
    
    set_property :delta => true
    
    # set_property :field_weights => {:field => number}
  end
  
  include CareerCommunity::AccountBelongings
  
  has_many :comments, :class_name => "ActivityPostComment", :foreign_key => "activity_post_id", :dependent => :destroy
  
  belongs_to :activity, :class_name => "Activity", :foreign_key => "activity_id"
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  
  
  validates_presence_of :account_id, :activity_id
  
  validates_presence_of :title, :message => "请输入 标题"
  validates_presence_of :content, :message => "请输入 内容"
  
  validates_length_of :title, :maximum => 256, :message => "标题 超过长度限制", :allow_nil => false
  
end