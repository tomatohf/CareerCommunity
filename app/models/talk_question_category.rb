class TalkQuestionCategory < ActiveRecord::Base
  
  belongs_to :talk, :class_name => "Talk", :foreign_key => "talk_id"
  
  belongs_to :creator, :class_name => "Account", :foreign_key => "creator_id"
  belongs_to :updater, :class_name => "Account", :foreign_key => "updater_id"
  
  
  validates_presence_of :talk_id, :creator_id, :updater_id
  
  validates_presence_of :name, :message => "请输入 名称"
  
  validates_length_of :name, :maximum => 250, :message => "名称 超过长度限制", :allow_nil => false
  validates_length_of :desc, :maximum => 1000, :message => "描述 超过长度限制", :allow_nil => true
  
  
  
  CKP_talk_question_categories = :talk_question_categories
  
  after_save { |question_category|
    self.clear_talk_question_categories_cache(question_category.talk_id)
  }
  
  after_destroy { |question_category|
    self.clear_talk_question_categories_cache(question_category.talk_id)
  }
  
  
  
  def self.get_talk_question_categories(talk_id)
    t_q_c = Cache.get("#{CKP_talk_question_categories}_#{talk_id}".to_sym)
    
    unless t_q_c
      t_q_c = self.find(
        :all,
        :conditions => ["talk_id = ?", talk_id]
      )
      
      Cache.set("#{CKP_talk_question_categories}_#{talk_id}".to_sym, t_q_c, Cache_TTL)
    end
    t_q_c
  end
  
  def self.clear_talk_question_categories_cache(talk_id)
    Cache.delete("#{CKP_talk_question_categories}_#{talk_id}".to_sym)
  end
  
end


