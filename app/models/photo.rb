class Photo < ActiveRecord::Base
  
  include CareerCommunity::Util
  
  belongs_to :album, :class_name => "Album", :foreign_key => "album_id"
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  
  has_many :comments, :class_name => "PhotoComment", :foreign_key => "photo_id", :dependent => :destroy

  has_one :covered_album, :class_name => "Album", :foreign_key => "cover_photo_id", :dependent => :nullify

  has_many :pic_profile, :class_name => "PicProfile", :foreign_key => "photo_id", :dependent => :destroy
  
  has_many :group_image, :class_name => "GroupImage", :foreign_key => "photo_id", :dependent => :destroy

  has_many :activity_image, :class_name => "ActivityImage", :foreign_key => "photo_id", :dependent => :destroy
  
  has_many :activity_photos, :class_name => "ActivityPhoto", :foreign_key => "photo_id", :dependent => :destroy
  has_many :group_photos, :class_name => "GroupPhoto", :foreign_key => "photo_id", :dependent => :destroy
  
  has_many :vote_image, :class_name => "VoteImage", :foreign_key => "photo_id", :dependent => :destroy
  
  has_one :company_profile, :class_name => "CompanyProfile", :foreign_key => "photo_id", :dependent => :nullify
  
  
  
  # paperclip
  has_attached_file :image, :styles => {
    :big => "800x600>",
    :normal => "600x600>",
    :thumb_200 => "200x200>",
    :thumb_120 => "120x120>",
    :thumb_80 => "80x80>",
    :thumb_48 => "48x48#"
  },
    #:url => "/system/files/:class_:attachment/:album_id/:id/:style_:id.:extension",
    #:path => ":rails_root/public/system/files/:class_:attachment/:album_id/:id/:style_:id.:extension",
    :url => "/system/files/:class_:attachment/:created_year/:created_month/:created_mday/:id/:style_:id.:extension",
    :path => ":rails_root/public/system/files/:class_:attachment/:created_year/:created_month/:created_mday/:id/:style_:id.:extension",
    :default_url => "",
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
  
  
  
  FCKP_spaces_show_photo = :fc_spaces_show_photo

  after_destroy { |photo|
    self.clear_photo_cache(photo.id)
    
    # clean album cover photo
    Album.clear_album_cover_photo_cache(photo.album_id)
    
    # clean the album photos
    Album.clear_album_photos_cache(photo.album_id)
    
    
    self.clear_spaces_show_photo_cache(photo.account_id)
  }
  
  after_save { |photo|
    self.clear_photo_cache(photo.id)
    
    Album.clear_album_photos_cache(photo.album_id)
    
    
    self.clear_spaces_show_photo_cache(photo.account_id)
  }

  def self.clear_spaces_show_photo_cache(account_id)
    Cache.delete(expand_cache_key("#{FCKP_spaces_show_photo}_#{account_id}"))
  end
  
  
  after_update { |photo|
    
    if photo.album_id_changed?
      
      old_album_id = photo.album_id_was
      
      # clean the cover photo of the moved photo's album if needed
      old_album = Album.find(old_album_id)
      if old_album.cover_photo_id == photo.id
        old_album.cover_photo_id = nil
        Album.clear_album_cover_photo_cache(old_album_id) if old_album.save
      end
      
      # clean the photos cache of the moved photo's album
      Album.clear_album_photos_cache(old_album_id)
        
    end
  }
  
  
  
  CKP_photo = :album_photo
  
  
  
  # Fix the mime types. Make sure to require the mime-types gem
  def swfupload_file=(data)
    data.content_type = MIME::Types.type_for(data.original_filename).to_s if data
    self.image = data
  end
  
  
  
  def self.get_photo(photo_id)
    photo = Cache.get("#{CKP_photo}_#{photo_id}".to_sym)
    
    unless photo
      photo = self.find(photo_id)
      
      self.set_photo_cache(photo_id, photo)
    end
    photo
  end
  
  def self.set_photo_cache(photo_id, photo)
    Cache.set("#{CKP_photo}_#{photo_id}".to_sym, photo.clear_association, Cache_TTL)
  end
  
  def self.clear_photo_cache(photo_id)
    Cache.delete("#{CKP_photo}_#{photo_id}".to_sym)
  end
  
  
  def clear_association
    copy = deep_copy(self)
    copy.clear_association_cache
    copy.clear_aggregation_cache
    copy
  end
  
end