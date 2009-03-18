class JobPositionInfo < ActiveRecord::Base
  
  acts_as_trashable
  
  
  belongs_to :job_position, :class_name => "JobPosition", :foreign_key => "job_position_id"
  
  belongs_to :creator, :class_name => "Account", :foreign_key => "creator_id"
  belongs_to :updater, :class_name => "Account", :foreign_key => "updater_id"
  
  
  
  has_and_belongs_to_many :industries,
                          :foreign_key => "job_position_info_id",
                          :association_foreign_key => "industry_id",
                          :join_table => "job_position_infos_industries"
  has_and_belongs_to_many :companies,
                          :foreign_key => "job_position_info_id",
                          :association_foreign_key => "company_id",
                          :join_table => "job_position_infos_companies"
  
  
  
  validates_presence_of :job_position_id, :creator_id, :updater_id
  
  validates_presence_of :title, :message => "请输入 标题"
  
  validates_length_of :title, :maximum => 250, :message => "标题 超过长度限制", :allow_nil => false
  
  
  
  CKP_job_position_infos_title = :job_position_infos_title
  
  after_save { |job_position_info|
    self.clear_job_position_infos_title_cache(job_position_info.job_position_id)
  }
  
  after_destroy { |job_position_info|
    self.clear_job_position_infos_title_cache(job_position_info.job_position_id)
  }
  
  
  
  def self.get_job_position_infos_title(job_position_id)
    infos = Cache.get("#{CKP_job_position_infos_title}_#{job_position_id}".to_sym)
    
    unless infos
      infos = self.find(
        :all,
        :select => "id, title",
        :conditions => ["job_position_id = ?", job_position_id]
      )
      
      Cache.set("#{CKP_job_position_infos_title}_#{job_position_id}".to_sym, infos, Cache_TTL)
    end
    infos
  end
  
  def self.clear_job_position_infos_title_cache(job_position_id)
    Cache.delete("#{CKP_job_position_infos_title}_#{job_position_id}".to_sym)
  end
  
  
  def self.load_industries_and_companies(infos)
    preload_associations(infos, [:industries, :companies])
  end
  
end


