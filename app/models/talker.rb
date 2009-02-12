class Talker < ActiveRecord::Base
  
  validates_length_of :real_name, :maximum => 50, :message => "真实姓名 超过长度限制", :allow_nil => true
  validates_length_of :experience, :maximum => 1000, :message => "经历 超过长度限制", :allow_nil => true
  
  validates_length_of :mobile, :maximum => 25, :message => "手机 超过长度限制", :allow_nil => true
  validates_length_of :phone, :maximum => 25, :message => "电话 超过长度限制", :allow_nil => true
  validates_length_of :qq, :maximum => 20, :message => "QQ号 超过长度限制", :allow_nil => true
  
  validates_length_of :other, :maximum => 1000, :message => "其他信息 超过长度限制", :allow_nil => true
  
  
  
  CKP_talker = :talker
  
  after_save { |talker|
    self.set_talker_cache(talker)
  }
  
  after_destroy { |talker|
    self.clear_talker_cache(talker.id)
  }
  
  
  
  def self.get_talker(talker_id)
    t = Cache.get("#{CKP_talker}_#{talker_id}".to_sym)
    
    unless t
      t = self.find(talker_id)
      
      self.set_talker_cache(t)
    end
    t
  end
  
  def self.set_talker_cache(talker)
    Cache.set("#{CKP_talker}_#{talker.id}".to_sym, talker.clear_association, Cache_TTL)
  end
  
  def self.clear_talker_cache(talker_id)
    Cache.delete("#{CKP_talker}_#{talker_id}".to_sym)
  end
  
end


