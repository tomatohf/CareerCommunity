class Recruitment < ActiveRecord::Base
  
  has_and_belongs_to_many :recruitment_tags, :foreign_key => "recruitment_tag_id"
  
  
  
  attr_protected :active, :created_at, :updated_at
  
  validates_presence_of :title, :content, :source_link
  
  validates_uniqueness_of :source_link
  
  
  
  def self.collect_new_messages
    messages = {}
    RecruitmentVendor.vendor_classess.each { |vendor| messages[vendor.to_sym] = eval(vendor).instance.collect_new_messages }
    messages
  end
  
  def self.save_new_messages
    self.collect_new_messages.values.flatten.each { |message| message.save }
  end
  
  
  
end
