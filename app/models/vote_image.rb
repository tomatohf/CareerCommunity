class VoteImage < ActiveRecord::Base
  
  belongs_to :vote_topic, :class_name => "VoteTopic", :foreign_key => "vote_topic_id"
  belongs_to :photo, :class_name => "Photo", :foreign_key => "photo_id"

  # ---

  validates_presence_of :vote_topic_id
  
  
  
  after_destroy { |image|
    VoteTopic.clear_vote_with_image_cache(image.vote_topic_id)
  }
  
  
  
  def self.get_by_vote_topic(vote_topic_id)
    self.find(:first, :conditions => ["vote_topic_id = ?", vote_topic_id])
  end
  
end