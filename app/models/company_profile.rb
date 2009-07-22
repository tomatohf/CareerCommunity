class CompanyProfile < ActiveRecord::Base
  
  acts_as_trashable
  
  
  belongs_to :company, :class_name => "Company", :foreign_key => "company_id"
  
  belongs_to :creator, :class_name => "Account", :foreign_key => "creator_id"
  belongs_to :updater, :class_name => "Account", :foreign_key => "updater_id"
  
  belongs_to :photo, :class_name => "Photo", :foreign_key => "photo_id"
  
  
  validates_presence_of :company_id, :updater_id
  
  
  
  Properties = [
		[:company_type, "公司类型"],
		[:establish_at, "成立时间"],
		[:product, "代表产品"],
		
		[:website, "公司网站"]
	]
  
  
  
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
  
  
  def self.get_profile(company_id)
    self.find(
      :first,
      :conditions => ["company_id = ?", company_id]
    )
  end
  
end