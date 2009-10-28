class Recruitment < ActiveRecord::Base
  
  include CareerCommunity::Util
  
  has_and_belongs_to_many :recruitment_tags,
                          :foreign_key => "recruitment_id",
                          :association_foreign_key => "recruitment_tag_id",
                          :join_table => "recruitments_recruitment_tags",
                          :after_add => Proc.new { |r, rt| RecruitmentTag.clear_top_tags_cache },
                          :after_remove => Proc.new { |r, rt| RecruitmentTag.clear_top_tags_cache }
  has_and_belongs_to_many :companies,
                          :foreign_key => "recruitment_id",
                          :association_foreign_key => "company_id",
                          :join_table => "recruitments_companies"
  has_and_belongs_to_many :job_positions,
                          :foreign_key => "recruitment_id",
                          :association_foreign_key => "job_position_id",
                          :join_table => "recruitments_job_positions"
                          
                          
                          
  define_index do
    # fields
    indexes :title, :content, :location
    indexes recruitment_tags.name, :as => :recruitment_tags_name

    # attributes
    has :recruitment_type, :publish_time

    set_property :delta => true

    # set_property :field_weights => {:field => number}
  end
  
  
  
  attr_protected :active, :created_at, :updated_at
  
  validates_presence_of :title, :message => "请输入 标题"
  validates_presence_of :content, :message => "请输入 内容"
  validates_presence_of :source_link, :message => "请输入 来源链接"
  
  validates_format_of :source_link, :with => %r{^http[^\s]*$}i, :message => "请输入格式正确的 来源链接"
  
  validates_uniqueness_of :source_link, :case_sensitive => false, :message => "来源链接 已存在, 可能该信息已存在. 试试发布其他信息吧"
  
  
  
  Type_fulltime = 1
  Type_parttime = 2
  Type_lecture = 3
  Type_jobfair = 4
  
  @@all_recruitment_types = {
    Type_fulltime => "全职",
    Type_parttime => "兼职",
    Type_lecture => "宣讲会",
    Type_jobfair => "招聘会"
  }
  def self.recruitment_types
    @@all_recruitment_types
  end
  
  def self.recruitment_type_label(type)
    @@all_recruitment_types[type]
  end
  
  
  named_scope :fulltime, :conditions => ["recruitment_type = ?", Type_fulltime]
  named_scope :parttime, :conditions => ["recruitment_type = ?", Type_parttime]
  named_scope :lecture, :conditions => ["recruitment_type = ?", Type_lecture]
  named_scope :jobfair, :conditions => ["recruitment_type = ?", Type_jobfair]
  
  
  
  def self.get_recruitment_type_scope(recruitment_type)
    case recruitment_type
      when Type_fulltime
        self.fulltime
      when Type_parttime
        self.parttime
      when Type_lecture
        self.lecture
      when Type_jobfair
        self.jobfair
      else
        self
      end
  end
  
  
  
  Filter_Out_Key_Words = [
    /hiall/i,
    /utomorrow/i,
    /54yjs/i,
    /yingjiesheng/i,
    /loooker/i,
    /2588/i,
    /guolairen/i,
    /hongyangedu/i,
    /5imeet/i,
    /bebeyond/i
  ]
  
  
  CKP_locations = :recruitment_locations
  
  FCKP_index_fulltime = :fc_index_fulltime_recruitments
  FCKP_index_parttime = :fc_index_parttime_recruitments
  FCKP_index_lecture = :fc_index_lecture_recruitments
  FCKP_index_jobfair = :fc_index_jobfair_recruitments
  
  FCKP_community_index_fulltime = :fc_community_index_fulltime_recruitments
  FCKP_community_index_parttime = :fc_community_index_parttime_recruitments
  FCKP_community_index_lecture = :fc_community_index_lecture_recruitments
  FCKP_community_index_jobfair = :fc_community_index_jobfair_recruitments
  
  after_destroy { |r|
    self.clear_locations_cache
    
    
    self.clear_recruitments_feed_cache
    
    self.clear_index_lecture_cache if r.recruitment_type == Type_lecture
    self.clear_index_fulltime_cache if r.recruitment_type == Type_fulltime
    self.clear_index_parttime_cache if r.recruitment_type == Type_parttime
    self.clear_index_jobfair_cache if r.recruitment_type == Type_jobfair
  }
  
  after_save { |r|
    self.clear_locations_cache
    
    
    self.clear_recruitments_feed_cache
    
    self.clear_index_lecture_cache if r.recruitment_type == Type_lecture
    self.clear_index_fulltime_cache if r.recruitment_type == Type_fulltime
    self.clear_index_parttime_cache if r.recruitment_type == Type_parttime
    self.clear_index_jobfair_cache if r.recruitment_type == Type_jobfair
  }
  
  def self.clear_recruitments_feed_cache
    Cache.delete(expand_cache_key("#{RecruitmentsController::ACKP_recruitments_feed}.atom"))
  end
  
  def self.clear_index_lecture_cache
    Cache.delete(expand_cache_key(FCKP_index_lecture))
    
    Cache.delete(expand_cache_key(FCKP_community_index_lecture))
  end
  
  def self.clear_index_fulltime_cache
    Cache.delete(expand_cache_key(FCKP_index_fulltime))
    
    Cache.delete(expand_cache_key(FCKP_community_index_fulltime))
  end
  
  def self.clear_index_parttime_cache
    Cache.delete(expand_cache_key(FCKP_index_parttime))
    
    Cache.delete(expand_cache_key(FCKP_community_index_parttime))
  end
  
  def self.clear_index_jobfair_cache
    Cache.delete(expand_cache_key(FCKP_index_jobfair))
    
    Cache.delete(expand_cache_key(FCKP_community_index_jobfair))
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
  
  def self.filter_out_by_key_words
    all_ids = Recruitment.find(:all, :select => "id")
    all_ids.each do |id|
      r = Recruitment.find(id.id)
      
      Filter_Out_Key_Words.each do |word|
        if r.title =~ word || r.content =~ word
          puts "id #{r.id} with title #{r.title} will be deleted"
          r.recruitment_tags.clear
          r.destroy
          break
        end
      end
      
      puts "id #{r.id} with title #{r.title} passed"
    end
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
