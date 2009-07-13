class Account < ActiveRecord::Base
  
  define_index do
    # fields
    
    # indexes :email # exclude email from index
    indexes :nick
    
    # basic profile
    # gender, two p_id and two city_id
    indexes profile_basic.real_name, :as => :basic_real_name
    indexes profile_basic.qmd, :as => :basic_qmd
    indexes profile_basic.province.name, :as => :basic_province_name
    indexes profile_basic.city.name, :as => :basic_city_name
    indexes profile_basic.hometown_province.name, :as => :basic_hometown_province_name
    indexes profile_basic.hometown_city.name, :as => :basic_hometown_city_name
    
    # exclude contact profile, for personal info privacy
    
    # hobby profile
    indexes profile_hobby.intro, :as => :hobby_intro
    indexes profile_hobby.interest, :as => :hobby_interest
    indexes profile_hobby.music, :as => :hobby_music
    indexes profile_hobby.movie, :as => :hobby_movie
    indexes profile_hobby.cartoon, :as => :hobby_cartoon
    indexes profile_hobby.game, :as => :hobby_game
    indexes profile_hobby.sport, :as => :hobby_sport
    indexes profile_hobby.book, :as => :hobby_book
    indexes profile_hobby.words, :as => :hobby_words
    indexes profile_hobby.food, :as => :hobby_food
    indexes profile_hobby.idol, :as => :hobby_idol
    indexes profile_hobby.car, :as => :hobby_car
    indexes profile_hobby.place, :as => :hobby_place
    
    # education profile
    # education_id
    indexes profile_educations.edu_name, :as => :edu_name
    indexes profile_educations.major, :as => :edu_major
    
    # job profile
    # profession_id
    indexes profile_jobs.job_name, :as => :job_name
    indexes profile_jobs.dept, :as => :job_dept
    indexes profile_jobs.position_title, :as => :job_position_title
    indexes profile_jobs.description, :as => :job_description

    # attributes
    has :checked, :active, :enabled, :created_at
    
    set_property :delta => true
    
    # set_property :field_weights => {:field => number}
  end
  
  
  include CareerCommunity::Util
  
  def self.email_regexp
    %r{^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$}i
  end
  
  def self.nick_regexp
    %r{^[^\s]*$}i
  end

  has_and_belongs_to_many :roles, :foreign_key => "account_id"
  
  belongs_to :timezone, :class_name => "Timezone", :foreign_key => "timezone_id"
  
  has_one :setting, :class_name => "AccountSetting", :foreign_key => "account_id", :dependent => :destroy
  
  has_one :profile_basic, :class_name => "BasicProfile", :foreign_key => "account_id", :dependent => :destroy
  has_one :profile_contact, :class_name => "ContactProfile", :foreign_key => "account_id", :dependent => :destroy
  has_one :profile_hobby, :class_name => "HobbyProfile", :foreign_key => "account_id", :dependent => :destroy
  has_many :profile_educations, :class_name => "EducationProfile", :foreign_key => "account_id", :order => "education_id DESC, enter_year DESC", :dependent => :destroy
  has_many :profile_jobs, :class_name => "JobProfile", :foreign_key => "account_id", :order => "enter_year DESC, enter_month DESC", :dependent => :destroy
  has_one :profile_point, :class_name => "PointProfile", :foreign_key => "account_id", :dependent => :destroy
  has_one :profile_pic, :class_name => "PicProfile", :foreign_key => "account_id", :dependent => :destroy

  has_many :albums, :class_name => "Album", :foreign_key => "account_id", :dependent => :destroy
  has_many :blogs, :class_name => "Blog", :foreign_key => "account_id", :dependent => :destroy
  
  has_many :friends, :class_name => "Friend", :foreign_key => "account_id", :dependent => :destroy
  has_many :be_friends, :class_name => "Friend", :foreign_key => "friend_id", :dependent => :destroy
  
  has_many :messages, :class_name => "Message", :foreign_key => "receiver_id", :dependent => :destroy
  has_many :sent_messages, :class_name => "SentMessage", :foreign_key => "sender_id", :dependent => :destroy
  has_many :be_sent_messages, :class_name => "SentMessage", :foreign_key => "receiver_id", :dependent => :destroy
  has_many :sys_messages, :class_name => "SysMessage", :foreign_key => "account_id", :dependent => :destroy
  
  has_many :activity_photos, :class_name => "ActivityPhoto", :foreign_key => "account_id", :dependent => :destroy
  has_many :group_photos, :class_name => "GroupPhoto", :foreign_key => "account_id", :dependent => :destroy
  
  
  attr_protected :checked, :enabled, :active
  
  validates_presence_of :email, :message => "请输入 email 地址"
  validates_presence_of :password, :message => "请输入你想使用的 密码"
                            
  validates_uniqueness_of :email, :case_sensitive => false, :message => "你输入的 email 地址已经注册过了,试试看直接 登录 或者 找回密码 吧"
  
  validates_format_of :email, :with => self.email_regexp, :message => "请输入格式正确的 email 地址"
  validates_format_of :nick, :with => self.nick_regexp, :message => "请输入格式正确的 昵称, 昵称 中不能包含 空格"
  
  validates_length_of :nick, :maximum => 15, :message => "昵称 超过长度限制", :allow_nil => true
  
  # attr_accessor :password_confirmation
  # validates_confirmation_of :password, :message => "密码 与 确认密码 不相同"
  
  
  named_scope :enabled, :conditions => { :enabled => true }
  named_scope :unlimited, :conditions => { :checked => true, :active => true }
  
  
  CKP_nick_pic = :account_nick_pic
  
  after_create { |account|
    # create the default album for new account
    album = Album.new(:account_id => account.id)
    album.name = "默认相册"
    album.description = "乔布圈为新用户自动创建的默认相册"
    album.save
  }
  
  after_destroy { |account|
    
  }
  
  after_save { |account|
    self.update_account_nick_pic_cache(
      account.id,
      :nick => account.get_nick,
      :email => account.email
    )
  }
  
  
  
  def self.find_enabled(id)
    self.enabled.find(id)
  end
  
  def self.get_by_email(email, only_enabled = true)
    (only_enabled ? self.enabled : self).find(:first, :conditions => ["email = ?", email])
  end
  
  def self.authenticate(email, pwd)
    account = self.get_by_email(email)
    account = nil if account && account.password != pwd
    account
  end
  
  def create_new(account_email, account_password, account_nick)
    self.email = account_email
    self.password = account_password
    self.nick = account_nick
    
    self.enabled = true
    self.active = true
    self.checked = false
    
    save
  end
  
  def deliver_register_confirmation
    Postman.deliver_register_confirmation(self)
  end
  
  def deliver_password_remind
    Postman.deliver_password_remind(self)
  end
  
  def delete_register(key)
    valid_to_delete =  (!checked) && (get_key == key)
    self.destroy if valid_to_delete
    
    valid_to_delete
  end
  
  def confirm_register(key)
    update_attribute(:checked, true) if (!checked) && (get_key == key)
    
    checked
  end
  
  # if an account is limited? then this account is readonly, which means it can NOT ADD or UPDATE any entry
  def limited?
    !(checked && active)
  end
  
  def get_nick(truncate = true)
    nickname = self.nick
    nickname = self.email.split("@")[0] if !new_record? && (nickname.nil? || nickname == "")
    
    truncate ? truncate_text(nickname, 18, "...") : nickname
  end
  
  def get_key
    hash_source = self.email.gsub("@", "@" + self.id.to_s + "@")
    Digest::SHA1.hexdigest hash_source
  end
  
  def can_create_group_count
    count = 0
    
    if false
      # TODO - update the "has paid user" check logic
      
      # has paid user can create three groups
      count += 3
    else
      # TODO - check point amount
      
    end
    
    if ApplicationController.helpers.general_admin?(self.id)
      count += 1000
    end
    
    count
  end
  
  def get_profile_pic_url
    pic_profile = self.profile_pic
    pic_profile && Photo.get_photo(pic_profile.photo_id).image.url(:thumb_48)
  end
  
  def self.get_nick_and_pic(account_id)
    n_p = Cache.get("#{CKP_nick_pic}_#{account_id}".to_sym)
    
    # check to avoid that the deleted photo image files are still cached
    # n_p = nil if n_p && n_p[1] && (!Pathname.new("#{RAILS_ROOT}/public#{n_p[1]}").exist?)
    
    unless n_p
      account = Account.find(account_id)
      n_p = [account.get_nick, account.get_profile_pic_url, account.email]
      
      Cache.set("#{CKP_nick_pic}_#{account_id}".to_sym, n_p, Cache_TTL)
    end
    n_p
  end
  
  def self.update_account_nick_pic_cache(account_id, updates = {})
    n_p = Cache.get("#{CKP_nick_pic}_#{account_id}".to_sym)
    if n_p
      n_p[0] = updates[:nick] if updates.key?(:nick)
      n_p[1] = updates[:pic] if updates.key?(:pic)
      n_p[2] = updates[:email] if updates.key?(:email)
      Cache.set("#{CKP_nick_pic}_#{account_id}".to_sym, n_p, Cache_TTL)
    end
  end
  
  def self.set_account_nick_pic_cache(account_id, account_nick, account_pic_url, account_email)
    n_p = [account_nick, account_pic_url, account_email]
    Cache.set("#{CKP_nick_pic}_#{account_id}".to_sym, n_p, Cache_TTL)
  end
  
  def self.clear_account_nick_pic_cache(account_id)
    Cache.delete("#{CKP_nick_pic}_#{account_id}".to_sym)
  end
  
end
