class JobPosition < ActiveRecord::Base
  
  define_index do
    # fields
    indexes :name, :desc

    # attributes
    has :created_at, :updated_at, :account_id
    
    set_property :delta => true
    
    # set_property :field_weights => {:field => number}
  end
  
  
  
  has_and_belongs_to_many :talks,
                          :foreign_key => "job_position_id",
                          :association_foreign_key => "talk_id",
                          :join_table => "talks_job_positions",
                          #:order => "created_at DESC",
                          :after_add => Proc.new { |job_position, talk| JobPosition.clear_talk_job_positions_cache(talk.id) },
                          :after_remove => Proc.new { |job_position, talk| JobPosition.clear_talk_job_positions_cache(talk.id) }
  
  
  
  validates_presence_of :name, :message => "请输入 名称"
  
  validates_uniqueness_of :name, :case_sensitive => false, :scope => :account_id, :message => "名称 已经存在"
  
  validates_length_of :name, :maximum => 256, :message => "名称 超过长度限制", :allow_nil => false
  validates_length_of :desc, :maximum => 1000, :message => "英文名或其他常用名 超过长度限制", :allow_nil => true
  
  
  
  named_scope :system, :conditions => ["account_id = ? or account_id = ?", 0, nil]
  
  
  
  CKP_account_positions = :account_positions
  CKP_position = :position
  
  CKP_talk_job_positions = :talk_job_positions
  
  after_save { |position|
    self.clear_talk_related_cache(position.id)
    
    self.clear_account_positions_cache(position.account_id) if position.account_id && position.account_id > 0
    
    self.set_position_cache(position)
  }
  
  after_destroy { |position|
    self.clear_talk_related_cache(position.id)
    
    self.clear_account_positions_cache(position.account_id) if position.account_id && position.account_id > 0
    
    self.clear_position_cache(position.id)
  }
  
  def self.clear_talk_related_cache(position_id)
    job_position = JobPosition.get_position(position_id)
    job_position.talks.each do |talk|
      self.clear_talk_job_positions_cache(talk.id)
    end
  end
  
  
  
  
  def self.get_account_positions(account_id)
    a_p = Cache.get("#{CKP_account_positions}_#{account_id}".to_sym)
    
    unless a_p
      a_p = self.find(:all, :conditions => ["account_id = ?", account_id], :order => "created_at DESC")
      
      # set individual position cache
      a_p.each { |p| self.set_position_cache(p) }
      
      Cache.set("#{CKP_account_positions}_#{account_id}".to_sym, a_p, Cache_TTL)
    end
    a_p
  end
  
  def self.clear_account_positions_cache(account_id)
    Cache.delete("#{CKP_account_positions}_#{account_id}".to_sym)
  end
  
  
  require_dependency "job_target"
  require_dependency "job_step"
  require_dependency "company"
  def self.get_position(position_id)
    p = Cache.get("#{CKP_position}_#{position_id}".to_sym)
    
    unless p
      p = self.find(position_id)
      
      self.set_position_cache(p)
    end
    p
  end
  class << self
    alias_method :get_job_position, :get_position
    alias_method :get_account_job_positions, :get_account_positions
  end
  
  def self.set_position_cache(position)
    Cache.set("#{CKP_position}_#{position.id}".to_sym, position, Cache_TTL)
  end
  
  def self.clear_position_cache(position_id)
    Cache.delete("#{CKP_position}_#{position_id}".to_sym)
  end
  
  
  def self.get_talk_job_positions(talk_id)
    jps = Cache.get("#{CKP_talk_job_positions}_#{talk_id}".to_sym)
    
    unless jps
      talk = Talk.get_talk(talk_id)
      
      jps = []
      talk.job_positions.each { |jp|
        self.set_position_cache(jp)
        jps << jp
      }
      
      Cache.set("#{CKP_talk_job_positions}_#{talk_id}".to_sym, jps, Cache_TTL)
    end
    jps
  end
  
  def self.clear_talk_job_positions_cache(talk_id)
    Cache.delete("#{CKP_talk_job_positions}_#{talk_id}".to_sym)
  end
  
  
end


