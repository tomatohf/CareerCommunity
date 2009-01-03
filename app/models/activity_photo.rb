class ActivityPhoto < ActiveRecord::Base
  
  include CareerCommunity::AccountBelongings
  
  belongs_to :activity, :class_name => "Activity", :foreign_key => "activity_id"
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :photo, :class_name => "Photo", :foreign_key => "photo_id"
  
  
  validates_presence_of :account_id, :activity_id, :photo_id
  
  
  
  CKP_count = :activity_photo_count
  Count_Cache_Group_Field = :activity_id
  include CareerCommunity::CountCacheable
  
end