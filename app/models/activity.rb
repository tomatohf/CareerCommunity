class Activity < ActiveRecord::Base
  
  acts_as_trashable
  
  
  define_index do
    # fields
    indexes :title, :place, :setting
    indexes master.nick, :as => :master_nick

    # attributes
    has :created_at, :updated_at, :cost, :member_limit
    
    set_property :delta => true
    
    # set_property :field_weights => {:field => number}
  end
  
  include CareerCommunity::Util
  
  has_many :members, :class_name => "ActivityMember", :foreign_key => "activity_id", :dependent => :destroy
  has_many :interests, :class_name => "ActivityInterest", :foreign_key => "activity_id", :dependent => :destroy
  
  belongs_to :creator, :class_name => "Account", :foreign_key => "creator_id"
  belongs_to :master, :class_name => "Account", :foreign_key => "master_id"
  
  has_one :image, :class_name => "ActivityImage", :foreign_key => "activity_id", :dependent => :destroy
  
  has_many :photos, :class_name => "ActivityPhoto", :foreign_key => "activity_id", :dependent => :destroy
  has_many :posts, :class_name => "ActivityPost", :foreign_key => "activity_id", :dependent => :destroy
  
  
  validates_presence_of :creator_id, :master_id
  
  validates_presence_of :title, :message => "请输入 活动的标题"
  
  # validates_presence_of :place, :message => "请输入 活动的地点"
  
  validates_presence_of :begin_at, :message => "请输入正确的 活动开始时间"
  validates_presence_of :end_at, :message => "请输入正确的 活动结束时间"
  
  validates_length_of :title, :maximum => 200, :message => "活动的标题 超过长度限制", :allow_nil => false
  # validates_length_of :desc, :maximum => 1000, :message => "活动的描述 超过长度限制", :allow_nil => true
  validates_length_of :place, :maximum => 250, :message => "活动的地点 超过长度限制", :allow_nil => false
  
  validates_numericality_of :member_limit, :message => "活动的人数限制 必须是0或者正整数", :allow_nil => true, :greater_than_or_equal_to => 0, :only_integer => true
  validates_numericality_of :cost, :message => "活动的人均费用 必须是大于等于0的数字", :allow_nil => true, :greater_than_or_equal_to => 0
  
  def validate
    now = DateTime.now
    
    if get_application_deadline
      # errors.add :application_deadline, "报名截止时间已成为过去" if application_deadline_changed? && (get_application_deadline < now)
      errors.add :begin_at, "报名截止时间比活动开始时间晚" if begin_at && begin_at < get_application_deadline
    else
      # errors.add :begin_at, "活动开始时间已成为过去" if begin_at_changed? && (begin_at && begin_at < now)
    end
    errors.add :begin_at, "活动结束时间比活动开始时间早" if begin_at && end_at && begin_at > end_at
    
    
    errors.add :place, "请输入 活动的地点" unless online || (place && place != "")
  end
  
  
  
  
  named_scope :uncancelled, :conditions => { :cancelled => false }
  
  
  CKP_activity_with_img = :activity_with_img
  
  CKP_activity_invitations = :activity_invitations
  CKP_activity_contact_invitations = :activity_contact_invitations
  
  CKP_activity_place_point = :activity_place_point
  
  CKP_activities_all_list = :activities_all_list
  
  FCKP_activities_show_created_activity = :fc_activities_show_created_activity
  
  FCKP_index_activity = :fc_index_activity
  
  after_save { |activity|
    self.clear_activities_all_cache
    self.clear_spaces_show_activity_cache(activity.id)
    self.clear_activities_show_created_activity_cache(activity.creator_id)
    
    self.clear_index_activity_cache if IndexController::Index_Activity_Account_Id_Scope.include?(activity.creator_id)
    
    self.clear_activity_place_point_cache(activity.id) if activity.place_changed?
    
    # clear changed attributes, before we cache it ...
    activity.clean_myself
    self.update_activity_with_image_cache(activity.id, :activity => activity)
  }
  
  after_destroy { |activity|
    self.clear_activity_with_image_cache(activity.id)
    
    
    self.clear_activities_all_cache
    self.clear_activities_show_created_activity_cache(activity.creator_id)
    
    self.clear_index_activity_cache if IndexController::Index_Activity_Account_Id_Scope.include?(activity.creator_id)
    
    self.clear_activity_place_point_cache(activity.id)
  }
  
  def self.clear_activities_all_cache
    activity_count = self.uncancelled.count
    page_count = activity_count > 0 ? (activity_count.to_f/ActivitiesController::Activity_List_Size).ceil : 1

    1.upto(page_count) { |i|
      Cache.delete("#{CKP_activities_all_list}_#{i}")
    }
  end
  
  def self.clear_activities_show_created_activity_cache(creator_id)
    Cache.delete(expand_cache_key("#{FCKP_activities_show_created_activity}_#{creator_id}"))
  end
  
  def self.clear_spaces_show_activity_cache(activity_id)
    ActivityMember.agreed.find(
			:all,
			:conditions => ["activity_id = ?", activity_id]
		).each do |am|
		  ActivityMember.clear_spaces_show_activity_member_cache(am.account_id)
		  
      ActivityMember.set_activity_member_cache(am.activity_id, am.account_id, am)
	  end
	  
	  ActivityInterest.find(
			:all,
			:conditions => ["activity_id = ?", activity_id]
		).each do |ai|
		  ActivityInterest.clear_spaces_show_activity_interest_cache(ai.account_id)
		  
		  ActivityInterest.set_activity_interest_cache(ai.activity_id, ai.account_id, ai)
	  end
  end
  
  def self.clear_index_activity_cache
    Cache.delete(expand_cache_key(FCKP_index_activity))
  end
  
  
  
  require_dependency "activity_image"
  def self.get_activities_all_list(page = 1)
    activities = Cache.get("#{CKP_activities_all_list}_#{page}".to_sym)
    
    unless activities
      activities = self.uncancelled.paginate(
		    :page => page,
	      :per_page => ActivitiesController::Activity_List_Size,
	      :include => [:image],
	      :order => "created_at DESC"
	    )
      
      Cache.set("#{CKP_activities_all_list}_#{page}".to_sym, activities)
    end
    activities
  end
  
  def get_image_url
    activity_image = self.image
    activity_image && Photo.get_photo(activity_image.photo_id).image.url(:thumb_48)
  end
  
  require_dependency "activity_member"
  require_dependency "activity_interest"
  require_dependency "activity_post"
  def self.get_activity_with_image(activity_id)
    a_i = Cache.get("#{CKP_activity_with_img}_#{activity_id}".to_sym)
    
    # check to avoid that the deleted photo image files are still cached
    # a_i = nil if a_i && a_i[1] && (!Pathname.new("#{RAILS_ROOT}/public#{a_i[1]}").exist?)
    
    unless a_i
      activity = self.find(activity_id)
      activity_image = activity.get_image_url
      a_i = [activity.clear_association, activity_image]
      
      Cache.set("#{CKP_activity_with_img}_#{activity_id}".to_sym, a_i, Cache_TTL)
    end
    a_i
  end
  
  def self.update_activity_with_image_cache(activity_id, updates = {})
    a_i = Cache.get("#{CKP_activity_with_img}_#{activity_id}".to_sym)
    if a_i
      if updates.key?(:activity)
        activity = updates[:activity]
        a_i[0] = activity.clear_association
      end
      a_i[1] = updates[:activity_img] if updates.key?(:activity_img)
      Cache.set("#{CKP_activity_with_img}_#{activity_id}".to_sym, a_i, Cache_TTL)
    end
  end
  
  def self.set_activity_with_image_cache(activity_id, activity, activity_img_url)
    a_i = [activity.clear_association, activity_img_url]
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
    Activity.uncancelled.paginate(
      :page => page,
      :per_page => per_page,
      :conditions => ["begin_at >= ? and begin_at < ?", first, last],
      :include => [:image],
      :order => "begin_at ASC"
    )
  end
  
  def get_title(show_status = false)
    return "[该活动已取消]" if self.cancelled
    
    the_title = title
    the_title = "(#{self.get_status[1]}) " + the_title if show_status
    the_title
  end
  
  def get_status
    application_deadline_at = get_application_deadline || begin_at
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
  
  def get_application_deadline
    self.online ? nil : application_deadline
  end
  
  
  def self.get_activity_invitations
    Cache.get(CKP_activity_invitations) || []
  end
  
  def self.add_activity_invitation(invitation)
    invitations = get_activity_invitations
    invitations << invitation
    Cache.set(CKP_activity_invitations, invitations)
  end
  
  def self.clear_activity_invitations_cache
    Cache.delete(CKP_activity_invitations)
  end
  
  
  def self.get_activity_contact_invitations
    Cache.get(CKP_activity_contact_invitations) || []
  end
  
  def self.add_activity_contact_invitation(invitation)
    invitations = get_activity_contact_invitations
    invitations << invitation
    Cache.set(CKP_activity_contact_invitations, invitations)
  end
  
  def self.clear_activity_contact_invitations_cache
    Cache.delete(CKP_activity_contact_invitations)
  end
  
  
  def self.get_activity_place_point(activity_id)
    Cache.get("#{CKP_activity_place_point}_#{activity_id}".to_sym)
  end
  
  def self.set_activity_place_point(activity_id, point_x, point_y)
    Cache.set("#{CKP_activity_place_point}_#{activity_id}".to_sym, [point_x, point_y])
  end
  
  def self.clear_activity_place_point_cache(activity_id)
    Cache.delete("#{CKP_activity_place_point}_#{activity_id}".to_sym)
  end
  
  
  def clear_association
    copy = deep_copy(self)
    copy.clear_association_cache
    copy.clear_aggregation_cache
    copy
  end
  
  
  def self.load_associations(activities, includes)
    preload_associations(activities, includes)
  end
  
  
  module Status
    Registering = [1, "报名中"]
    Registered = [2, "报名结束"]
    Ongoing = [3, "进行中"]
    Finished = [4, "已结束"]
  end
  
  
end