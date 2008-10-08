class Activity < ActiveRecord::Base
  
  define_index do
    # fields
    indexes :title, :place, :setting
    indexes master.nick, :as => :master_nick

    # attributes
    has :created_at, :updated_at, :cost, :member_limit
    
    set_property :delta => true
    
    # set_property :field_weights => {:field => number}
  end
  
  has_many :members, :class_name => "ActivityMember", :foreign_key => "activity_id", :dependent => :destroy
  
  belongs_to :creator, :class_name => "Account", :foreign_key => "creator_id"
  belongs_to :master, :class_name => "Account", :foreign_key => "master_id"
  
  has_one :image, :class_name => "ActivityImage", :foreign_key => "activity_id", :dependent => :destroy
  
  has_many :photos, :class_name => "ActivityPhoto", :foreign_key => "activity_id", :dependent => :destroy
  
  
  validates_presence_of :creator_id, :master_id
  
  validates_presence_of :title, :message => "请输入 活动的标题"
  
  validates_presence_of :place, :message => "请输入 活动的地点"
  
  validates_presence_of :begin_at, :message => "请输入正确的 活动开始时间"
  validates_presence_of :end_at, :message => "请输入正确的 活动结束时间"
  
  validates_length_of :title, :maximum => 200, :message => "活动的标题 超过长度限制", :allow_nil => false
  # validates_length_of :desc, :maximum => 1000, :message => "活动的描述 超过长度限制", :allow_nil => true
  validates_length_of :place, :maximum => 250, :message => "活动的地点 超过长度限制", :allow_nil => false
  
  validates_numericality_of :member_limit, :message => "活动的人数限制 必须是0或者正整数", :allow_nil => true, :greater_than_or_equal_to => 0, :only_integer => true
  validates_numericality_of :cost, :message => "活动的人均费用 必须是大于等于0的数字", :allow_nil => true, :greater_than_or_equal_to => 0
  
  def validate
    now = DateTime.now
    
    if application_deadline
      errors.add :application_deadline, "报名截止时间已成为过去" if application_deadline_changed? && (application_deadline < now)
      errors.add :begin_at, "报名截止时间比活动开始时间晚" if begin_at && begin_at < application_deadline
    else
      errors.add :begin_at, "活动开始时间已成为过去" if begin_at_changed? && (begin_at && begin_at < now)
    end
    errors.add :begin_at, "活动结束时间比活动开始时间早" if begin_at && end_at && begin_at > end_at
  end
  
  
  
  
  CKP_activity_with_img = :activity_with_img
  
  
  
  def get_image_url
    self.image && self.image.pic_url
  end
  
  require_dependency "activity_member"
  require_dependency "activity_interest"
  def self.get_activity_with_image(activity_id)
    a_i = Cache.get("#{CKP_activity_with_img}_#{activity_id}".to_sym)
    unless a_i
      activity = self.find(activity_id)
      activity_image = activity.get_image_url
      activity.clear_association
      a_i = [activity, activity_image]
      
      Cache.set("#{CKP_activity_with_img}_#{activity_id}".to_sym, a_i, Cache_TTL)
    end
    a_i
  end
  
  def self.update_activity_with_image_cache(activity_id, updates = {})
    a_i = Cache.get("#{CKP_activity_with_img}_#{activity_id}".to_sym)
    if a_i
      if updates.key?(:activity)
        activity = updates[:activity]
        activity.clear_association
        a_i[0] = activity
      end
      a_i[1] = updates[:activity_img] if updates.key?(:activity_img)
      Cache.set("#{CKP_activity_with_img}_#{activity_id}".to_sym, a_i, Cache_TTL)
    end
  end
  
  def self.set_activity_with_image_cache(activity_id, activity, activity_img_url)
    activity.clear_association
    a_i = [activity, activity_img_url]
    Cache.set("#{CKP_activity_with_img}_#{activity_id}".to_sym, a_i, Cache_TTL)
  end
  
  def self.clear_activity_with_image_cache(activity_id)
    Cache.delete("#{CKP_activity_with_img}_#{activity_id}".to_sym)
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
  
  def self.paginate_list_by_begin_at(first, last, page, per_page)
    Activity.paginate(
      :page => page,
      :per_page => per_page,
      :conditions => ["begin_at > ? and begin_at < ?", first, last],
      :include => [:image],
      :order => "begin_at ASC"
    )
  end
  
  def get_title(show_status = false)
    the_title = title
    the_title = "(#{self.get_status[1]}) " + the_title if show_status
    the_title
  end
  
  def get_status
    application_deadline_at = application_deadline || begin_at
    now = DateTime.now
    
    if now <= application_deadline_at
      Status::Registering
    elsif now <= begin_at
      Status::Registered
    elsif now <= end_at
      Status::Ongoing
    else
      Status::Finished
    end
  end
  
  def clear_association
    self.clear_association_cache
  end
  
  
  module Status
    Registering = [1, "报名中"]
    Registered = [2, "报名结束"]
    Ongoing = [3, "进行中"]
    Finished = [4, "已结束"]
  end
  
  
end