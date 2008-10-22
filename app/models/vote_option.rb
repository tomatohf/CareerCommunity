class VoteOption < ActiveRecord::Base
  
  has_many :records, :class_name => "VoteRecord", :foreign_key => "vote_option_id", :dependent => :destroy
  
  belongs_to :topic, :class_name => "VoteTopic", :foreign_key => "vote_topic_id"
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  
  
  validates_presence_of :account_id, :vote_topic_id
  
  validates_presence_of :title, :message => "请输入 标题"
  
  validates_length_of :title, :maximum => 256, :message => "标题 超过长度限制", :allow_nil => false
  
end


