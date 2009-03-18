class TalkQuestion < ActiveRecord::Base
  
  acts_as_trashable
  
  
  has_and_belongs_to_many :job_tags,
                          :foreign_key => "talk_question_id",
                          :association_foreign_key => "job_tag_id",
                          :join_table => "talk_questions_job_tags",
                          #:order => "created_at DESC",
                          :after_add => Proc.new { |talk_question, job_tag| JobTag.clear_talk_question_tags_cache(talk_question.id) },
                          :after_remove => Proc.new { |talk_question, job_tag| JobTag.clear_talk_question_tags_cache(talk_question.id) }
                          
                          
                          
  belongs_to :talk, :class_name => "Talk", :foreign_key => "talk_id"
  
  belongs_to :creator, :class_name => "Account", :foreign_key => "creator_id"
  belongs_to :updater, :class_name => "Account", :foreign_key => "updater_id"
  
  has_many :answers, :class_name => "TalkAnswer", :foreign_key => "question_id", :dependent => :destroy
  
  
  validates_presence_of :talk_id, :creator_id, :updater_id
  
  validates_presence_of :question, :message => "请输入 问题"
  
  validates_length_of :question, :maximum => 250, :message => "问题 超过长度限制", :allow_nil => false
  validates_length_of :summary, :maximum => 250, :message => "点评 超过长度限制", :allow_nil => true
  
  
  
  CKP_talk_question = :talk_question
  CKP_talk_questions = :talk_questions
  
  after_save { |question|
    self.set_question_cache(question)
    
    self.clear_talk_questions_cache(question.talk_id)
    
    Talk.clear_reader_content_cache(question.talk_id)
  }
  
  after_destroy { |question|
    self.clear_question_cache(question.id)
    
    self.clear_talk_questions_cache(question.talk_id)
    
    Talk.clear_reader_content_cache(question.talk_id)
  }
  
  
  
  def self.get_question(question_id)
    t_q = Cache.get("#{CKP_talk_question}_#{question_id}".to_sym)
    
    unless t_q
      t_q = self.find(question_id)
      
      self.set_question_cache(t_q)
    end
    t_q
  end
  
  def self.set_question_cache(question)
    Cache.set("#{CKP_talk_question}_#{question.id}".to_sym, question, Cache_TTL)
  end
  
  def self.clear_question_cache(question_id)
    Cache.delete("#{CKP_talk_question}_#{question_id}".to_sym)
  end
  
  
  def self.get_talk_questions(talk_id)
    t_qs = Cache.get("#{CKP_talk_questions}_#{talk_id}".to_sym)
    
    unless t_qs
      t_qs = self.find(
        :all,
        :conditions => ["talk_id = ?", talk_id]
      )
      
      Cache.set("#{CKP_talk_questions}_#{talk_id}".to_sym, t_qs, Cache_TTL)
    end
    t_qs
  end
  
  def self.clear_talk_questions_cache(talk_id)
    Cache.delete("#{CKP_talk_questions}_#{talk_id}".to_sym)
  end
  
end


