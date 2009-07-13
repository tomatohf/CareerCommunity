class Talk < ActiveRecord::Base
  
  acts_as_trashable
  
  
  define_index do
    # fields
    indexes :title, :info
    
    indexes question_categories.name, :as => :question_categories_name
    indexes question_categories.desc, :as => :question_categories_desc
    
    indexes questions.question, :as => :questions_question
    indexes questions.summary, :as => :questions_summary
    
    indexes answers.answer, :as => :answers_answer
    indexes answers.summary, :as => :answers_summary
    
    indexes comments.content, :as => :comments_content
    

    # attributes
    has :published, :publish_at
    
    set_property :delta => true
    
    # set_property :field_weights => {:field => number}
  end
  
  include CareerCommunity::Util
  
  has_many :comments, :class_name => "TalkComment", :foreign_key => "talk_id", :dependent => :destroy
  
  has_many :reporters, :class_name => "TalkReporter", :foreign_key => "talk_id", :dependent => :destroy
  has_many :talk_talkers, :class_name => "TalkTalker", :foreign_key => "talk_id", :dependent => :destroy
  
  has_many :question_categories, :class_name => "TalkQuestionCategory", :foreign_key => "talk_id", :dependent => :destroy
  has_many :questions, :class_name => "TalkQuestion", :foreign_key => "talk_id", :dependent => :destroy
  has_many :answers, :class_name => "TalkAnswer", :foreign_key => "talk_id", :dependent => :destroy
  
  belongs_to :creator, :class_name => "Account", :foreign_key => "creator_id"
  belongs_to :updater, :class_name => "Account", :foreign_key => "updater_id"
  
  
  has_and_belongs_to_many :companies,
                          :foreign_key => "talk_id",
                          :association_foreign_key => "company_id",
                          :join_table => "talks_companies",
                          #:order => "created_at DESC",
                          :after_add => Proc.new { |talk, company| Company.clear_talk_companies_cache(talk.id) },
                          :after_remove => Proc.new { |talk, company| Company.clear_talk_companies_cache(talk.id) }
  has_and_belongs_to_many :job_positions,
                          :foreign_key => "talk_id",
                          :association_foreign_key => "job_position_id",
                          :join_table => "talks_job_positions",
                          #:order => "created_at DESC",
                          :after_add => Proc.new { |talk, job_position| JobPosition.clear_talk_job_positions_cache(talk.id) },
                          :after_remove => Proc.new { |talk, job_position| JobPosition.clear_talk_job_positions_cache(talk.id) }
  has_and_belongs_to_many :industries,
                          :foreign_key => "talk_id",
                          :association_foreign_key => "industry_id",
                          :join_table => "talks_industries",
                          #:order => "created_at DESC",
                          :after_add => Proc.new { |talk, industry| Industry.clear_talk_industries_cache(talk.id) },
                          :after_remove => Proc.new { |talk, industry| Industry.clear_talk_industries_cache(talk.id) }
  has_and_belongs_to_many :job_processes,
                          :foreign_key => "talk_id",
                          :association_foreign_key => "job_process_id",
                          :join_table => "talks_job_processes",
                          #:order => "created_at DESC",
                          :after_add => Proc.new { |talk, job_process| JobProcess.clear_talk_job_processes_cache(talk.id) },
                          :after_remove => Proc.new { |talk, job_process| JobProcess.clear_talk_job_processes_cache(talk.id) }
  
  
  validates_presence_of :creator_id, :updater_id
  
  validates_presence_of :title, :message => "请输入 标题"
  validates_presence_of :sn, :message => "请输入 编号"
  
  validates_length_of :title, :maximum => 250, :message => "标题 超过长度限制", :allow_nil => false
  validates_length_of :sn, :maximum => 250, :message => "编号 超过长度限制", :allow_nil => false
  validates_length_of :place, :maximum => 250, :message => "地点 超过长度限制", :allow_nil => true
  
  
  
  named_scope :published, :conditions => ["published = ?", true]
  named_scope :unpublished, :conditions => ["published = ?", false]
  
  
  
  CKP_talk = :talk
  CKP_reader_content = :talk_reader_content
  CKP_talk_index_talks = :talk_index_talks
  
  FCKP_index_talk = :fc_index_talk
  FCKP_all_talks_json_list = :fc_all_talks_json_list
  
  after_save { |talk|
    self.set_talk_cache(talk)
    self.clear_reader_content_cache(talk.id)
    
    self.clear_talks_feed_cache
    self.clear_index_talk_cache
    
    self.clear_list_all_talks_cache
  }
  
  after_destroy { |talk|
    self.clear_talk_cache(talk.id)
    self.clear_reader_content_cache(talk.id)
    
    self.clear_talks_feed_cache
    self.clear_index_talk_cache
    
    self.clear_list_all_talks_cache
  }
  
  def self.clear_talks_feed_cache
    Cache.delete(expand_cache_key("#{TalksController::ACKP_talks_feed}.atom"))
  end
  
  def self.clear_index_talk_cache
    Cache.delete(expand_cache_key(FCKP_index_talk))
  end
  
  def self.clear_list_all_talks_cache
    talks_count = self.published.count
    page_count = talks_count > 0 ? (talks_count.to_f/TalksController::Talk_Page_Size).ceil : 1

    1.upto(page_count) { |i|
      Cache.delete("#{CKP_talk_index_talks}_#{i}")
      Cache.delete(expand_cache_key("#{FCKP_all_talks_json_list}_#{i}"))
    }
  end
  
  
  
  def self.get_talk_index_talks(page = 1)
    talks = Cache.get("#{CKP_talk_index_talks}_#{page}".to_sym)
    
    unless talks
      talks = self.published.paginate(
		    :page => page,
	      :per_page => TalksController::Talk_Page_Size,
	      :order => "publish_at DESC"
	    )
      
      Cache.set("#{CKP_talk_index_talks}_#{page}".to_sym, talks)
    end
    talks
  end
  
  def self.get_talk(talk_id)
    t = Cache.get("#{CKP_talk}_#{talk_id}".to_sym)
    
    unless t
      t = self.find(talk_id)
      
      self.set_talk_cache(t)
    end
    t
  end
  
  def self.set_talk_cache(talk)
    Cache.set("#{CKP_talk}_#{talk.id}".to_sym, talk.clear_association, Cache_TTL)
  end
  
  def self.clear_talk_cache(talk_id)
    Cache.delete("#{CKP_talk}_#{talk_id}".to_sym)
  end
  
  
  def self.get_reader_content(talk_id)
    Cache.get("#{CKP_reader_content}_#{talk_id}".to_sym)
  end
  
  def self.set_reader_content_cache(talk_id, content)
    Cache.set("#{CKP_reader_content}_#{talk_id}".to_sym, content, Cache_TTL)
  end
  
  def self.clear_reader_content_cache(talk_id)
    Cache.delete("#{CKP_reader_content}_#{talk_id}".to_sym)
  end
  
  
  def get_title
    self.title
  end
  
  
  def get_info
    ((self.info && self.info != "") && eval(self.info)) || {}
  end
  
  def fill_info(hash_info)
    self.info = hash_info.inspect
  end
  
  def update_info(hash_info)
    new_info = self.get_info.merge(hash_info)
    self.fill_info(new_info)
  end
  
  
  
  def clear_association
    copy = deep_copy(self)
    copy.clear_association_cache
    copy.clear_aggregation_cache
    copy
  end
  
end


