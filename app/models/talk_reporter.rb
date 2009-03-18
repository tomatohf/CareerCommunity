class TalkReporter < ActiveRecord::Base
  
  acts_as_trashable
  
  
  belongs_to :talk, :class_name => "Talk", :foreign_key => "talk_id"
  
  
  validates_presence_of :talk_id
  
  validates_presence_of :name, :message => "请输入 名称"
  
  validates_length_of :name, :maximum => 250, :message => "名称 超过长度限制", :allow_nil => false
  
  
  
  CKP_talk_reporters = :talk_reporters
  
  after_save { |talk_reporter|
    self.clear_talk_reporters_cache(talk_reporter.talk_id)
  }
  
  after_destroy { |talk_reporter|
    self.clear_talk_reporters_cache(talk_reporter.talk_id)
  }
  
  
  
  def self.get_talk_reporters(talk_id)
    t_r = Cache.get("#{CKP_talk_reporters}_#{talk_id}".to_sym)
    
    unless t_r
      t_r = self.find(
        :all,
        :conditions => ["talk_id = ?", talk_id]
      ).collect do |talk_reporter|
        [talk_reporter.id, talk_reporter.name]
      end
      
      Cache.set("#{CKP_talk_reporters}_#{talk_id}".to_sym, t_r, Cache_TTL)
    end
    t_r
  end
  
  def self.clear_talk_reporters_cache(talk_id)
    Cache.delete("#{CKP_talk_reporters}_#{talk_id}".to_sym)
  end
  
end


