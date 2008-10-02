class HobbyProfile < ActiveRecord::Base
  
  include CareerCommunity::AccountBelongings

  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"

  # ---

  validates_presence_of :account_id
  
  validates_length_of :intro, :maximum => 1000, :message => "自我介绍 超过长度限制", :allow_nil => true
  validates_length_of :interest, :maximum => 1000, :message => "兴趣 超过长度限制", :allow_nil => true
  validates_length_of :music, :maximum => 1000, :message => "喜欢的音乐 超过长度限制", :allow_nil => true
  validates_length_of :movie, :maximum => 1000, :message => "喜欢的电影 超过长度限制", :allow_nil => true
  validates_length_of :cartoon, :maximum => 1000, :message => "喜欢的动漫 超过长度限制", :allow_nil => true
  validates_length_of :game, :maximum => 1000, :message => "喜欢的游戏 超过长度限制", :allow_nil => true
  validates_length_of :sport, :maximum => 1000, :message => "喜欢的运动 超过长度限制", :allow_nil => true
  validates_length_of :book, :maximum => 1000, :message => "喜欢的书籍 超过长度限制", :allow_nil => true
  validates_length_of :words, :maximum => 1000, :message => "喜欢的言语 超过长度限制", :allow_nil => true
  validates_length_of :food, :maximum => 1000, :message => "喜欢的食物 超过长度限制", :allow_nil => true
  validates_length_of :idol, :maximum => 1000, :message => "喜欢的偶像 超过长度限制", :allow_nil => true
  validates_length_of :car, :maximum => 1000, :message => "喜欢的车 超过长度限制", :allow_nil => true
  validates_length_of :place, :maximum => 1000, :message => "喜欢的地方 超过长度限制", :allow_nil => true
  
  
end
