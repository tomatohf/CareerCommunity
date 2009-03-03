class PersonalBookmark < ActiveRecord::Base
  
  include CareerCommunity::Util
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  
  
  validates_presence_of :account_id
  
  validates_presence_of :title, :message => "请输入 标题"
  validates_presence_of :url, :message => "请输入 地址"
  
  validates_length_of :title, :maximum => 250, :message => "标题 超过长度限制", :allow_nil => false
  
  validates_length_of :desc, :maximum => 1000, :message => "描述 超过长度限制", :allow_nil => true
  
  
  
  FCKP_spaces_show_bookmark = :fc_spaces_show_personal_bookmark
  
  after_save { |bookmark|
    self.clear_spaces_show_bookmark_cache(bookmark.account_id)
  }
  
  after_destroy { |bookmark|
    self.clear_spaces_show_bookmark_cache(bookmark.account_id)
  }
  
  def self.clear_spaces_show_bookmark_cache(account_id)
    Cache.delete(expand_cache_key("#{FCKP_spaces_show_bookmark}_#{account_id}"))
  end
  
  
  
  def is_absolute_url
    url[0, 4] == "http"
  end
  
  def get_display_url
    is_absolute_url ? url : "http://www.qiaobutang.com" + url
  end
  
  
  
end


