class JobInfo < ActiveRecord::Base
  
  define_index do
    # fields
    indexes :title, :content

    # attributes
    has :created_at, :updated_at, :creator_id, :updater_id, :general
    
    set_property :delta => true
    
    # set_property :field_weights => {:field => number}
  end
  
  
  
  has_and_belongs_to_many :industries,
                          :foreign_key => "job_info_id",
                          :association_foreign_key => "industry_id",
                          :join_table => "job_infos_industries"
  has_and_belongs_to_many :companies,
                          :foreign_key => "job_info_id",
                          :association_foreign_key => "company_id",
                          :join_table => "job_infos_companies"
  has_and_belongs_to_many :job_positions,
                          :foreign_key => "job_info_id",
                          :association_foreign_key => "job_position_id",
                          :join_table => "job_infos_job_positions"
  has_and_belongs_to_many :job_processes,
                          :foreign_key => "job_info_id",
                          :association_foreign_key => "job_process_id",
                          :join_table => "job_infos_job_processes"
  has_and_belongs_to_many :job_info_categories,
                          :foreign_key => "job_info_id",
                          :association_foreign_key => "job_info_category_id",
                          :join_table => "job_infos_job_info_categories"
  
  
  
  belongs_to :creator, :class_name => "Account", :foreign_key => "creator_id"
  belongs_to :updater, :class_name => "Account", :foreign_key => "updater_id"
  
  
  
  validates_presence_of :title, :message => "请输入 标题"
  
  validates_length_of :title, :maximum => 250, :message => "标题 超过长度限制", :allow_nil => false
  
  
  
  named_scope :general, :conditions => ["general = ?", true]
  
  
    
end


