class IndustryInfo < ActiveRecord::Base
  
  belongs_to :industry, :class_name => "Industry", :foreign_key => "industry_id"
  
  belongs_to :creator, :class_name => "Account", :foreign_key => "creator_id"
  belongs_to :updater, :class_name => "Account", :foreign_key => "updater_id"
  
  
  
  validates_presence_of :industry_id, :creator_id, :updater_id
  
  validates_presence_of :title, :message => "请输入 标题"
  
  validates_length_of :title, :maximum => 250, :message => "标题 超过长度限制", :allow_nil => false
  
  
  
  CKP_industry_infos_title = :industry_infos_title
  
  after_save { |industry_info|
    self.clear_industry_infos_title_cache(industry_info.industry_id)
  }
  
  after_destroy { |industry_info|
    self.clear_industry_infos_title_cache(industry_info.industry_id)
  }
  
  
  
  def self.get_industry_infos_title(industry_id)
    infos = Cache.get("#{CKP_industry_infos_title}_#{industry_id}".to_sym)
    
    unless infos
      infos = self.find(
        :all,
        :select => "title",
        :conditions => ["industry_id = ?", industry_id]
      ).collect do |info|
        [info.id, info.title]
      end
      
      Cache.set("#{CKP_industry_infos_title}_#{industry_id.id}".to_sym, infos, Cache_TTL)
    end
    infos
  end
  
  def self.clear_industry_infos_title_cache(industry_id)
    Cache.delete("#{CKP_industry_infos_title}_#{industry_id}".to_sym)
  end
  
end


