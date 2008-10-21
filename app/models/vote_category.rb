class VoteCategory < ActiveRecord::Base
  
  has_many :vote_topics, :class_name => "VoteTopic", :foreign_key => "vote_topic_id", :dependent => :nullify

  # ---

  validates_presence_of :name
  
  
end

