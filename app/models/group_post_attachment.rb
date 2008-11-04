class GroupPostAttachment < ActiveRecord::Base
  
  belongs_to :group_post, :class_name => "GroupPost", :foreign_key => "group_post_id"
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  
  # constants to share within post attachment's setting
  Attachment_Url = "/system/files/:class/:attachment/:id/:basename.:extension"
  Attachment_Path = ":rails_root/public/system/files/:class/:attachment/:id/:basename.:extension"
  Attachment_Content_Type = [
    "text/plain", "text/enriched",
    
    "application/pdf", "application/x-pdf",
    
    "application/msword", "application/ms-word",
    "application/mspowerpoint", "application/ms-powerpoint", "application/vnd.ms-powerpoint",
    #"application/msexcel", "application/ms-excel", "application/vnd.ms-excel", "application/x-msexcel",
    
    "application/zip"
  ]
  Attachment_Size_Limit = 5.megabyte
  Attachment_Size_Limit_Text = "5M"
  
  # paperclip
  has_attached_file :attachment,
    :url => Attachment_Url,
    :path => Attachment_Path,
    :storage => :filesystem,
    :whiny_thumbnails => false # to avoid displaying internal errors

  validates_attachment_presence :attachment, :message => "请选择 附件"
  
  validates_attachment_content_type :attachment, :content_type => Attachment_Content_Type, :message => "上传的附件不在允许的文件类型范围内"
  
  validates_attachment_size :attachment, :less_than => Attachment_Size_Limit, :message => "附件的文件大小不能超过 #{Attachment_Size_Limit_Text}"
  # to avoid displaying internal errors
  # validates_attachment_thumbnails :attachment
  
  
  validates_presence_of :account_id, :group_post_id
  
  validates_length_of :desc, :maximum => 1000, :message => "附件描述 超过长度限制", :allow_nil => true
  
  
  
  
end


