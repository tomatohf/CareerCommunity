class ActivityImage < ActiveRecord::Base
  
  include CareerCommunity::Util
  
  belongs_to :activity, :class_name => "Activity", :foreign_key => "activity_id"
  belongs_to :photo, :class_name => "Photo", :foreign_key => "photo_id"

  # ---

  validates_presence_of :activity_id
  
  
  
  after_save { |activity_image|
    Activity.clear_activities_all_cache
    
    
    Activity.clear_spaces_show_activity_cache(activity_image.activity_id)
  }
  
  after_destroy { |activity_image|
    Activity.clear_activities_all_cache
    Activity.clear_spaces_show_activity_cache(activity_image.activity_id)
  }
  
  
  
  def self.get_by_activity(activity_id)
    self.find(:first, :conditions => ["activity_id = ?", activity_id])
  end
  
end