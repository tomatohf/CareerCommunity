class GroupPostCategory < ActiveRecord::Base
  
  
  has_many :posts, :class_name => "GroupPost", :foreign_key => "category_id", :dependent => :nullify
  
  
  
  validates_presence_of :group_id
  
  validates_presence_of :name, :message => "请输入 名称"
  
  validates_length_of :name, :maximum => 250, :message => "名称 超过长度限制", :allow_nil => false
  
  
  
  def self.get_categories(group_id)
    self.find(
      :all,
      :conditions => ["group_id = ?", group_id]
    )
  end
  
  
end


