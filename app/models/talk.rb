class Talk < ActiveRecord::Base
  
  include CareerCommunity::Util
  
  has_many :comments, :class_name => "TalkComment", :foreign_key => "talk_id", :dependent => :destroy
  
  has_many :reporters, :class_name => "TalkReporter", :foreign_key => "talk_id", :dependent => :destroy
  has_many :talk_talkers, :class_name => "TalkTalker", :foreign_key => "talk_id", :dependent => :destroy
  
  has_many :question_categories, :class_name => "TalkQuestionCategory", :foreign_key => "talk_id", :dependent => :destroy
  has_many :questions, :class_name => "TalkQuestion", :foreign_key => "talk_id", :dependent => :destroy
  
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
  
  
  validates_presence_of :creator_id, :updater_id
  
  validates_presence_of :title, :message => "请输入 标题"
  validates_presence_of :sn, :message => "请输入 编号"
  
  validates_length_of :title, :maximum => 250, :message => "标题 超过长度限制", :allow_nil => false
  validates_length_of :sn, :maximum => 250, :message => "编号 超过长度限制", :allow_nil => false
  validates_length_of :place, :maximum => 250, :message => "地点 超过长度限制", :allow_nil => true
  
  
  
  named_scope :published, :conditions => ["published = ?", true]
  named_scope :unpublished, :conditions => ["published = ?", false]
  
  
  
  CKP_talk = :talk
  
  after_save { |talk|
    self.set_talk_cache(talk)
  }
  
  after_destroy { |talk|
    self.clear_talk_cache(talk.id)
  }
  
  
  
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


