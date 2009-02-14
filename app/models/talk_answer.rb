class TalkAnswer < ActiveRecord::Base
  
  belongs_to :talk, :class_name => "Talk", :foreign_key => "talk_id"
  belongs_to :question, :class_name => "TalkQuestion", :foreign_key => "question_id"
  belongs_to :talker, :class_name => "Talker", :foreign_key => "talker_id"
  
  belongs_to :creator, :class_name => "Account", :foreign_key => "creator_id"
  belongs_to :updater, :class_name => "Account", :foreign_key => "updater_id"
  
  
  validates_presence_of :talk_id, :question_id, :talker_id, :creator_id, :updater_id
  
  validates_presence_of :answer, :message => "请输入 回答"
  
  validates_length_of :summary, :maximum => 250, :message => "点评 超过长度限制", :allow_nil => true
  
  
  
  CKP_talk_answer = :talk_answer
  CKP_talk_question_answers = :talk_question_answers
  
  after_save { |answer|
    self.set_answer_cache(answer)
    
    self.clear_talk_question_answers_cache(answer.question_id)
  }
  
  after_destroy { |answer|
    self.clear_answer_cache(answer.id)
    
    self.clear_talk_question_answers_cache(answer.question_id)
  }
  
  
  
  def self.get_answer(answer_id)
    t_a = Cache.get("#{CKP_talk_answer}_#{answer_id}".to_sym)
    
    unless t_a
      t_a = self.find(answer_id)
      
      self.set_answer_cache(t_a)
    end
    t_a
  end
  
  def self.set_answer_cache(answer)
    Cache.set("#{CKP_talk_answer}_#{answer.id}".to_sym, answer, Cache_TTL)
  end
  
  def self.clear_answer_cache(answer_id)
    Cache.delete("#{CKP_talk_answer}_#{answer_id}".to_sym)
  end
  
  
  def self.get_talk_question_answers(question_id)
    t_q_as = Cache.get("#{CKP_talk_question_answers}_#{question_id}".to_sym)
    
    unless t_q_as
      t_q_as = self.find(
        :all,
        :conditions => ["question_id = ?", question_id]
      )
      
      Cache.set("#{CKP_talk_question_answers}_#{question_id}".to_sym, t_q_as, Cache_TTL)
    end
    t_q_as
  end
  
  def self.clear_talk_question_answers_cache(question_id)
    Cache.delete("#{CKP_talk_question_answers}_#{question_id}".to_sym)
  end
  
end


