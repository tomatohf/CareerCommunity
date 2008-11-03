class Photo < ActiveRecord::Base
  
  include CareerCommunity::Util
  
  belongs_to :album, :class_name => "Album", :foreign_key => "album_id"
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  
  has_many :comments, :class_name => "PhotoComment", :foreign_key => "photo_id", :dependent => :destroy

  has_one :covered_album, :class_name => "Album", :foreign_key => "cover_photo_id", :dependent => :nullify

  has_one :pic_profile, :class_name => "PicProfile", :foreign_key => "photo_id", :dependent => :destroy
  
  has_one :group_image, :class_name => "GroupImage", :foreign_key => "photo_id", :dependent => :destroy

  has_one :activity_image, :class_name => "ActivityImage", :foreign_key => "photo_id", :dependent => :destroy
  
  has_many :activity_photos, :class_name => "ActivityPhoto", :foreign_key => "photo_id", :dependent => :destroy
  has_many :group_photos, :class_name => "GroupPhoto", :foreign_key => "photo_id", :dependent => :destroy
  
  has_one :vote_image, :class_name => "VoteImage", :foreign_key => "photo_id", :dependent => :destroy
  
  
  
  FCKP_spaces_show_photo = :fc_spaces_show_photo

  after_destroy { |photo|
    # clean album cover photo
    Album.clear_album_cover_photo_cache(photo.album_id)
    
    # clean account pic 
    PicProfile.find(:all, :conditions => ["photo_id = ?", photo.id]).each do |pp|
      Account.clear_account_nick_pic_cache(pp.account_id)
    end
    
    # clean group image
    GroupImage.find(:all, :conditions => ["photo_id = ?", photo.id]).each do |gi|
      Group.clear_group_with_image_cache(gi.group_id)
    end
    
    # clean activity image
    ActivityImage.find(:all, :conditions => ["photo_id = ?", photo.id]).each do |ai|
      Activity.clear_activity_with_image_cache(ai.activity_id)
    end
    
    # clean vote topic image
    VoteImage.find(:all, :conditions => ["photo_id = ?", photo.id]).each do |vi|
      VoteTopic.clear_vote_topic_with_image_cache(vi.vote_topic_id)
    end
    
    # clean the album photos
    Album.clear_album_photos_cache(photo.album_id)
    
    
    self.clear_spaces_show_photo_cache(photo.account_id)
  }
  
  after_save { |photo|
    Album.clear_album_photos_cache(photo.album_id)
    
    
    self.clear_spaces_show_photo_cache(photo.account_id)
  }

  def self.clear_spaces_show_photo_cache(account_id)
    Cache.delete(expand_cache_key("#{FCKP_spaces_show_photo}_#{account_id}"))
  end
  
  
  # paperclip
  has_attached_file :image, :styles => {
    :big => "800x600>",
    :normal => "600x600>",
    :thumb_200 => "200x200>",
    :thumb_120 => "120x120>",
    :thumb_80 => "80x80>",
    :thumb_48 => "48x48#"
  },
    :url => "/system/files/:class_:attachment/:album_id/:id/:style_:id.:extension",
    :path => ":rails_root/public/system/files/:class_:attachment/:album_id/:id/:style_:id.:extension",
    :storage => :filesystem,
    :whiny_thumbnails => false # to avoid displaying internal errors

  validates_attachment_presence :image, :message => "请选择 图片文件"
  validates_attachment_content_type :image, :content_type => [
    "image/jpg", "image/jpeg", "image/gif", "image/png", "image/bmp",
    
    # to be compatible with IE ...
    "image/pjpeg", "image/x-png"
  ], :message => "只能上传 JPG, JPEG, GIF, PNG 或 BMP 格式的图片"
  validates_attachment_size :image, :less_than => 3.megabyte, :message => "每个图片文件大小不能超过 3M"
  # to avoid displaying internal errors
  # validates_attachment_thumbnails :image
  
  
  validates_presence_of :account_id, :album_id
  
  validates_length_of :title, :maximum => 256, :message => "照片描述 超过长度限制", :allow_nil => true
  
  
  
  # Fix the mime types. Make sure to require the mime-types gem
  def swfupload_file=(data)
    data.content_type = MIME::Types.type_for(data.original_filename).to_s if data
    self.image = data
  end
  
end