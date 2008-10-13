class Group < ActiveRecord::Base
  
  define_index do
    # fields
    indexes :name, :desc, :setting
    indexes master.nick, :as => :master_nick

    # attributes
    has :created_at, :updated_at
    
    set_property :delta => true
    
    # set_property :field_weights => {:field => number}
  end
  
  has_many :members, :class_name => "GroupMember", :foreign_key => "group_id", :dependent => :destroy
  
  belongs_to :creator, :class_name => "Account", :foreign_key => "creator_id"
  belongs_to :master, :class_name => "Account", :foreign_key => "master_id"
  
  has_one :image, :class_name => "GroupImage", :foreign_key => "group_id", :dependent => :destroy
  
  has_many :group_photos, :class_name => "GroupPhoto", :foreign_key => "group_id", :dependent => :destroy
  
  
  validates_presence_of :creator_id, :master_id
  
  validates_presence_of :name, :message => "请输入 圈子名称"
  
  validates_length_of :name, :maximum => 20, :message => "圈子名称 超过长度限制", :allow_nil => false
  validates_length_of :desc, :maximum => 1000, :message => "圈子描述 超过长度限制", :allow_nil => true
  
  
  
  after_destroy { |group|
    self.decrease_created_count_cache(group.creator_id)
  }
  
  after_create { |group|
    self.increase_created_count_cache(group.creator_id)
  }
  
  
  CKP_created_count = :group_created_count
  CKP_group_with_img = :group_with_img
  
  
  
  # all enabled custom groups should be registered here
  # a custom group optionally includes the following :
  #   a controller in /app/controllers/custom_groups directory
  #   database tables
  #   some views(HTML) under /app/views/custom_groups directory by controllers
  #   the static index page under /public directory
  Custom_Groups = {
    "feedback" => "feedback"
  }
  
  
  
  def get_image_url
    pic_url = self.image && self.image.pic_url
    
    unless Pathname.new("#{RAILS_ROOT}/public#{pic_url}").exist?
      pic_url = nil
      photo_id = self.self.image.photo_id
      if photo_id
        photo = Photo.find(photo_id)
        pic_url = photo.image.url(:thumb_48)
        self.self.image.pic_url = pic_url
        self.self.image.save
      else
        self.self.image.destroy
      end
    end
    pic_url
  end
  
  require_dependency "group_member"
  require_dependency "group_post"
  def self.get_group_with_image(group_id)
    g_i = Cache.get("#{CKP_group_with_img}_#{group_id}".to_sym)
    
    # check to avoid that the deleted photo image files are still cached
    # g_i = nil if g_i && g_i[1] && (!Pathname.new("#{RAILS_ROOT}/public#{g_i[1]}").exist?)
    
    unless g_i
      group = self.find(group_id)
      group_image_url = group.get_image_url
      group.clear_association
      g_i = [group, group_image_url]
      
      Cache.set("#{CKP_group_with_img}_#{group_id}".to_sym, g_i, Cache_TTL)
    end
    g_i
  end
  
  def self.update_group_with_image_cache(group_id, updates = {})
    g_i = Cache.get("#{CKP_group_with_img}_#{group_id}".to_sym)
    if g_i
      if updates.key?(:group)
        group = updates[:group]
        group.clear_association
        g_i[0] = group
      end
      g_i[1] = updates[:group_img] if updates.key?(:group_img)
      Cache.set("#{CKP_group_with_img}_#{group_id}".to_sym, g_i, Cache_TTL)
    end
  end
  
  def self.set_group_with_image_cache(group_id, group, group_img_url)
    group.clear_association
    g_i = [group, group_img_url]
    Cache.set("#{CKP_group_with_img}_#{group_id}".to_sym, g_i, Cache_TTL)
  end
  
  def self.clear_group_with_image_cache(group_id)
    Cache.delete("#{CKP_group_with_img}_#{group_id}".to_sym)
  end
  
  def get_setting
    ((self.setting && self.setting != "") && eval(self.setting)) || {}
  end
  
  def fill_setting(hash_setting)
    self.setting = hash_setting.inspect
  end
  
  def update_setting(hash_setting)
    new_setting = self.get_setting.merge(hash_setting)
    self.fill_setting(new_setting)
  end
  
  def self.get_created_count(account_id)
    c_c = Cache.get("#{CKP_created_count}_#{account_id}".to_sym)
    unless c_c
      c_c = self.count(:conditions => ["creator_id = ?", account_id])
      
      Cache.set("#{CKP_created_count}_#{account_id}".to_sym, c_c, Cache_TTL)
    end
    c_c
  end
  
  def self.clear_created_count_cache(account_id)
    Cache.delete("#{CKP_created_count}_#{account_id}".to_sym)
  end
  
  def self.increase_created_count_cache(account_id, count = 1)
    c_c = Cache.get("#{CKP_created_count}_#{account_id}".to_sym)
    if c_c
      updated_c_c = c_c.to_i + count
      
      Cache.set("#{CKP_created_count}_#{account_id}".to_sym, updated_c_c, Cache_TTL)
    end
  end
  
  def self.decrease_created_count_cache(account_id, count = 1)
    c_c = Cache.get("#{CKP_created_count}_#{account_id}".to_sym)
    if c_c
      updated_c_c = c_c.to_i - count
      
      Cache.set("#{CKP_created_count}_#{account_id}".to_sym, updated_c_c, Cache_TTL)
    end
  end
  
  def clear_association
    self.clear_association_cache
  end
  
  
end

