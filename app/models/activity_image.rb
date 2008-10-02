class ActivityImage < ActiveRecord::Base
  
  belongs_to :activity, :class_name => "Activity", :foreign_key => "activity_id"
  belongs_to :photo, :class_name => "Photo", :foreign_key => "photo_id"

  # ---

  validates_presence_of :activity_id
  
  
  
  def self.get_by_activity(activity_id)
    self.find(:first, :conditions => ["activity_id = ?", activity_id])
  end
  
end