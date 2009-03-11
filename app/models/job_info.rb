class JobInfo < ActiveRecord::Base
  
  define_index do
    # fields
    indexes :title, :content

    # attributes
    has :created_at, :updated_at, :creator_id, :updater_id, :general
    
    set_property :delta => true
    
    # set_property :field_weights => {:field => number}
  end
  
  
  
  belongs_to :creator, :class_name => "Account", :foreign_key => "creator_id"
  belongs_to :updater, :class_name => "Account", :foreign_key => "updater_id"
  
  
  
  validates_presence_of :title, :message => "请输入 标题"
  
  validates_length_of :title, :maximum => 250, :message => "标题 超过长度限制", :allow_nil => false
  
  
  
  named_scope :general, :conditions => ["general = ?", true]
  
  
    
end


