class BasicProfile < ActiveRecord::Base
  
  include CareerCommunity::AccountBelongings

  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  
  belongs_to :province, :class_name => "Province", :foreign_key => "province_id"
  belongs_to :city, :class_name => "City", :foreign_key => "city_id"
  belongs_to :hometown_province, :class_name => "Province", :foreign_key => "hometown_province_id"
  belongs_to :hometown_city, :class_name => "City", :foreign_key => "hometown_city_id"
  
  validates_length_of :real_name, :maximum => 50, :message => "真实姓名 超过长度限制", :allow_nil => true
  validates_length_of :qmd, :maximum => 300, :message => "签名档 超过长度限制", :allow_nil => true
  
  
end
