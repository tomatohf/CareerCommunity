class RemoveIndexOnDelta < ActiveRecord::Migration
  def self.up
    
    # for 001_create_accounts.rb
    remove_index :accounts, :delta
    remove_index :timezones, :delta
    remove_index :roles, :delta
    remove_index :accounts_roles, :delta
    remove_index :autologins, :delta
    remove_index :account_settings, :delta
    
    # for 002_create_profiles.rb
    remove_index :provinces, :delta
    remove_index :cities, :delta
    remove_index :basic_profiles, :delta
    remove_index :contact_profiles, :delta
    remove_index :hobby_profiles, :delta
    remove_index :education_profiles, :delta
    remove_index :job_profiles, :delta
    remove_index :point_profiles, :delta
    remove_index :pic_profiles, :delta
    
    # for 003_create_photos.rb
    remove_index :albums, :delta
    remove_index :photos, :delta
    remove_index :photo_comments, :delta
    
    # for 004_create_blogs.rb
    remove_index :blogs, :delta
    remove_index :blog_comments, :delta
    
    # for 005_create_friends.rb
    remove_index :space_comments, :delta
    remove_index :friends, :delta
    remove_index :account_actions, :delta
    remove_index :messages, :delta
    remove_index :sent_messages, :delta
    remove_index :sys_messages, :delta
    
    # for 006_create_groups.rb
    remove_index :groups, :delta
    remove_index :group_members, :delta
    remove_index :group_images, :delta
    remove_index :group_posts, :delta
    remove_index :group_post_comments, :delta
    remove_index :group_photos, :delta
    
    # for 007_create_activities.rb
    remove_index :activities, :delta
    remove_index :group_activities, :delta
    remove_index :activity_members, :delta
    remove_index :activity_interests, :delta
    remove_index :activity_images, :delta
    remove_index :activity_posts, :delta
    remove_index :activity_post_comments, :delta
    remove_index :activity_photos, :delta
    
    # for 008_create_recruitments.rb
    remove_index :recruitments, :delta
    remove_index :recruitment_tags, :delta
    
    # for 009_create_votes.rb
    remove_index :vote_categories, :delta
    remove_index :vote_topics, :delta
    remove_index :vote_images, :delta
    remove_index :vote_options, :delta
    remove_index :vote_records, :delta
    remove_index :vote_comments, :delta
    
    # for 012_create_service_applications.rb
    remove_index :service_applications, :delta
    
    # for 015_activity_group_pictures.rb
    remove_index :activity_pictures, :delta
    remove_index :activity_picture_comments, :delta
    remove_index :group_pictures, :delta
    remove_index :group_picture_comments, :delta
    
    # for 018_create_talks.rb
    remove_index :talks, :delta
    remove_index :talk_reporters, :delta
    remove_index :talk_talkers, :delta
    remove_index :talk_questions, :delta
    remove_index :talk_answers, :delta
    remove_index :talkers, :delta
    remove_index :talk_comments, :delta
    remove_index :job_tags, :delta
    
    # for 019_create_view_counters.rb
    remove_index :view_counters, :delta
    
    # for 023_create_job_infos.rb
    remove_index :job_infos, :delta
    remove_index :industry_infos, :delta
    remove_index :company_infos, :delta
    remove_index :job_position_infos, :delta
    
    # for 026_create_exps.rb
    remove_index :exps, :delta
    
    # for 028_create_job_target_notes.rb
    remove_index :job_target_notes, :delta
    
    # for 030_create_job_services.rb
    remove_index :job_services, :delta
    remove_index :job_service_evaluations, :delta
    
    # for 031_job_service_categories_delta_index.rb
    remove_index :job_service_categories, :delta
    
    # for 033_create_goals.rb
    remove_index :goals, :delta
    remove_index :goal_follows, :delta
    remove_index :goal_tracks, :delta
    remove_index :goal_track_comments, :delta
    remove_index :goal_posts, :delta
    remove_index :goal_post_comments, :delta
    
  end

  def self.down
    
    # for 001_create_accounts.rb
    add_index :accounts, :delta
    add_index :timezones, :delta
    add_index :roles, :delta
    add_index :accounts_roles, :delta
    add_index :autologins, :delta
    add_index :account_settings, :delta
    
    # for 002_create_profiles.rb
    add_index :provinces, :delta
    add_index :cities, :delta
    add_index :basic_profiles, :delta
    add_index :contact_profiles, :delta
    add_index :hobby_profiles, :delta
    add_index :education_profiles, :delta
    add_index :job_profiles, :delta
    add_index :point_profiles, :delta
    add_index :pic_profiles, :delta
    
    # for 003_create_photos.rb
    add_index :albums, :delta
    add_index :photos, :delta
    add_index :photo_comments, :delta
    
    # for 004_create_blogs.rb
    add_index :blogs, :delta
    add_index :blog_comments, :delta
    
    # for 005_create_friends.rb
    add_index :space_comments, :delta
    add_index :friends, :delta
    add_index :account_actions, :delta
    add_index :messages, :delta
    add_index :sent_messages, :delta
    add_index :sys_messages, :delta
    
    # for 006_create_groups.rb
    add_index :groups, :delta
    add_index :group_members, :delta
    add_index :group_images, :delta
    add_index :group_posts, :delta
    add_index :group_post_comments, :delta
    add_index :group_photos, :delta
    
    # for 007_create_activities.rb
    add_index :activities, :delta
    add_index :group_activities, :delta
    add_index :activity_members, :delta
    add_index :activity_interests, :delta
    add_index :activity_images, :delta
    add_index :activity_posts, :delta
    add_index :activity_post_comments, :delta
    add_index :activity_photos, :delta
    
    # for 008_create_recruitments.rb
    add_index :recruitments, :delta
    add_index :recruitment_tags, :delta
    
    # for 009_create_votes.rb
    add_index :vote_categories, :delta
    add_index :vote_topics, :delta
    add_index :vote_images, :delta
    add_index :vote_options, :delta
    add_index :vote_records, :delta
    add_index :vote_comments, :delta
    
    # for 012_create_service_applications.rb
    add_index :service_applications, :delta
    
    # for 015_activity_group_pictures.rb
    add_index :activity_pictures, :delta
    add_index :activity_picture_comments, :delta
    add_index :group_pictures, :delta
    add_index :group_picture_comments, :delta
    
    # for 018_create_talks.rb
    add_index :talks, :delta
    add_index :talk_reporters, :delta
    add_index :talk_talkers, :delta
    add_index :talk_questions, :delta
    add_index :talk_answers, :delta
    add_index :talkers, :delta
    add_index :talk_comments, :delta
    add_index :job_tags, :delta
    
    # for 019_create_view_counters.rb
    add_index :view_counters, :delta
    
    # for 023_create_job_infos.rb
    add_index :job_infos, :delta
    add_index :industry_infos, :delta
    add_index :company_infos, :delta
    add_index :job_position_infos, :delta
    
    # for 026_create_exps.rb
    add_index :exps, :delta
    
    # for 028_create_job_target_notes.rb
    add_index :job_target_notes, :delta
    
    # for 030_create_job_services.rb
    add_index :job_services, :delta
    add_index :job_service_evaluations, :delta
    
    # for 031_job_service_categories_delta_index.rb
    add_index :job_service_categories, :delta
    
    # for 033_create_goals.rb
    add_index :goals, :delta
    add_index :goal_follows, :delta
    add_index :goal_tracks, :delta
    add_index :goal_track_comments, :delta
    add_index :goal_posts, :delta
    add_index :goal_post_comments, :delta
    
  end
end

