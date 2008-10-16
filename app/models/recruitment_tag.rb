class RecruitmentTag < ActiveRecord::Base
  
  has_and_belongs_to_many :recruitments,
                          :foreign_key => "recruitment_tag_id",
                          :association_foreign_key => "recruitment_id",
                          :join_table => "recruitments_recruitment_tags",
                          :order => "publish_time DESC",
                          :after_add => :clear_top_tags_cache,
                          :after_remove => :clear_top_tags_cache

  # ---

  validates_presence_of :name
  validates_uniqueness_of :name
  
  CKP_top_tags = :recruitment_top_tags
  
  after_destroy { |tag|
    self.clear_top_tags_cache
  }
  
  after_save { |tag|
    self.clear_top_tags_cache
  }
  
  
  
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
  
  def self.get_top_tags
    tags = Cache.get(CKP_top_tags)
    unless tags
      tag_objects = tags(:order => "count DESC", :limit => 200)
      tags = tag_objects.collect { |tag_obj| [tag_obj.id, tag_obj.name, tag_obj.count.to_i] }
      
      Cache.set(CKP_top_tags, tags, Cache_TTL)
    end
    tags
  end
  
  def self.clear_top_tags_cache
    Cache.delete(CKP_top_tags)
  end
  
  
  
end
