class GroupPicture < ActiveRecord::Base
  
  include CareerCommunity::Util
  
  belongs_to :group, :class_name => "Group", :foreign_key => "group_id"
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  
  has_many :comments, :class_name => "GroupPictureComment", :foreign_key => "group_picture_id", :dependent => :destroy
  
  
  
  # paperclip
  has_attached_file :image, :styles => {
    :normal => "600x600>",
    :thumb_160 => "160x160>",
    :thumb_80 => "80x80>"
  },
    :url => "/group/pictures/image/:id/:style",
    :path => ":rails_root/files/group_picture_images/:created_year/:created_month/:created_mday/:id/:style_:id.:extension",
    :storage => :filesystem,
    :whiny_thumbnails => false # to avoid displaying internal errors

  validates_attachment_presence :image, :message => "请选择 图片文件"
  validates_attachment_content_type :image,
    :content_type => ActivityPicture::Image_Content_Type, :message => "只能上传 #{ActivityPicture::Image_Content_Type_Text}"
  validates_attachment_size :image,
    :less_than => ActivityPicture::Image_Size_Limit, :message => "每个图片文件大小不能超过 #{ActivityPicture::Image_Size_Limit_Text}"
  # to avoid displaying internal errors
  # validates_attachment_thumbnails :image
  
  
  validates_presence_of :account_id, :group_id
  
  validates_length_of :title, :maximum => 1000, :message => "照片描述 超过长度限制", :allow_nil => true
  
  
  
  after_destroy { |picture|
    self.clear_picture_cache(picture.id)
    
    self.clear_pictures_id_cache(picture.group_id)
  }
  
  after_save { |picture|
    self.clear_picture_cache(picture.id)
    
    self.clear_pictures_id_cache(picture.group_id)
  }
  
  
  
  named_scope :good, :conditions => { :good => true }
  named_scope :top, :conditions => { :top => true }
  
  
  CKP_group_picture = :group_picture
  
  CKP_group_pictures_id = :group_pictures_id
  
  
  
  CKP_count = :group_picture_count
  Count_Cache_Group_Field = :group_id
  include CareerCommunity::CountCacheable
  
  
  
  # Fix the mime types. Make sure to require the mime-types gem
  def swfupload_file=(data)
    data.content_type = MIME::Types.type_for(data.original_filename).to_s if data
    self.image = data
  end
  
  
  
  def self.get_picture(picture_id)
    picture = Cache.get("#{CKP_group_picture}_#{picture_id}".to_sym)
    
    unless picture
      picture = self.find(picture_id)
      
      self.set_picture_cache(picture_id, picture)
    end
    picture
  end
  
  def self.set_picture_cache(picture_id, picture)
    Cache.set("#{CKP_group_picture}_#{picture_id}".to_sym, picture.clear_association, Cache_TTL)
  end
  
  def self.clear_picture_cache(picture_id)
    Cache.delete("#{CKP_group_picture}_#{picture_id}".to_sym)
  end
  
  
  def self.get_pictures_id(group_id)
    pictures_id = Cache.get("#{CKP_group_pictures_id}_#{group_id}".to_sym)
    
    unless pictures_id
      pictures_id = self.find(
        :all,
        :select => "id",
        :conditions => ["group_id = ?", group_id],
        :order => "responded_at DESC"
      ).collect { |p| p.id }
      
      Cache.set("#{CKP_group_pictures_id}_#{group_id}".to_sym, pictures_id, Cache_TTL)
    end
    pictures_id
  end
  
  def self.clear_pictures_id_cache(group_id)
    Cache.delete("#{CKP_group_pictures_id}_#{group_id}".to_sym)
  end
  
  
  def clear_association
    copy = deep_copy(self)
    copy.clear_association_cache
    copy.clear_aggregation_cache
    copy
  end
  
end