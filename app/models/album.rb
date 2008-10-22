class Album < ActiveRecord::Base
  
  has_many :photos, :class_name => "Photo", :foreign_key => "album_id", :dependent => :destroy
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :cover_photo, :class_name => "Photo", :foreign_key => "cover_photo_id"
  
  
  validates_presence_of :account_id
  
  validates_presence_of :name, :message => "请输入 相册名称"
  
  validates_length_of :description, :maximum => 1000, :message => "相册描述 超过长度限制", :allow_nil => true
  
  CKP_photos = :album_photos
  CKP_cover_photo = :album_cover_photo
  CKP_account_albums = :account_albums
  
  after_destroy { |album|
    self.clear_account_albums_cache(album.account_id)
  }
  
  after_save { |album|
    self.clear_account_albums_cache(album.account_id)
  }
  
  
  
  def self.get_all_by_account_id(account_id)
    self.find(
      :all,
      :conditions => ["account_id = ?", account_id],
      :include => [:cover_photo]
    )
  end
  
  def self.get_all_names_by_account_id(account_id)
    aa = Cache.get("#{CKP_account_albums}_#{account_id}".to_sym)
    unless aa
      albums = self.find(
        :all,
        :conditions => ["account_id = ?", account_id],
        :select => "id, name"
      )
      aa = albums.collect {|album| [album.id, album.name] }
      
      Cache.set("#{CKP_account_albums}_#{account_id}".to_sym, aa, Cache_TTL)
    end
    aa
  end
  
  def self.clear_account_albums_cache(account_id)
    Cache.delete("#{CKP_account_albums}_#{account_id}".to_sym)
  end
  
  def get_cover_photo_img_src(style, photo = nil)
    self.cover_photo_id ? (photo || self.get_cover_photo).image.url(style) : style.to_s == "thumb_80" ? "/images/album_thumb.png" : "/images/album.png"
  end
  
  # if it's sure that the cover photo object has been loaded ...
  def get_cover_photo_img_src_and_set_cache(style)
    self.cover_photo_id ? self.get_cover_photo_and_set_cache.image.url(style) : style.to_s == "thumb_80" ? "/images/album_thumb.png" : "/images/album.png"
  end
  
  
  # cache related methods

  # to avoid the "Undefined Class/Module Photo" problem when loading the cached photos from memcached
  require_dependency "photo"
  def get_photos
    p = Cache.get("#{CKP_photos}_#{self.id}".to_sym)
    unless p
      p = self.photos
      
      Cache.set("#{CKP_photos}_#{self.id}".to_sym, p, Cache_TTL)
    end
    p
  end
  
  def self.clear_album_photos_cache(album_id)
    Cache.delete("#{CKP_photos}_#{album_id}".to_sym)
  end
  
  def get_cover_photo
    cp = Cache.get("#{CKP_cover_photo}_#{self.id}".to_sym)
    unless cp
      cp = self.cover_photo
      
      set_cover_photo_cache(cp)
    end
    cp
  end
  
  # if it's sure that the cover photo object has been loaded ...
  def get_cover_photo_and_set_cache
    cp = self.cover_photo
    set_cover_photo_cache(cp)
    cp
  end
  
  def set_cover_photo_cache(cover_photo)
    Cache.set("#{CKP_cover_photo}_#{self.id}".to_sym, cover_photo, Cache_TTL)
  end
  
  def self.clear_album_cover_photo_cache(album_id)
    Cache.delete("#{CKP_cover_photo}_#{album_id}".to_sym)
  end
  
  private
  
end