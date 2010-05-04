module Intranet
  class SalesOpportunityAttachment < ActiveRecord::Base
    
    belongs_to :opportunity, :class_name => "SalesOpportunity", :foreign_key => "opportunity_id"
  
  
    # paperclip
    has_attached_file :attachment,
      :url => "",
      :path => ":rails_root/files/sales_opportunity_attachments/:created_year/:created_month/:created_mday/:id/:basename.:extension",
      :default_url => "",
      :storage => :filesystem,
      :whiny_thumbnails => false # to avoid displaying internal errors

    validates_attachment_presence :attachment, :message => "请选择 附件"

    # validates_attachment_content_type :attachment, :content_type => GroupPostAttachment::Attachment_Content_Type, :message => "上传的附件不在允许的文件类型范围内"

    validates_attachment_size :attachment, :less_than => GroupPostAttachment::Attachment_Size_Limit, :message => "附件的文件大小不能超过 #{GroupPostAttachment::Attachment_Size_Limit_Text}"
    # to avoid displaying internal errors
    # validates_attachment_thumbnails :attachment


    validates_presence_of :opportunity_id

    validates_length_of :desc, :maximum => 100, :message => "附件描述 超过长度限制", :allow_nil => true
    
    
  end
end
