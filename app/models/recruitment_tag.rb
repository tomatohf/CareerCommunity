class RecruitmentTag < ActiveRecord::Base
  
  has_and_belongs_to_many :recruitments, :foreign_key => ":recruitment_id", :join_table => "recruitments_recruitment_tags"

  # ---

  validates_presence_of :name
  validates_uniqueness_of :name
  
  
  
  def self.get_tag(tag_name)
    self.find(:first, :conditions => ["name = ?", tag_name]) || self.new(:name => tag_name)
  end
  
  
  def self.tags(options = {})
    query = "select recruitment_tags.id, name, count(*) as count"
    query << " from recruitments_recruitment_tags, recruitment_tags"
    query << " where recruitment_tags.id = recruitment_tag_id"
    query << " group by recruitment_tag_id"
    query << " order by #{options[:order]}" if options[:order] != nil
    query << " limit #{options[:limit]}" if options[:limit] != nil
    tags = self.find_by_sql(query)
  end
  
  
  
end
