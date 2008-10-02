class GroupPhoto < ActiveRecord::Base
  
  include CareerCommunity::AccountBelongings
  
  belongs_to :group, :class_name => "Group", :foreign_key => "group_id"
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :photo, :class_name => "Photo", :foreign_key => "photo_id"
  
  
  validates_presence_of :account_id, :group_id, :photo_id
  
end