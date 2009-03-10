class CompanyInfo < ActiveRecord::Base
  
  belongs_to :company, :class_name => "Company", :foreign_key => "company_id"
  
  belongs_to :creator, :class_name => "Account", :foreign_key => "creator_id"
  belongs_to :updater, :class_name => "Account", :foreign_key => "updater_id"
  
  
  
  validates_presence_of :company_id, :creator_id, :updater_id
  
  validates_presence_of :title, :message => "请输入 标题"
  
  validates_length_of :title, :maximum => 250, :message => "标题 超过长度限制", :allow_nil => false
  
  
  
  CKP_company_infos_title = :company_infos_title
  
  after_save { |company_info|
    self.clear_company_infos_title_cache(company_info.company_id)
  }
  
  after_destroy { |company_info|
    self.clear_company_infos_title_cache(company_info.company_id)
  }
  
  
  
  def self.get_company_infos_title(company_id)
    infos = Cache.get("#{CKP_company_infos_title}_#{company_id}".to_sym)
    
    unless infos
      infos = self.find(
        :all,
        :select => "id, title",
        :conditions => ["company_id = ?", company_id]
      ).collect do |info|
        [info.id, info.title]
      end
      
      Cache.set("#{CKP_company_infos_title}_#{company_id}".to_sym, infos, Cache_TTL)
    end
    infos
  end
  
  def self.clear_company_infos_title_cache(company_id)
    Cache.delete("#{CKP_company_infos_title}_#{company_id}".to_sym)
  end
  
end


