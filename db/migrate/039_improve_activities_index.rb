class ImproveActivitiesIndex < ActiveRecord::Migration
  def self.up
    
    remove_index :activities, :online
    
    remove_index :activities, :created_at
    remove_index :activities, :creator_id
    remove_index :activities, :master_id
    remove_index :activities, :begin_at
    remove_index :activities, :end_at
    remove_index :activities, :application_deadline
    remove_index :activities, :cost
    remove_index :activities, :member_limit
    remove_index :activities, :in_group
    
    add_index :activities, [:cancelled, :created_at]
    add_index :activities, [:cancelled, :begin_at]
    add_index :activities, [:cancelled, :creator_id, :created_at]
    add_index :activities, [:cancelled, :in_group, :begin_at]
    
    
    remove_index :activity_members, :created_at
    remove_index :activity_members, :updated_at
    remove_index :activity_members, :join_at
    remove_index :activity_members, :activity_id
    remove_index :activity_members, :account_id
    remove_index :activity_members, :accepted
    remove_index :activity_members, :approved
    remove_index :activity_members, :absent
    remove_index :activity_members, [:activity_id, :account_id]
    remove_index :activity_members, :admin
    
    add_index :activity_members, [:account_id, :accepted, :approved, :join_at], 
              :name => :index_activity_members_on_account_accepted_approved_join
    add_index :activity_members, [:activity_id, :accepted, :approved, :join_at], 
              :name => :index_activity_members_on_activity_accepted_approved_join
    add_index :activity_members, [:activity_id, :accepted, :approved, :admin, :join_at], 
              :name => :index_activity_members_on_activity_accepted_approved_admin_join
    add_index :activity_members, [:activity_id, :account_id, :accepted, :approved, :admin], 
              :name => :index_activity_members_on_act_acc_accepted_approved_admin
    add_index :activity_members, [:activity_id, :accepted, :approved, :absent, :join_at], 
              :name => :index_activity_members_on_act_acc_approved_absent_join
              
              
    remove_index :activity_interests, :created_at
    remove_index :activity_interests, :activity_id
    remove_index :activity_interests, :account_id
    remove_index :activity_interests, [:activity_id, :account_id]
    
    add_index :activity_interests, [:account_id, :created_at]
    add_index :activity_interests, [:activity_id, :created_at]
    add_index :activity_interests, [:activity_id, :account_id]
    
    
    # remove_index :activity_images, :activity_id
    remove_index :activity_images, :photo_id
    
    
    remove_index :activity_posts, :created_at
    remove_index :activity_posts, :activity_id
    remove_index :activity_posts, :account_id
    remove_index :activity_posts, :top
    
  end

  def self.down
    
    add_index :activity_posts, :created_at
    add_index :activity_posts, :activity_id
    add_index :activity_posts, :account_id
    add_index :activity_posts, :top
    
    
    # add_index :activity_images, :activity_id
    add_index :activity_images, :photo_id
    
    
    remove_index :activity_interests, [:account_id, :created_at]
    remove_index :activity_interests, [:activity_id, :created_at]
    remove_index :activity_interests, [:activity_id, :account_id]
    
    add_index :activity_interests, :created_at
    add_index :activity_interests, :activity_id
    add_index :activity_interests, :account_id
    add_index :activity_interests, [:activity_id, :account_id]
    
    
    remove_index :activity_members, :name => :index_activity_members_on_act_acc_approved_absent_join
    remove_index :activity_members, :name => :index_activity_members_on_act_acc_accepted_approved_admin
    remove_index :activity_members, :name => :index_activity_members_on_activity_accepted_approved_admin_join
    remove_index :activity_members, :name => :index_activity_members_on_activity_accepted_approved_join
    remove_index :activity_members, :name => :index_activity_members_on_account_accepted_approved_join
              
    add_index :activity_members, :created_at
    add_index :activity_members, :updated_at
    add_index :activity_members, :join_at
    add_index :activity_members, :activity_id
    add_index :activity_members, :account_id
    add_index :activity_members, :accepted
    add_index :activity_members, :approved
    add_index :activity_members, :absent
    add_index :activity_members, [:activity_id, :account_id]
    add_index :activity_members, :admin
    
    
    remove_index :activities, [:cancelled, :in_group, :begin_at]
    remove_index :activities, [:cancelled, :creator_id, :created_at]
    remove_index :activities, [:cancelled, :begin_at]
    remove_index :activities, [:cancelled, :created_at]
    
    add_index :activities, :created_at
    add_index :activities, :creator_id
    add_index :activities, :master_id
    add_index :activities, :begin_at
    add_index :activities, :end_at
    add_index :activities, :application_deadline
    add_index :activities, :cost
    add_index :activities, :member_limit
    add_index :activities, :in_group
    
    add_index :activities, :online
    
  end
end

