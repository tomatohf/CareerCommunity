class Recruitment < ActiveRecord::Base
  
  has_and_belongs_to_many :recruitment_tags,
                          :foreign_key => "recruitment_id",
                          :association_foreign_key => "recruitment_tag_id",
                          :join_table => "recruitments_recruitment_tags"
  
  
  
  attr_protected :active, :created_at, :updated_at
  
  validates_presence_of :title, :content, :source_link
  
  validates_uniqueness_of :source_link
  
  
  
  def self.collect_new_messages(start_page = 1, page_count = 1)
    messages = {}
    RecruitmentVendor.vendor_classess.each { |vendor| messages[vendor.to_sym] = eval(vendor).instance.collect_new_messages(start_page, page_count) }
    messages
  end
  
  def self.save_new_messages(start_page = 1, page_count = 1)
    self.collect_new_messages(start_page, page_count).values.flatten.each { |message| message.save }
  end
  
  
  def self.paginate_by_catalog(page, per_page, catalog_name, catalog_value)
    self.paginate(
      :page => page,
      :per_page => per_page,
      :conditions => ["#{catalog_name} = ?", catalog_value],
      :order => "publish_time DESC",
      :include => [:recruitment_tags]
    )
  end
  
  
  
end
