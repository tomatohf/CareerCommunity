class Recruitment < ActiveRecord::Base
  
  define_index do
    # fields
    indexes :title, :content, :location, :recruitment_type
    indexes recruitment_tags.name, :as => :recruitment_tags_name

    # attributes
    has :created_at, :updated_at, :publish_time
    
    set_property :delta => true
    
    # set_property :field_weights => {:field => number}
  end
  
  include CareerCommunity::Util
  
  has_and_belongs_to_many :recruitment_tags,
                          :foreign_key => "recruitment_id",
                          :association_foreign_key => "recruitment_tag_id",
                          :join_table => "recruitments_recruitment_tags",
                          :after_add => Proc.new { |r, rt| RecruitmentTag.clear_top_tags_cache },
                          :after_remove => Proc.new { |r, rt| RecruitmentTag.clear_top_tags_cache }
  
  
  
  attr_protected :active, :created_at, :updated_at
  
  validates_presence_of :title, :message => "请输入 标题"
  validates_presence_of :content, :message => "请输入 内容"
  validates_presence_of :source_link, :message => "请输入 来源链接"
  
  validates_format_of :source_link, :with => %r{^http[^\s]*$}i, :message => "请输入格式正确的 来源链接"
  
  validates_uniqueness_of :source_link, :case_sensitive => false, :message => "来源链接 已存在, 可能该信息已存在. 试试发布其他信息吧"
  
  CKP_types = :recruitment_types
  CKP_locations = :recruitment_locations
  
  after_destroy { |r|
    self.clear_types_cache
    self.clear_locations_cache
    
    
    self.clear_recruitments_index_cache
    self.clear_recruitments_show_cache(r)
    self.clear_recruitments_feed_cache
  }
  
  after_save { |r|
    self.clear_types_cache
    self.clear_locations_cache
    
    
    self.clear_recruitments_index_cache
    self.clear_recruitments_show_cache(r)
    self.clear_recruitments_feed_cache
  }
  
  def self.clear_recruitments_index_cache
    recruitment_count = self.count
    index_page_count = recruitment_count > 0 ? (recruitment_count.to_f/RecruitmentsController::Recruitment_List_Size).ceil : 1

    1.upto(index_page_count) { |i|
      Cache.delete(expand_cache_key("#{RecruitmentsController::ACKP_recruitments_index}_#{i}"))
    }
  end
  
  def self.clear_recruitments_show_cache(recruitment)
    Cache.delete(expand_cache_key("#{RecruitmentsController::ACKP_recruitments_show}_#{recruitment.id}"))
  end
  
  def self.clear_recruitments_feed_cache
    Cache.delete(expand_cache_key("#{RecruitmentsController::ACKP_recruitments_feed}.atom"))
  end
  
  
  
  def self.collect_new_messages(start_page = 1, page_count = 1)
    messages = {}
    RecruitmentVendor.vendor_classess.each { |vendor| messages[vendor.to_sym] = eval(vendor).instance.collect_new_messages(start_page, page_count) }
    messages
  end
  
  def self.save_new_messages(start_page = 1, page_count = 1)
    RecruitmentVendor.vendor_classess.each { |vendor| eval(vendor).instance.save_new_messages(start_page, page_count) }
  end
  
  def self.save_new_messages_of_one_vendor(vendor_class_name, start_page = 1, page_count = 1)
    vendor_class_name = "RecruitmentVendor::#{vendor_class_name}" unless vendor_class_name =~ /^RecruitmentVendor/
    
    eval(vendor_class_name).instance.save_new_messages(start_page, page_count)
  end
  
  
  
  def self.paginate_by_catalog(page, per_page, catalog_name, catalog_value)
    self.paginate(
      :page => page,
      :per_page => per_page,
      :select => "id, title, publish_time, location, recruitment_type",
      :conditions => ["#{catalog_name} = ?", catalog_value],
      :order => "publish_time DESC",
      :include => [:recruitment_tags]
    )
  end
  
  
  def self.get_types
    types = Cache.get(CKP_types)
    unless types
      types = self.find(:all, :select => "DISTINCT recruitment_type").collect { |r| r.recruitment_type }.select { |t| t && t !="" }
      
      Cache.set(CKP_types, types, Cache_TTL)
    end
    types
  end
  
  def self.clear_types_cache
    Cache.delete(CKP_types)
  end
  
  def self.get_locations
    locations = Cache.get(CKP_locations)
    unless locations
      locations = self.find(:all, :select => "DISTINCT location").collect { |r| r.location }.select { |l| l && l !="" }
      
      Cache.set(CKP_locations, locations, Cache_TTL)
    end
    locations
  end
  
  def self.clear_locations_cache
    Cache.delete(CKP_locations)
  end
  
  
  
end
