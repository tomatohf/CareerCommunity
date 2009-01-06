class GroupImage < ActiveRecord::Base
  
  belongs_to :group, :class_name => "Group", :foreign_key => "group_id"
  belongs_to :photo, :class_name => "Photo", :foreign_key => "photo_id"

  # ---

  validates_presence_of :group_id
  
  
  
  after_destroy { |image|
    Group.clear_group_with_image_cache(image.group_id)
  }
  
  
  
  def self.get_by_group(group_id)
    self.find(:first, :conditions => ["group_id = ?", group_id])
  end
  
end