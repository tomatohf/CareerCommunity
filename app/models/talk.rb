class Talk < ActiveRecord::Base
  
  include CareerCommunity::Util
  
  has_many :comments, :class_name => "TalkComment", :foreign_key => "talk_id", :dependent => :destroy
  
  belongs_to :creator, :class_name => "Account", :foreign_key => "creator_id"
  belongs_to :updater, :class_name => "Account", :foreign_key => "updater_id"
  
  
  validates_presence_of :creator_id, :updater_id
  
  validates_presence_of :title, :message => "请输入 标题"
  validates_presence_of :sn, :message => "请输入 编号"
  
  validates_length_of :title, :maximum => 250, :message => "标题 超过长度限制", :allow_nil => false
  validates_length_of :sn, :maximum => 250, :message => "编号 超过长度限制", :allow_nil => false
  validates_length_of :place, :maximum => 250, :message => "地点 超过长度限制", :allow_nil => true
  
  
  
  named_scope :published, :conditions => ["published = ?", true]
  named_scope :unpublished, :conditions => ["published = ?", false]
  
  
  
  # CKP_<some_key> = :<value>
  
  after_save { |talk|
    
  }
  
  after_destroy { |talk|
    
  }
  
  
  
  def get_title
    self.title
  end
  
  
  def get_info
    ((self.info && self.info != "") && eval(self.info)) || {}
  end
  
  def fill_info(hash_info)
    self.info = hash_info.inspect
  end
  
  def update_info(hash_info)
    new_info = self.get_info.merge(hash_info)
    self.fill_info(new_info)
  end
  
  
  
  def clear_association
    copy = deep_copy(self)
    copy.clear_association_cache
    copy.clear_aggregation_cache
    copy
  end
  
end


