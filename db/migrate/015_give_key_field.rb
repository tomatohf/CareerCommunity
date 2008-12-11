class GiveKeyField < ActiveRecord::Migration
  def self.up

    add_column :groups, :custom_key, :string
    
    Group.find(:all).each do |group|
      Group.clear_group_with_image_cache(group.id)
      
      ck = group.get_setting[:custom_key]
      group.custom_key = group.get_setting[:custom_key] if ck && ck != ""
      group.save!
    end
    
  end

  def self.down
  end
end
