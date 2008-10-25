class VoteOption < ActiveRecord::Base
  
  has_many :records, :class_name => "VoteRecord", :foreign_key => "vote_option_id", :dependent => :destroy
  
  belongs_to :topic, :class_name => "VoteTopic", :foreign_key => "vote_topic_id"
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  
  
  validates_presence_of :account_id, :vote_topic_id
  
  validates_presence_of :title, :message => "请输入 标题"
  
  validates_length_of :title, :maximum => 256, :message => "标题 超过长度限制", :allow_nil => false
  
  
  
  CKP_topic_options = :vote_topic_options
  
  after_destroy { |vote_option|
    self.clear_vote_topic_options_cache(vote_option.vote_topic_id)
  }
  
  after_save { |vote_option|
    self.clear_vote_topic_options_cache(vote_option.vote_topic_id)
  }
  
  
  
  def self.get_vote_topic_options(vote_topic_id)
    v_o = Cache.get("#{CKP_topic_options}_#{vote_topic_id}".to_sym)
    
    unless v_o
      v_o = self.find(:all, :conditions => ["vote_topic_id = ?", vote_topic_id]).collect do |option|
        [option.id, option.title, option.color, option.account_id, option.vote_topic_id]
      end
      
      Cache.set("#{CKP_topic_options}_#{vote_topic_id}".to_sym, v_o, Cache_TTL)
    end
    v_o
  end
  
  def self.clear_vote_topic_options_cache(vote_topic_id)
    Cache.delete("#{CKP_topic_options}_#{vote_topic_id}".to_sym)
  end
  
  
end


