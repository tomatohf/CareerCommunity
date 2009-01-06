class RemovePicUrl < ActiveRecord::Migration
  def self.up

    remove_column(:pic_profiles, :pic_url)
    remove_column(:group_images, :pic_url)
    remove_column(:activity_images, :pic_url)
    remove_column(:vote_images, :pic_url)
    
  end

  def self.down
  end
end
