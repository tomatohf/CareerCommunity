class JobTag < ActiveRecord::Base
  
  has_and_belongs_to_many :talk_questions,
                          :foreign_key => "job_tag_id",
                          :association_foreign_key => "talk_question_id",
                          :join_table => "talk_questions_job_tags",
                          #:order => "created_at DESC",
                          :after_add => Proc.new { |job_tag, talk_question| JobTag.clear_talk_question_tags_cache(talk_question.id) },
                          :after_remove => Proc.new { |job_tag, talk_question| JobTag.clear_talk_question_tags_cache(talk_question.id) }

  # ---

  validates_presence_of :name
  validates_uniqueness_of :name
  
  validates_length_of :name, :maximum => 250, :message => "名称 超过长度限制", :allow_nil => false
  
  
  
  CKP_talk_question_tags = :talk_question_tags
  
#  after_destroy { |tag|
#  }
  
#  after_save { |tag|
#  }
  
  
  
  def self.get_tag(tag_name)
    self.find(:first, :conditions => ["name = ?", tag_name]) || self.new(:name => tag_name)
  end
  
  
  def self.get_talk_question_tags(talk_question_id)
    tags = Cache.get("#{CKP_talk_question_tags}_#{talk_question_id}".to_sym)
    
    unless tags
      question = TalkQuestion.get_question(talk_question_id)
      
      tags = []
      question.job_tags.each { |tag|
        tags << tag
      }
      
      Cache.set("#{CKP_talk_question_tags}_#{talk_question_id}".to_sym, tags, Cache_TTL)
    end
    tags
  end
  
  def self.clear_talk_question_tags_cache(talk_question_id)
    Cache.delete("#{CKP_talk_question_tags}_#{talk_question_id}".to_sym)
  end
  
  
  
end
