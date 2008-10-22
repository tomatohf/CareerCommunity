class VoteRecord < ActiveRecord::Base
  
  belongs_to :topic, :class_name => "VoteTopic", :foreign_key => "vote_topic_id"
  belongs_to :option, :class_name => "VoteOption", :foreign_key => "vote_option_id"
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  
  
  validates_presence_of :account_id, :vote_topic_id, :vote_option_id
  
end


