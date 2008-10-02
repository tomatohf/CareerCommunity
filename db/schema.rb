# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 7) do

  create_table "account_actions", :force => true do |t|
    t.integer  "account_id",  :limit => 11
    t.datetime "created_at"
    t.string   "action_type", :limit => 30
    t.text     "raw_data"
    t.boolean  "delta"
  end

  add_index "account_actions", ["account_id"], :name => "index_account_actions_on_account_id"
  add_index "account_actions", ["created_at"], :name => "index_account_actions_on_created_at"
  add_index "account_actions", ["action_type"], :name => "index_account_actions_on_action_type"
  add_index "account_actions", ["delta"], :name => "index_account_actions_on_delta"

  create_table "account_settings", :force => true do |t|
    t.integer  "account_id", :limit => 11
    t.text     "setting"
    t.datetime "updated_at"
    t.boolean  "delta"
  end

  add_index "account_settings", ["account_id"], :name => "index_account_settings_on_account_id"
  add_index "account_settings", ["delta"], :name => "index_account_settings_on_delta"

  create_table "accounts", :force => true do |t|
    t.string   "email"
    t.string   "password"
    t.string   "nick"
    t.integer  "timezone_id", :limit => 11
    t.boolean  "checked",                   :default => false
    t.boolean  "active",                    :default => true
    t.boolean  "enabled",                   :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta"
  end

  add_index "accounts", ["email"], :name => "index_accounts_on_email", :unique => true
  add_index "accounts", ["enabled"], :name => "index_accounts_on_enabled"
  add_index "accounts", ["delta"], :name => "index_accounts_on_delta"

  create_table "accounts_roles", :id => false, :force => true do |t|
    t.integer "account_id", :limit => 11
    t.integer "role_id",    :limit => 11
    t.boolean "delta"
  end

  add_index "accounts_roles", ["account_id", "role_id"], :name => "index_accounts_roles_on_account_id_and_role_id"
  add_index "accounts_roles", ["delta"], :name => "index_accounts_roles_on_delta"

  create_table "activities", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",           :limit => 11
    t.integer  "master_id",            :limit => 11
    t.string   "title"
    t.datetime "begin_at"
    t.datetime "end_at"
    t.datetime "application_deadline"
    t.string   "place"
    t.integer  "cost",                 :limit => 10, :precision => 10, :scale => 0
    t.integer  "member_limit",         :limit => 11
    t.integer  "in_group",             :limit => 11
    t.text     "setting"
    t.boolean  "delta"
  end

  add_index "activities", ["created_at"], :name => "index_activities_on_created_at"
  add_index "activities", ["creator_id"], :name => "index_activities_on_creator_id"
  add_index "activities", ["master_id"], :name => "index_activities_on_master_id"
  add_index "activities", ["begin_at"], :name => "index_activities_on_begin_at"
  add_index "activities", ["end_at"], :name => "index_activities_on_end_at"
  add_index "activities", ["application_deadline"], :name => "index_activities_on_application_deadline"
  add_index "activities", ["cost"], :name => "index_activities_on_cost"
  add_index "activities", ["member_limit"], :name => "index_activities_on_member_limit"
  add_index "activities", ["in_group"], :name => "index_activities_on_in_group"
  add_index "activities", ["delta"], :name => "index_activities_on_delta"

  create_table "activity_images", :force => true do |t|
    t.integer  "activity_id", :limit => 11
    t.datetime "updated_at"
    t.integer  "photo_id",    :limit => 11
    t.string   "pic_url"
    t.boolean  "delta"
  end

  add_index "activity_images", ["activity_id"], :name => "index_activity_images_on_activity_id"
  add_index "activity_images", ["photo_id"], :name => "index_activity_images_on_photo_id"
  add_index "activity_images", ["delta"], :name => "index_activity_images_on_delta"

  create_table "activity_interests", :force => true do |t|
    t.datetime "created_at"
    t.integer  "activity_id", :limit => 11
    t.integer  "account_id",  :limit => 11
    t.boolean  "delta"
  end

  add_index "activity_interests", ["created_at"], :name => "index_activity_interests_on_created_at"
  add_index "activity_interests", ["activity_id"], :name => "index_activity_interests_on_activity_id"
  add_index "activity_interests", ["account_id"], :name => "index_activity_interests_on_account_id"
  add_index "activity_interests", ["activity_id", "account_id"], :name => "index_activity_interests_on_activity_id_and_account_id"
  add_index "activity_interests", ["delta"], :name => "index_activity_interests_on_delta"

  create_table "activity_members", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "join_at"
    t.integer  "activity_id", :limit => 11
    t.integer  "account_id",  :limit => 11
    t.boolean  "accepted",                  :default => false
    t.boolean  "approved",                  :default => false
    t.boolean  "absent",                    :default => false
    t.boolean  "admin",                     :default => false
    t.boolean  "delta"
  end

  add_index "activity_members", ["created_at"], :name => "index_activity_members_on_created_at"
  add_index "activity_members", ["updated_at"], :name => "index_activity_members_on_updated_at"
  add_index "activity_members", ["join_at"], :name => "index_activity_members_on_join_at"
  add_index "activity_members", ["activity_id"], :name => "index_activity_members_on_activity_id"
  add_index "activity_members", ["account_id"], :name => "index_activity_members_on_account_id"
  add_index "activity_members", ["accepted"], :name => "index_activity_members_on_accepted"
  add_index "activity_members", ["approved"], :name => "index_activity_members_on_approved"
  add_index "activity_members", ["absent"], :name => "index_activity_members_on_absent"
  add_index "activity_members", ["activity_id", "account_id"], :name => "index_activity_members_on_activity_id_and_account_id"
  add_index "activity_members", ["admin"], :name => "index_activity_members_on_admin"
  add_index "activity_members", ["delta"], :name => "index_activity_members_on_delta"

  create_table "activity_photos", :force => true do |t|
    t.datetime "created_at"
    t.integer  "activity_id", :limit => 11
    t.integer  "photo_id",    :limit => 11
    t.integer  "account_id",  :limit => 11
    t.boolean  "delta"
  end

  add_index "activity_photos", ["activity_id"], :name => "index_activity_photos_on_activity_id"
  add_index "activity_photos", ["photo_id"], :name => "index_activity_photos_on_photo_id"
  add_index "activity_photos", ["account_id"], :name => "index_activity_photos_on_account_id"
  add_index "activity_photos", ["delta"], :name => "index_activity_photos_on_delta"

  create_table "activity_post_comments", :force => true do |t|
    t.integer  "activity_post_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",       :limit => 11
    t.string   "content",          :limit => 1000
    t.boolean  "delta"
  end

  add_index "activity_post_comments", ["activity_post_id"], :name => "index_activity_post_comments_on_activity_post_id"
  add_index "activity_post_comments", ["account_id"], :name => "index_activity_post_comments_on_account_id"
  add_index "activity_post_comments", ["created_at"], :name => "index_activity_post_comments_on_created_at"
  add_index "activity_post_comments", ["delta"], :name => "index_activity_post_comments_on_delta"

  create_table "activity_posts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "activity_id",  :limit => 11
    t.integer  "account_id",   :limit => 11
    t.string   "title"
    t.text     "content"
    t.boolean  "top",                        :default => false
    t.datetime "responded_at"
    t.boolean  "delta"
  end

  add_index "activity_posts", ["created_at"], :name => "index_activity_posts_on_created_at"
  add_index "activity_posts", ["activity_id"], :name => "index_activity_posts_on_activity_id"
  add_index "activity_posts", ["account_id"], :name => "index_activity_posts_on_account_id"
  add_index "activity_posts", ["top"], :name => "index_activity_posts_on_top"
  add_index "activity_posts", ["delta"], :name => "index_activity_posts_on_delta"

  create_table "albums", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",     :limit => 11
    t.string   "name"
    t.string   "description",    :limit => 1000
    t.integer  "cover_photo_id", :limit => 11
    t.boolean  "delta"
  end

  add_index "albums", ["account_id"], :name => "index_albums_on_account_id"
  add_index "albums", ["created_at"], :name => "index_albums_on_created_at"
  add_index "albums", ["updated_at"], :name => "index_albums_on_updated_at"
  add_index "albums", ["delta"], :name => "index_albums_on_delta"

  create_table "autologins", :force => true do |t|
    t.string   "session_id"
    t.integer  "account_id",  :limit => 11
    t.datetime "expire_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta"
  end

  add_index "autologins", ["account_id"], :name => "index_autologins_on_account_id"
  add_index "autologins", ["delta"], :name => "index_autologins_on_delta"

  create_table "basic_profiles", :force => true do |t|
    t.integer  "account_id",           :limit => 11
    t.datetime "updated_at"
    t.string   "real_name",            :limit => 50
    t.boolean  "gender"
    t.integer  "province_id",          :limit => 11
    t.integer  "city_id",              :limit => 11
    t.integer  "hometown_province_id", :limit => 11
    t.integer  "hometown_city_id",     :limit => 11
    t.date     "birthday"
    t.string   "qmd",                  :limit => 300
    t.boolean  "delta"
  end

  add_index "basic_profiles", ["account_id"], :name => "index_basic_profiles_on_account_id"
  add_index "basic_profiles", ["birthday"], :name => "index_basic_profiles_on_birthday"
  add_index "basic_profiles", ["real_name"], :name => "index_basic_profiles_on_real_name"
  add_index "basic_profiles", ["province_id"], :name => "index_basic_profiles_on_province_id"
  add_index "basic_profiles", ["city_id"], :name => "index_basic_profiles_on_city_id"
  add_index "basic_profiles", ["hometown_province_id"], :name => "index_basic_profiles_on_hometown_province_id"
  add_index "basic_profiles", ["hometown_city_id"], :name => "index_basic_profiles_on_hometown_city_id"
  add_index "basic_profiles", ["delta"], :name => "index_basic_profiles_on_delta"

  create_table "blog_comments", :force => true do |t|
    t.integer  "blog_id",    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id", :limit => 11
    t.string   "content",    :limit => 1000
    t.boolean  "delta"
  end

  add_index "blog_comments", ["blog_id"], :name => "index_blog_comments_on_blog_id"
  add_index "blog_comments", ["account_id"], :name => "index_blog_comments_on_account_id"
  add_index "blog_comments", ["created_at"], :name => "index_blog_comments_on_created_at"
  add_index "blog_comments", ["delta"], :name => "index_blog_comments_on_delta"

  create_table "blogs", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id", :limit => 11
    t.string   "title"
    t.text     "content"
    t.boolean  "delta"
  end

  add_index "blogs", ["account_id"], :name => "index_blogs_on_account_id"
  add_index "blogs", ["created_at"], :name => "index_blogs_on_created_at"
  add_index "blogs", ["delta"], :name => "index_blogs_on_delta"

  create_table "cities", :force => true do |t|
    t.string  "name"
    t.integer "province_id", :limit => 11
    t.boolean "delta"
  end

  add_index "cities", ["delta"], :name => "index_cities_on_delta"

  create_table "contact_profiles", :force => true do |t|
    t.integer  "account_id", :limit => 11
    t.datetime "updated_at"
    t.string   "msn"
    t.string   "gtalk"
    t.string   "qq",         :limit => 20
    t.string   "skype"
    t.string   "mobile",     :limit => 25
    t.string   "phone",      :limit => 25
    t.string   "address"
    t.string   "website"
    t.boolean  "delta"
  end

  add_index "contact_profiles", ["account_id"], :name => "index_contact_profiles_on_account_id"
  add_index "contact_profiles", ["delta"], :name => "index_contact_profiles_on_delta"

  create_table "education_profiles", :force => true do |t|
    t.integer  "account_id",   :limit => 11
    t.datetime "updated_at"
    t.integer  "education_id", :limit => 1
    t.integer  "enter_year",   :limit => 2
    t.string   "edu_name"
    t.string   "major"
    t.boolean  "delta"
  end

  add_index "education_profiles", ["account_id"], :name => "index_education_profiles_on_account_id"
  add_index "education_profiles", ["education_id"], :name => "index_education_profiles_on_education_id"
  add_index "education_profiles", ["enter_year"], :name => "index_education_profiles_on_enter_year"
  add_index "education_profiles", ["delta"], :name => "index_education_profiles_on_delta"

  create_table "friends", :force => true do |t|
    t.datetime "created_at"
    t.integer  "account_id", :limit => 11
    t.integer  "friend_id",  :limit => 11
    t.boolean  "delta"
  end

  add_index "friends", ["account_id"], :name => "index_friends_on_account_id"
  add_index "friends", ["friend_id"], :name => "index_friends_on_friend_id"
  add_index "friends", ["account_id", "friend_id"], :name => "index_friends_on_account_id_and_friend_id"
  add_index "friends", ["delta"], :name => "index_friends_on_delta"

  create_table "group_activities", :force => true do |t|
    t.datetime "created_at"
    t.integer  "activity_id", :limit => 11
    t.integer  "account_id",  :limit => 11
    t.boolean  "delta"
  end

  add_index "group_activities", ["delta"], :name => "index_group_activities_on_delta"

  create_table "group_images", :force => true do |t|
    t.integer  "group_id",   :limit => 11
    t.datetime "updated_at"
    t.integer  "photo_id",   :limit => 11
    t.string   "pic_url"
    t.boolean  "delta"
  end

  add_index "group_images", ["group_id"], :name => "index_group_images_on_group_id"
  add_index "group_images", ["photo_id"], :name => "index_group_images_on_photo_id"
  add_index "group_images", ["delta"], :name => "index_group_images_on_delta"

  create_table "group_members", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "join_at"
    t.integer  "group_id",   :limit => 11
    t.integer  "account_id", :limit => 11
    t.boolean  "accepted",                 :default => false
    t.boolean  "approved",                 :default => false
    t.boolean  "admin",                    :default => false
    t.boolean  "delta"
  end

  add_index "group_members", ["created_at"], :name => "index_group_members_on_created_at"
  add_index "group_members", ["updated_at"], :name => "index_group_members_on_updated_at"
  add_index "group_members", ["join_at"], :name => "index_group_members_on_join_at"
  add_index "group_members", ["group_id"], :name => "index_group_members_on_group_id"
  add_index "group_members", ["account_id"], :name => "index_group_members_on_account_id"
  add_index "group_members", ["accepted"], :name => "index_group_members_on_accepted"
  add_index "group_members", ["approved"], :name => "index_group_members_on_approved"
  add_index "group_members", ["admin"], :name => "index_group_members_on_admin"
  add_index "group_members", ["group_id", "account_id"], :name => "index_group_members_on_group_id_and_account_id"
  add_index "group_members", ["delta"], :name => "index_group_members_on_delta"

  create_table "group_photos", :force => true do |t|
    t.datetime "created_at"
    t.integer  "group_id",   :limit => 11
    t.integer  "photo_id",   :limit => 11
    t.integer  "account_id", :limit => 11
    t.boolean  "delta"
  end

  add_index "group_photos", ["group_id"], :name => "index_group_photos_on_group_id"
  add_index "group_photos", ["photo_id"], :name => "index_group_photos_on_photo_id"
  add_index "group_photos", ["account_id"], :name => "index_group_photos_on_account_id"
  add_index "group_photos", ["delta"], :name => "index_group_photos_on_delta"

  create_table "group_post_comments", :force => true do |t|
    t.integer  "group_post_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",    :limit => 11
    t.string   "content",       :limit => 1000
    t.boolean  "delta"
  end

  add_index "group_post_comments", ["group_post_id"], :name => "index_group_post_comments_on_group_post_id"
  add_index "group_post_comments", ["account_id"], :name => "index_group_post_comments_on_account_id"
  add_index "group_post_comments", ["created_at"], :name => "index_group_post_comments_on_created_at"
  add_index "group_post_comments", ["delta"], :name => "index_group_post_comments_on_delta"

  create_table "group_posts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id",     :limit => 11
    t.integer  "account_id",   :limit => 11
    t.string   "title"
    t.text     "content"
    t.boolean  "top",                        :default => false
    t.datetime "responded_at"
    t.boolean  "delta"
  end

  add_index "group_posts", ["created_at"], :name => "index_group_posts_on_created_at"
  add_index "group_posts", ["group_id"], :name => "index_group_posts_on_group_id"
  add_index "group_posts", ["account_id"], :name => "index_group_posts_on_account_id"
  add_index "group_posts", ["top"], :name => "index_group_posts_on_top"
  add_index "group_posts", ["delta"], :name => "index_group_posts_on_delta"

  create_table "groups", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id", :limit => 11
    t.integer  "master_id",  :limit => 11
    t.string   "name"
    t.string   "desc",       :limit => 1000
    t.text     "setting"
    t.boolean  "delta"
  end

  add_index "groups", ["created_at"], :name => "index_groups_on_created_at"
  add_index "groups", ["creator_id"], :name => "index_groups_on_creator_id"
  add_index "groups", ["master_id"], :name => "index_groups_on_master_id"
  add_index "groups", ["delta"], :name => "index_groups_on_delta"

  create_table "hobby_profiles", :force => true do |t|
    t.integer  "account_id", :limit => 11
    t.datetime "updated_at"
    t.string   "intro",      :limit => 1000
    t.string   "interest",   :limit => 1000
    t.string   "music",      :limit => 1000
    t.string   "movie",      :limit => 1000
    t.string   "cartoon",    :limit => 1000
    t.string   "game",       :limit => 1000
    t.string   "sport",      :limit => 1000
    t.string   "book",       :limit => 1000
    t.string   "words",      :limit => 1000
    t.string   "food",       :limit => 1000
    t.string   "idol",       :limit => 1000
    t.string   "car",        :limit => 1000
    t.string   "place",      :limit => 1000
    t.boolean  "delta"
  end

  add_index "hobby_profiles", ["account_id"], :name => "index_hobby_profiles_on_account_id"
  add_index "hobby_profiles", ["delta"], :name => "index_hobby_profiles_on_delta"

  create_table "job_profiles", :force => true do |t|
    t.integer  "account_id",     :limit => 11
    t.datetime "updated_at"
    t.integer  "profession_id",  :limit => 1
    t.integer  "enter_year",     :limit => 2
    t.integer  "enter_month",    :limit => 1
    t.string   "job_name"
    t.string   "dept"
    t.string   "position_title"
    t.string   "description",    :limit => 1000
    t.boolean  "delta"
  end

  add_index "job_profiles", ["account_id"], :name => "index_job_profiles_on_account_id"
  add_index "job_profiles", ["profession_id"], :name => "index_job_profiles_on_profession_id"
  add_index "job_profiles", ["enter_year"], :name => "index_job_profiles_on_enter_year"
  add_index "job_profiles", ["enter_month"], :name => "index_job_profiles_on_enter_month"
  add_index "job_profiles", ["delta"], :name => "index_job_profiles_on_delta"

  create_table "messages", :force => true do |t|
    t.datetime "created_at"
    t.integer  "receiver_id", :limit => 11
    t.integer  "sender_id",   :limit => 11
    t.string   "content",     :limit => 1000
    t.boolean  "has_read",                    :default => false
    t.integer  "reply_to_id", :limit => 11
    t.boolean  "delta"
  end

  add_index "messages", ["created_at"], :name => "index_messages_on_created_at"
  add_index "messages", ["receiver_id"], :name => "index_messages_on_receiver_id"
  add_index "messages", ["sender_id"], :name => "index_messages_on_sender_id"
  add_index "messages", ["has_read"], :name => "index_messages_on_has_read"
  add_index "messages", ["reply_to_id"], :name => "index_messages_on_reply_to_id"
  add_index "messages", ["delta"], :name => "index_messages_on_delta"

  create_table "photo_comments", :force => true do |t|
    t.integer  "photo_id",   :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id", :limit => 11
    t.string   "content",    :limit => 1000
    t.boolean  "delta"
  end

  add_index "photo_comments", ["photo_id"], :name => "index_photo_comments_on_photo_id"
  add_index "photo_comments", ["account_id"], :name => "index_photo_comments_on_account_id"
  add_index "photo_comments", ["created_at"], :name => "index_photo_comments_on_created_at"
  add_index "photo_comments", ["delta"], :name => "index_photo_comments_on_delta"

  create_table "photos", :force => true do |t|
    t.integer  "album_id",           :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",         :limit => 11
    t.string   "title"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size",    :limit => 11
    t.boolean  "delta"
  end

  add_index "photos", ["account_id"], :name => "index_photos_on_account_id"
  add_index "photos", ["album_id"], :name => "index_photos_on_album_id"
  add_index "photos", ["created_at"], :name => "index_photos_on_created_at"
  add_index "photos", ["delta"], :name => "index_photos_on_delta"

  create_table "pic_profiles", :force => true do |t|
    t.integer  "account_id", :limit => 11
    t.datetime "updated_at"
    t.integer  "photo_id",   :limit => 11
    t.string   "pic_url"
    t.boolean  "delta"
  end

  add_index "pic_profiles", ["account_id"], :name => "index_pic_profiles_on_account_id"
  add_index "pic_profiles", ["photo_id"], :name => "index_pic_profiles_on_photo_id"
  add_index "pic_profiles", ["delta"], :name => "index_pic_profiles_on_delta"

  create_table "point_profiles", :force => true do |t|
    t.integer  "account_id", :limit => 11
    t.datetime "updated_at"
    t.integer  "points",     :limit => 11
    t.integer  "exp",        :limit => 11
    t.boolean  "delta"
  end

  add_index "point_profiles", ["account_id"], :name => "index_point_profiles_on_account_id"
  add_index "point_profiles", ["points"], :name => "index_point_profiles_on_points"
  add_index "point_profiles", ["exp"], :name => "index_point_profiles_on_exp"
  add_index "point_profiles", ["delta"], :name => "index_point_profiles_on_delta"

  create_table "provinces", :force => true do |t|
    t.string  "name"
    t.boolean "delta"
  end

  add_index "provinces", ["delta"], :name => "index_provinces_on_delta"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta"
  end

  add_index "roles", ["name"], :name => "index_roles_on_name"
  add_index "roles", ["delta"], :name => "index_roles_on_delta"

  create_table "sent_messages", :force => true do |t|
    t.datetime "created_at"
    t.integer  "sender_id",   :limit => 11
    t.integer  "receiver_id", :limit => 11
    t.string   "content",     :limit => 1000
    t.integer  "reply_to_id", :limit => 11
    t.boolean  "delta"
  end

  add_index "sent_messages", ["created_at"], :name => "index_sent_messages_on_created_at"
  add_index "sent_messages", ["sender_id"], :name => "index_sent_messages_on_sender_id"
  add_index "sent_messages", ["receiver_id"], :name => "index_sent_messages_on_receiver_id"
  add_index "sent_messages", ["reply_to_id"], :name => "index_sent_messages_on_reply_to_id"
  add_index "sent_messages", ["delta"], :name => "index_sent_messages_on_delta"

  create_table "space_comments", :force => true do |t|
    t.integer  "owner_id",   :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id", :limit => 11
    t.string   "content",    :limit => 1000
    t.boolean  "delta"
  end

  add_index "space_comments", ["owner_id"], :name => "index_space_comments_on_owner_id"
  add_index "space_comments", ["account_id"], :name => "index_space_comments_on_account_id"
  add_index "space_comments", ["created_at"], :name => "index_space_comments_on_created_at"
  add_index "space_comments", ["delta"], :name => "index_space_comments_on_delta"

  create_table "sys_messages", :force => true do |t|
    t.integer  "account_id", :limit => 11
    t.datetime "created_at"
    t.boolean  "has_read",                 :default => false
    t.string   "msg_type",   :limit => 30
    t.text     "raw_data"
    t.boolean  "delta"
  end

  add_index "sys_messages", ["account_id"], :name => "index_sys_messages_on_account_id"
  add_index "sys_messages", ["created_at"], :name => "index_sys_messages_on_created_at"
  add_index "sys_messages", ["has_read"], :name => "index_sys_messages_on_has_read"
  add_index "sys_messages", ["msg_type"], :name => "index_sys_messages_on_msg_type"
  add_index "sys_messages", ["delta"], :name => "index_sys_messages_on_delta"

  create_table "timezones", :force => true do |t|
    t.string  "name"
    t.integer "offset", :limit => 11
    t.boolean "delta"
  end

  add_index "timezones", ["name"], :name => "index_timezones_on_name"
  add_index "timezones", ["delta"], :name => "index_timezones_on_delta"

end
