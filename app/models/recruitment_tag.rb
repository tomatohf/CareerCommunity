class RecruitmentTag < ActiveRecord::Base
  
  has_and_belongs_to_many :recruitments, :foreign_key => ":recruitment_id"

  # ---

  validates_presence_of :name
  validates_uniqueness_of :name
  
  
  
  def self.get_tag(tag_name)
    self.find(:first, :conditions => ["name = ?", tag_name]) || self.new(:name => tag_name)
  end
  
end
