class ActivityPicture < ActiveRecord::Base
  
  belongs_to :activity, :class_name => "Activity", :foreign_key => "activity_id"
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  
  has_many :comments, :class_name => "ActivityPictureComment", :foreign_key => "activity_picture_id", :dependent => :destroy
  
  
  
  # constants to share within picture's setting
  Image_Content_Type = [
    "image/jpg", "image/jpeg", "image/gif", "image/png", "image/bmp",
    
    # to be compatible with IE ...
    "image/pjpeg", "image/x-png"
  ]
  Image_Content_Type_Text = "JPG, JPEG, GIF, PNG 或 BMP 格式的图片"
  Image_Size_Limit = 3.megabyte
  Image_Size_Limit_Text = "3M"
  
  # paperclip
  has_attached_file :image, :styles => {
    :normal => "600x600>",
    :thumb_160 => "160x160>",
    :thumb_80 => "80x80>"
  },
    :url => "/activity/pictures/image/:id/:style",
    :path => ":rails_root/files/activity_picture_images/:created_year/:created_month/:created_mday/:id/:style_:id.:extension",
    :storage => :filesystem,
    :whiny_thumbnails => false # to avoid displaying internal errors

  validates_attachment_presence :image, :message => "请选择 图片文件"
  validates_attachment_content_type :image,
    :content_type => Image_Content_Type, :message => "只能上传 #{Image_Content_Type_Text}"
  validates_attachment_size :image,
    :less_than => Image_Size_Limit, :message => "每个图片文件大小不能超过 #{Image_Size_Limit_Text}"
  # to avoid displaying internal errors
  # validates_attachment_thumbnails :image
  
  
  validates_presence_of :account_id, :activity_id
  
  validates_length_of :title, :maximum => 1000, :message => "照片描述 超过长度限制", :allow_nil => true
  
  
  
  CKP_count = :activity_picture_count
  Count_Cache_Group_Field = :activity_id
  include CareerCommunity::CountCacheable
  
  
  
  # Fix the mime types. Make sure to require the mime-types gem
  def swfupload_file=(data)
    data.content_type = MIME::Types.type_for(data.original_filename).to_s if data
    self.image = data
  end
  
end