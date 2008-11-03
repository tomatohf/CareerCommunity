class Blog < ActiveRecord::Base
  
  define_index do
    # fields
    indexes :title, :content
    indexes account.nick, :as => :account_nick
    indexes comments.content, :as => :comments_content
    indexes comments.account.nick, :as => :comments_account_nick

    # attributes
    has :created_at, :updated_at
    
    set_property :delta => true
    
    # set_property :field_weights => {:field => number}
  end
  
  
  include CareerCommunity::AccountBelongings
  include CareerCommunity::Util
  
  has_many :comments, :class_name => "BlogComment", :foreign_key => "blog_id", :dependent => :destroy
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  
  
  validates_presence_of :account_id
  
  validates_presence_of :title, :message => "请输入 标题"
  validates_presence_of :content, :message => "请输入 内容"
  
  validates_length_of :title, :maximum => 256, :message => "标题 超过长度限制", :allow_nil => false
  
  
  
  FCKP_spaces_show_blog = :fc_spaces_show_blog
  
  after_save { |blog|
    self.clear_spaces_show_blog_cache(blog.account_id)
  }
  
  after_destroy { |blog|
    self.clear_spaces_show_blog_cache(blog.account_id)
  }
  
  def self.clear_spaces_show_blog_cache(account_id)
    Cache.delete(expand_cache_key("#{FCKP_spaces_show_blog}_#{account_id}"))
  end
  
  
end