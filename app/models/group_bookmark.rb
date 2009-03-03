class GroupBookmark < ActiveRecord::Base
  
  include CareerCommunity::Util
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :group, :class_name => "Group", :foreign_key => "group_id"
  
  
  validates_presence_of :account_id, :group_id
  
  validates_presence_of :title, :message => "请输入 标题"
  validates_presence_of :url, :message => "请输入 地址"
  
  validates_length_of :title, :maximum => 250, :message => "标题 超过长度限制", :allow_nil => false
  
  validates_length_of :desc, :maximum => 1000, :message => "描述 超过长度限制", :allow_nil => true
  
  
  
  FCKP_groups_show_bookmark = :fc_groups_show_personal_bookmark
  
  after_save { |bookmark|
    self.clear_groups_show_bookmark_cache(bookmark.group_id)
  }
  
  after_destroy { |bookmark|
    self.clear_groups_show_bookmark_cache(bookmark.group_id)
  }
  
  def self.clear_groups_show_bookmark_cache(group_id)
    Cache.delete(expand_cache_key("#{FCKP_groups_show_bookmark}_#{group_id}"))
  end
  
  
  
  def is_absolute_url
    url[0, 4] == "http"
  end
  
  def get_display_url
    is_absolute_url ? url : "http://www.qiaobutang.com" + url
  end
  
  
  
end


