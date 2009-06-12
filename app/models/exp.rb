class Exp < ActiveRecord::Base
  
  define_index do
    # fields
    indexes :title, :content

    # attributes
    has :created_at, :publish_time, :active, :account_id
    
    set_property :delta => true
    
    # set_property :field_weights => {:field => number}
  end
  
  include CareerCommunity::Util
  
  has_and_belongs_to_many :companies,
                          :foreign_key => "exp_id",
                          :association_foreign_key => "company_id",
                          :join_table => "exps_companies"
  has_and_belongs_to_many :job_positions,
                          :foreign_key => "exp_id",
                          :association_foreign_key => "job_position_id",
                          :join_table => "exps_job_positions"
  
  
  
  attr_protected :active, :created_at, :updated_at
  
  validates_presence_of :title, :message => "请输入 标题"
  validates_presence_of :content, :message => "请输入 内容"
  
  # validates_presence_of :source_link, :message => "请输入 来源链接"
  # validates_format_of :source_link, :with => %r{^http[^\s]*$}i, :message => "请输入格式正确的 来源链接"
  validates_uniqueness_of :source_link, :case_sensitive => false, :allow_nil => true, :allow_blank => true, :message => "来源链接 已存在"
  
  
  
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
    /bebeyond/i,
    
    /51mianjing/i
  ]
  
  
  FCKP_index_list = :fc_index_exp_list
  
  FCKP_community_index_list = :fc_community_index_exp_list
  
  after_destroy { |exp|
    self.clear_exps_feed_cache
    
    self.clear_index_list_cache
  }
  
  after_save { |exp|
    self.clear_exps_feed_cache
    
    self.clear_index_list_cache
  }
  
  def self.clear_exps_feed_cache
    Cache.delete(expand_cache_key("#{ExpsController::ACKP_exps_feed}.atom"))
  end
  
  def self.clear_index_list_cache
    Cache.delete(expand_cache_key(FCKP_index_list))
    
    Cache.delete(expand_cache_key(FCKP_community_index_list))
  end
  
  
  
  def self.save_new_messages(start_page = 1, page_count = 1)
    ExpVendor.vendor_classess.each { |vendor| eval(vendor).instance.save_new_messages(start_page, page_count) }
  end
  
  def self.save_new_messages_of_one_vendor(vendor_class_name, start_page = 1, page_count = 1)
    vendor_class_name = "ExpVendor::#{vendor_class_name}" unless vendor_class_name =~ /^ExpVendor/
    
    eval(vendor_class_name).instance.save_new_messages(start_page, page_count)
  end
  
  def self.filter_out_by_key_words
    all_ids = self.find(:all, :select => "id")
    all_ids.each do |id|
      r = self.find(id.id)
      
      Filter_Out_Key_Words.each do |word|
        if r.title =~ word || r.content =~ word
          puts "id #{r.id} with title #{r.title} will be deleted"
          
          r.destroy
          
          break
        end
      end
      
      puts "id #{r.id} with title #{r.title} passed"
    end
  end
  
  
  
end
