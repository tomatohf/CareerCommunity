class TalkTalker < ActiveRecord::Base
  
  belongs_to :talk, :class_name => "Talk", :foreign_key => "talk_id"
  belongs_to :talker, :class_name => "Talker", :foreign_key => "talker_id"
  
  
  validates_presence_of :talk_id, :talker_id
  
  
  
  CKP_talk_talkers = :talk_talkers
  
  after_save { |talk_talker|
    self.clear_talk_talkers_cache(talk_talker.talk_id)
  }
  
  after_destroy { |talk_talker|
    self.clear_talk_talkers_cache(talk_talker.talk_id)
  }
  
  
  
  require_dependency "talker"
  def self.get_talk_talkers(talk_id)
    t_t = Cache.get("#{CKP_talk_talkers}_#{talk_id}".to_sym)
    
    unless t_t
      t_t = self.find(
        :all,
        :conditions => ["talk_id = ?", talk_id],
        :include => [:talker]
      ).collect do |talk_talker|
        talker = talk_talker.talker
        Talker.set_talker_cache(talker)
        [talk_talker.id, talker]
      end
      
      Cache.set("#{CKP_talk_talkers}_#{talk_id}".to_sym, t_t, Cache_TTL)
    end
    t_t
  end
  
  def self.clear_talk_talkers_cache(talk_id)
    Cache.delete("#{CKP_talk_talkers}_#{talk_id}".to_sym)
  end
  
end


