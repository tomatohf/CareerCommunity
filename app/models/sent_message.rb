class SentMessage < ActiveRecord::Base
  
  include CareerCommunity::AccountBelongings
  
  belongs_to :sender, :class_name => "Account", :foreign_key => "sender_id"
  belongs_to :receiver, :class_name => "Account", :foreign_key => "receiver_id"

  # ---

  validates_presence_of :sender_id, :receiver_id, :reply_to_id, :content
  
  validates_length_of :content, :maximum => 1000, :message => "消息内容 超过长度限制", :allow_nil => false
  
  def self.get_threads(sender_id, receiver_id, reply_id)
    self.find(
      :all,
      :conditions => ["reply_to_id = ? and sender_id = ? and receiver_id = ?", reply_id, sender_id, receiver_id]
    )
  end
  
end