class ActivityOnlinePostGood < ActiveRecord::Migration
  def self.up

    # to support online activity
    add_column :activities, :online, :boolean, :default => false
    
    # to support good post setting
    add_column :group_posts, :good, :boolean, :default => false
    add_column :activity_posts, :good, :boolean, :default => false
    
  end

  def self.down
    remove_column(:activity_posts, :good)
    remove_column(:group_posts, :good)
    remove_column(:activities, :online)
  end
end
