class Talker < ActiveRecord::Base
  
  acts_as_trashable
  
  
  validates_presence_of :real_name, :message => "请输入 真实姓名"
  
  validates_length_of :real_name, :maximum => 50, :message => "真实姓名 超过长度限制", :allow_nil => true
  validates_length_of :experience, :maximum => 1000, :message => "经历 超过长度限制", :allow_nil => true
  
  validates_length_of :mobile, :maximum => 25, :message => "手机 超过长度限制", :allow_nil => true
  validates_length_of :phone, :maximum => 25, :message => "电话 超过长度限制", :allow_nil => true
  validates_length_of :qq, :maximum => 20, :message => "QQ号 超过长度限制", :allow_nil => true
  
  validates_length_of :other, :maximum => 1000, :message => "其他信息 超过长度限制", :allow_nil => true
  
  
  
  CKP_talker = :talker
  CKP_all_talker_names = :all_talker_names
  
  after_save { |talker|
    self.set_talker_cache(talker)
    
    self.clear_talk_talker_related_cache(talker.id)
    
    self.clear_all_talker_names_cache
  }
  
  after_destroy { |talker|
    self.clear_talker_cache(talker.id)
    
    self.clear_talk_talker_related_cache(talker.id)
    
    self.clear_all_talker_names_cache
  }
  
  def self.clear_talk_talker_related_cache(talker_id)
    TalkTalker.find(
      :all,
      :conditions => ["talker_id = ?", talker_id]
    ).each do |talk_talker|
      TalkTalker.clear_talk_talkers_cache(talk_talker.talk_id)
      
      Talk.clear_reader_content_cache(talk_talker.talk_id)
    end
  end
  
  
  
  def get_name
    the_name = self.real_name
    
    the_name += " (#{self.nick})" if self.nick && self.nick != ""
    
    the_name
  end
  
  
  require_dependency "talk_talker"
  def self.get_talker(talker_id)
    t = Cache.get("#{CKP_talker}_#{talker_id}".to_sym)
    
    unless t
      t = self.find(talker_id)
      
      self.set_talker_cache(t)
    end
    t
  end
  
  def self.set_talker_cache(talker)
    Cache.set("#{CKP_talker}_#{talker.id}".to_sym, talker, Cache_TTL)
  end
  
  def self.clear_talker_cache(talker_id)
    Cache.delete("#{CKP_talker}_#{talker_id}".to_sym)
  end
  
  def self.get_all_talker_names
    a_t_n = Cache.get(CKP_all_talker_names)
    
    unless a_t_n
      a_t_n = self.find(
        :all,
        :select => "id, real_name, nick",
        :order => "id DESC"
      ).collect { |talker|
        [talker.id, talker.get_name]
      }
      
      Cache.set(CKP_all_talker_names, a_t_n, Cache_TTL)
    end
    a_t_n
  end
  
  def self.clear_all_talker_names_cache
    Cache.delete(CKP_all_talker_names)
  end
  
end


