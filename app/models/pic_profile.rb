class PicProfile < ActiveRecord::Base
  
  include CareerCommunity::AccountBelongings
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :photo, :class_name => "Photo", :foreign_key => "photo_id"

  # ---

  validates_presence_of :account_id
  
  
  
  after_destroy { |pic_profile|
    Account.clear_account_nick_pic_cache(pic_profile.account_id)
    
    PointProfile.adjust_account_points_by_action(pic_profile.account_id, :create_pic_profile, false)
  }
  
  after_create { |pic_profile|
    PointProfile.adjust_account_points_by_action(pic_profile.account_id, :create_pic_profile, true)
  }
  
end