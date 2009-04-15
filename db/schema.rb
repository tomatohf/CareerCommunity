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

ActiveRecord::Schema.define(:version => 30) do

  create_table "account_actions", :force => true do |t|
    t.integer  "account_id",  :limit => 11
    t.datetime "created_at"
    t.string   "action_type", :limit => 30
    t.text     "raw_data"
    t.boolean  "delta"
    t.boolean  "hide",                      :default => false
  end

  add_index "account_actions", ["account_id"], :name => "index_account_actions_on_account_id"
  add_index "account_actions", ["created_at"], :name => "index_account_actions_on_created_at"
  add_index "account_actions", ["action_type"], :name => "index_account_actions_on_action_type"
  add_index "account_actions", ["delta"], :name => "index_account_actions_on_delta"
  add_index "account_actions", ["hide"], :name => "index_account_actions_on_hide"

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
    t.boolean  "cancelled",                                                         :default => false
    t.boolean  "online",                                                            :default => false
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

  create_table "activity_picture_comments", :force => true do |t|
    t.integer  "activity_picture_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",          :limit => 11
    t.string   "content",             :limit => 1000
    t.boolean  "delta"
  end

  add_index "activity_picture_comments", ["activity_picture_id"], :name => "index_activity_picture_comments_on_activity_picture_id"
  add_index "activity_picture_comments", ["account_id"], :name => "index_activity_picture_comments_on_account_id"
  add_index "activity_picture_comments", ["created_at"], :name => "index_activity_picture_comments_on_created_at"
  add_index "activity_picture_comments", ["delta"], :name => "index_activity_picture_comments_on_delta"

  create_table "activity_pictures", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "activity_id",        :limit => 11
    t.integer  "account_id",         :limit => 11
    t.string   "title",              :limit => 1000
    t.boolean  "top",                                :default => false
    t.boolean  "good",                               :default => false
    t.datetime "responded_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size",    :limit => 11
    t.boolean  "delta"
  end

  add_index "activity_pictures", ["created_at"], :name => "index_activity_pictures_on_created_at"
  add_index "activity_pictures", ["activity_id"], :name => "index_activity_pictures_on_activity_id"
  add_index "activity_pictures", ["account_id"], :name => "index_activity_pictures_on_account_id"
  add_index "activity_pictures", ["top"], :name => "index_activity_pictures_on_top"
  add_index "activity_pictures", ["good"], :name => "index_activity_pictures_on_good"
  add_index "activity_pictures", ["responded_at"], :name => "index_activity_pictures_on_responded_at"
  add_index "activity_pictures", ["delta"], :name => "index_activity_pictures_on_delta"

  create_table "activity_post_attachments", :force => true do |t|
    t.datetime "created_at"
    t.integer  "activity_post_id",        :limit => 11
    t.integer  "account_id",              :limit => 11
    t.string   "desc",                    :limit => 1000
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size",    :limit => 11
    t.boolean  "delta"
  end

  add_index "activity_post_attachments", ["created_at"], :name => "index_activity_post_attachments_on_created_at"
  add_index "activity_post_attachments", ["activity_post_id"], :name => "index_activity_post_attachments_on_activity_post_id"
  add_index "activity_post_attachments", ["account_id"], :name => "index_activity_post_attachments_on_account_id"

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
    t.boolean  "good",                       :default => false
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

  create_table "companies", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id", :limit => 11,   :default => 0
    t.string   "name"
    t.string   "desc",       :limit => 1000
    t.boolean  "delta"
  end

  add_index "companies", ["created_at"], :name => "index_companies_on_created_at"

  create_table "companies_industries", :id => false, :force => true do |t|
    t.integer "company_id",  :limit => 11
    t.integer "industry_id", :limit => 11
  end

  add_index "companies_industries", ["company_id"], :name => "index_companies_industries_on_company_id"
  add_index "companies_industries", ["industry_id"], :name => "index_companies_industries_on_industry_id"

  create_table "company_infos", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id", :limit => 11
    t.integer  "updater_id", :limit => 11
    t.string   "title"
    t.text     "content"
    t.integer  "company_id", :limit => 11
    t.boolean  "delta"
  end

  add_index "company_infos", ["created_at"], :name => "index_company_infos_on_created_at"
  add_index "company_infos", ["updated_at"], :name => "index_company_infos_on_updated_at"
  add_index "company_infos", ["creator_id"], :name => "index_company_infos_on_creator_id"
  add_index "company_infos", ["updater_id"], :name => "index_company_infos_on_updater_id"
  add_index "company_infos", ["company_id"], :name => "index_company_infos_on_company_id"
  add_index "company_infos", ["delta"], :name => "index_company_infos_on_delta"

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

  create_table "exps", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.datetime "publish_time"
    t.string   "source_name"
    t.string   "source_link"
    t.boolean  "active",                     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",   :limit => 11
    t.boolean  "delta"
  end

  add_index "exps", ["publish_time"], :name => "index_exps_on_publish_time"
  add_index "exps", ["source_link"], :name => "index_exps_on_source_link"
  add_index "exps", ["active"], :name => "index_exps_on_active"
  add_index "exps", ["created_at"], :name => "index_exps_on_created_at"
  add_index "exps", ["delta"], :name => "index_exps_on_delta"

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

  create_table "group_bookmarks", :force => true do |t|
    t.datetime "created_at"
    t.integer  "account_id", :limit => 11
    t.integer  "group_id",   :limit => 11
    t.string   "title"
    t.string   "url"
    t.string   "desc",       :limit => 1000
    t.boolean  "delta"
  end

  add_index "group_bookmarks", ["created_at"], :name => "index_group_bookmarks_on_created_at"
  add_index "group_bookmarks", ["account_id"], :name => "index_group_bookmarks_on_account_id"
  add_index "group_bookmarks", ["group_id"], :name => "index_group_bookmarks_on_group_id"

  create_table "group_images", :force => true do |t|
    t.integer  "group_id",   :limit => 11
    t.datetime "updated_at"
    t.integer  "photo_id",   :limit => 11
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

  create_table "group_picture_comments", :force => true do |t|
    t.integer  "group_picture_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",       :limit => 11
    t.string   "content",          :limit => 1000
    t.boolean  "delta"
  end

  add_index "group_picture_comments", ["group_picture_id"], :name => "index_group_picture_comments_on_group_picture_id"
  add_index "group_picture_comments", ["account_id"], :name => "index_group_picture_comments_on_account_id"
  add_index "group_picture_comments", ["created_at"], :name => "index_group_picture_comments_on_created_at"
  add_index "group_picture_comments", ["delta"], :name => "index_group_picture_comments_on_delta"

  create_table "group_pictures", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id",           :limit => 11
    t.integer  "account_id",         :limit => 11
    t.string   "title",              :limit => 1000
    t.boolean  "top",                                :default => false
    t.boolean  "good",                               :default => false
    t.datetime "responded_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size",    :limit => 11
    t.boolean  "delta"
  end

  add_index "group_pictures", ["created_at"], :name => "index_group_pictures_on_created_at"
  add_index "group_pictures", ["group_id"], :name => "index_group_pictures_on_group_id"
  add_index "group_pictures", ["account_id"], :name => "index_group_pictures_on_account_id"
  add_index "group_pictures", ["top"], :name => "index_group_pictures_on_top"
  add_index "group_pictures", ["good"], :name => "index_group_pictures_on_good"
  add_index "group_pictures", ["responded_at"], :name => "index_group_pictures_on_responded_at"
  add_index "group_pictures", ["delta"], :name => "index_group_pictures_on_delta"

  create_table "group_post_attachments", :force => true do |t|
    t.datetime "created_at"
    t.integer  "group_post_id",           :limit => 11
    t.integer  "account_id",              :limit => 11
    t.string   "desc",                    :limit => 1000
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size",    :limit => 11
    t.boolean  "delta"
  end

  add_index "group_post_attachments", ["created_at"], :name => "index_group_post_attachments_on_created_at"
  add_index "group_post_attachments", ["group_post_id"], :name => "index_group_post_attachments_on_group_post_id"
  add_index "group_post_attachments", ["account_id"], :name => "index_group_post_attachments_on_account_id"

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
    t.boolean  "good",                       :default => false
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
    t.boolean  "dismissed",                  :default => false
    t.string   "custom_key"
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

  create_table "industries", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id", :limit => 11,   :default => 0
    t.string   "name"
    t.string   "desc",       :limit => 1000
    t.boolean  "delta"
  end

  add_index "industries", ["created_at"], :name => "index_industries_on_created_at"
  add_index "industries", ["account_id"], :name => "index_industries_on_account_id"

  create_table "industry_infos", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",  :limit => 11
    t.integer  "updater_id",  :limit => 11
    t.string   "title"
    t.text     "content"
    t.integer  "industry_id", :limit => 11
    t.boolean  "delta"
  end

  add_index "industry_infos", ["created_at"], :name => "index_industry_infos_on_created_at"
  add_index "industry_infos", ["updated_at"], :name => "index_industry_infos_on_updated_at"
  add_index "industry_infos", ["creator_id"], :name => "index_industry_infos_on_creator_id"
  add_index "industry_infos", ["updater_id"], :name => "index_industry_infos_on_updater_id"
  add_index "industry_infos", ["industry_id"], :name => "index_industry_infos_on_industry_id"
  add_index "industry_infos", ["delta"], :name => "index_industry_infos_on_delta"

  create_table "job_info_categories", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "desc",               :limit => 1000
    t.integer  "parent_category_id", :limit => 11
    t.boolean  "delta"
  end

  add_index "job_info_categories", ["created_at"], :name => "index_job_info_categories_on_created_at"
  add_index "job_info_categories", ["updated_at"], :name => "index_job_info_categories_on_updated_at"
  add_index "job_info_categories", ["parent_category_id"], :name => "index_job_info_categories_on_parent_category_id"

  create_table "job_infos", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id", :limit => 11
    t.integer  "updater_id", :limit => 11
    t.string   "title"
    t.text     "content"
    t.boolean  "general",                  :default => false
    t.boolean  "delta"
  end

  add_index "job_infos", ["created_at"], :name => "index_job_infos_on_created_at"
  add_index "job_infos", ["updated_at"], :name => "index_job_infos_on_updated_at"
  add_index "job_infos", ["creator_id"], :name => "index_job_infos_on_creator_id"
  add_index "job_infos", ["updater_id"], :name => "index_job_infos_on_updater_id"
  add_index "job_infos", ["delta"], :name => "index_job_infos_on_delta"

  create_table "job_infos_companies", :id => false, :force => true do |t|
    t.integer "job_info_id", :limit => 11
    t.integer "company_id",  :limit => 11
  end

  add_index "job_infos_companies", ["job_info_id"], :name => "index_job_infos_companies_on_job_info_id"
  add_index "job_infos_companies", ["company_id"], :name => "index_job_infos_companies_on_company_id"

  create_table "job_infos_industries", :id => false, :force => true do |t|
    t.integer "job_info_id", :limit => 11
    t.integer "industry_id", :limit => 11
  end

  add_index "job_infos_industries", ["job_info_id"], :name => "index_job_infos_industries_on_job_info_id"
  add_index "job_infos_industries", ["industry_id"], :name => "index_job_infos_industries_on_industry_id"

  create_table "job_infos_job_info_categories", :id => false, :force => true do |t|
    t.integer "job_info_id",          :limit => 11
    t.integer "job_info_category_id", :limit => 11
  end

  add_index "job_infos_job_info_categories", ["job_info_id"], :name => "index_job_infos_job_info_categories_on_job_info_id"
  add_index "job_infos_job_info_categories", ["job_info_category_id"], :name => "index_job_infos_job_info_categories_on_job_info_category_id"

  create_table "job_infos_job_positions", :id => false, :force => true do |t|
    t.integer "job_info_id",     :limit => 11
    t.integer "job_position_id", :limit => 11
  end

  add_index "job_infos_job_positions", ["job_info_id"], :name => "index_job_infos_job_positions_on_job_info_id"
  add_index "job_infos_job_positions", ["job_position_id"], :name => "index_job_infos_job_positions_on_job_position_id"

  create_table "job_infos_job_processes", :id => false, :force => true do |t|
    t.integer "job_info_id",    :limit => 11
    t.integer "job_process_id", :limit => 11
  end

  add_index "job_infos_job_processes", ["job_info_id"], :name => "index_job_infos_job_processes_on_job_info_id"
  add_index "job_infos_job_processes", ["job_process_id"], :name => "index_job_infos_job_processes_on_job_process_id"

  create_table "job_position_infos", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",      :limit => 11
    t.integer  "updater_id",      :limit => 11
    t.string   "title"
    t.text     "content"
    t.integer  "job_position_id", :limit => 11
    t.boolean  "delta"
  end

  add_index "job_position_infos", ["created_at"], :name => "index_job_position_infos_on_created_at"
  add_index "job_position_infos", ["updated_at"], :name => "index_job_position_infos_on_updated_at"
  add_index "job_position_infos", ["creator_id"], :name => "index_job_position_infos_on_creator_id"
  add_index "job_position_infos", ["updater_id"], :name => "index_job_position_infos_on_updater_id"
  add_index "job_position_infos", ["job_position_id"], :name => "index_job_position_infos_on_job_position_id"
  add_index "job_position_infos", ["delta"], :name => "index_job_position_infos_on_delta"

  create_table "job_position_infos_companies", :id => false, :force => true do |t|
    t.integer "job_position_info_id", :limit => 11
    t.integer "company_id",           :limit => 11
  end

  add_index "job_position_infos_companies", ["job_position_info_id"], :name => "index_job_position_infos_companies_on_job_position_info_id"
  add_index "job_position_infos_companies", ["company_id"], :name => "index_job_position_infos_companies_on_company_id"

  create_table "job_position_infos_industries", :id => false, :force => true do |t|
    t.integer "job_position_info_id", :limit => 11
    t.integer "industry_id",          :limit => 11
  end

  add_index "job_position_infos_industries", ["job_position_info_id"], :name => "index_job_position_infos_industries_on_job_position_info_id"
  add_index "job_position_infos_industries", ["industry_id"], :name => "index_job_position_infos_industries_on_industry_id"

  create_table "job_positions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id", :limit => 11,   :default => 0
    t.string   "name"
    t.string   "desc",       :limit => 1000
    t.boolean  "delta"
  end

  add_index "job_positions", ["created_at"], :name => "index_job_positions_on_created_at"

  create_table "job_processes", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id", :limit => 11, :default => 0
    t.string   "name"
    t.boolean  "delta"
  end

  add_index "job_processes", ["created_at"], :name => "index_job_processes_on_created_at"

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

  create_table "job_service_categories", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "desc",       :limit => 1000
    t.boolean  "delta"
  end

  add_index "job_service_categories", ["created_at"], :name => "index_job_service_categories_on_created_at"
  add_index "job_service_categories", ["updated_at"], :name => "index_job_service_categories_on_updated_at"

  create_table "job_service_evaluations", :force => true do |t|
    t.integer  "job_service_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",     :limit => 11
    t.integer  "point",          :limit => 1
    t.string   "content",        :limit => 1000
    t.boolean  "delta"
  end

  add_index "job_service_evaluations", ["created_at"], :name => "index_job_service_evaluations_on_created_at"
  add_index "job_service_evaluations", ["updated_at"], :name => "index_job_service_evaluations_on_updated_at"
  add_index "job_service_evaluations", ["job_service_id"], :name => "index_job_service_evaluations_on_job_service_id"
  add_index "job_service_evaluations", ["account_id"], :name => "index_job_service_evaluations_on_account_id"
  add_index "job_service_evaluations", ["point"], :name => "index_job_service_evaluations_on_point"
  add_index "job_service_evaluations", ["delta"], :name => "index_job_service_evaluations_on_delta"

  create_table "job_service_functions", :force => true do |t|
    t.string  "name"
    t.boolean "delta"
  end

  add_index "job_service_functions", ["name"], :name => "index_job_service_functions_on_name"
  add_index "job_service_functions", ["delta"], :name => "index_job_service_functions_on_delta"

  create_table "job_services", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "updater_id",  :limit => 11
    t.integer  "creator_id",  :limit => 11
    t.integer  "category_id", :limit => 11
    t.string   "name"
    t.string   "url"
    t.string   "place"
    t.string   "desc",        :limit => 1000
    t.string   "phone"
    t.string   "scope"
    t.integer  "cost",        :limit => 10,   :precision => 10, :scale => 0
    t.boolean  "delta"
  end

  add_index "job_services", ["created_at"], :name => "index_job_services_on_created_at"
  add_index "job_services", ["updated_at"], :name => "index_job_services_on_updated_at"
  add_index "job_services", ["creator_id"], :name => "index_job_services_on_creator_id"
  add_index "job_services", ["updater_id"], :name => "index_job_services_on_updater_id"
  add_index "job_services", ["category_id"], :name => "index_job_services_on_category_id"
  add_index "job_services", ["cost"], :name => "index_job_services_on_cost"
  add_index "job_services", ["delta"], :name => "index_job_services_on_delta"

  create_table "job_services_functions", :id => false, :force => true do |t|
    t.integer "job_service_id", :limit => 11
    t.integer "function_id",    :limit => 11
  end

  add_index "job_services_functions", ["job_service_id"], :name => "index_job_services_functions_on_job_service_id"
  add_index "job_services_functions", ["function_id"], :name => "index_job_services_functions_on_function_id"

  create_table "job_statuses", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id", :limit => 11, :default => 0
    t.string   "name"
    t.string   "color",      :limit => 7
    t.boolean  "delta"
  end

  add_index "job_statuses", ["created_at"], :name => "index_job_statuses_on_created_at"
  add_index "job_statuses", ["account_id"], :name => "index_job_statuses_on_account_id"
  add_index "job_statuses", ["color"], :name => "index_job_statuses_on_color"

  create_table "job_steps", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "job_target_id",  :limit => 11
    t.integer  "account_id",     :limit => 11
    t.integer  "job_process_id", :limit => 11
    t.string   "label"
    t.integer  "job_status_id",  :limit => 11
    t.datetime "begin_at"
    t.datetime "end_at"
    t.boolean  "delta"
    t.datetime "remind_at"
  end

  add_index "job_steps", ["created_at"], :name => "index_job_steps_on_created_at"
  add_index "job_steps", ["job_target_id"], :name => "index_job_steps_on_job_target_id"
  add_index "job_steps", ["account_id"], :name => "index_job_steps_on_account_id"
  add_index "job_steps", ["job_process_id"], :name => "index_job_steps_on_job_process_id"
  add_index "job_steps", ["job_status_id"], :name => "index_job_steps_on_job_status_id"

  create_table "job_tags", :force => true do |t|
    t.string  "name"
    t.boolean "delta"
  end

  add_index "job_tags", ["name"], :name => "index_job_tags_on_name"
  add_index "job_tags", ["delta"], :name => "index_job_tags_on_delta"

  create_table "job_target_notes", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "content"
    t.integer  "job_target_id", :limit => 11
    t.boolean  "delta"
  end

  add_index "job_target_notes", ["job_target_id"], :name => "index_job_target_notes_on_job_target_id"
  add_index "job_target_notes", ["updated_at"], :name => "index_job_target_notes_on_updated_at"
  add_index "job_target_notes", ["created_at"], :name => "index_job_target_notes_on_created_at"
  add_index "job_target_notes", ["delta"], :name => "index_job_target_notes_on_delta"

  create_table "job_targets", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",          :limit => 11
    t.integer  "company_id",          :limit => 11
    t.integer  "job_position_id",     :limit => 11
    t.integer  "current_job_step_id", :limit => 11
    t.boolean  "closed",                            :default => false
    t.text     "info"
    t.boolean  "delta"
    t.boolean  "starred",                           :default => false
  end

  add_index "job_targets", ["created_at"], :name => "index_job_targets_on_created_at"
  add_index "job_targets", ["updated_at"], :name => "index_job_targets_on_updated_at"
  add_index "job_targets", ["account_id"], :name => "index_job_targets_on_account_id"
  add_index "job_targets", ["company_id"], :name => "index_job_targets_on_company_id"
  add_index "job_targets", ["job_position_id"], :name => "index_job_targets_on_job_position_id"
  add_index "job_targets", ["current_job_step_id"], :name => "index_job_targets_on_current_job_step_id"
  add_index "job_targets", ["closed"], :name => "index_job_targets_on_closed"

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

  create_table "personal_bookmarks", :force => true do |t|
    t.datetime "created_at"
    t.integer  "account_id", :limit => 11
    t.string   "title"
    t.string   "url"
    t.string   "desc",       :limit => 1000
    t.boolean  "delta"
  end

  add_index "personal_bookmarks", ["created_at"], :name => "index_personal_bookmarks_on_created_at"
  add_index "personal_bookmarks", ["account_id"], :name => "index_personal_bookmarks_on_account_id"

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

  create_table "recruitment_tags", :force => true do |t|
    t.string  "name"
    t.boolean "delta"
  end

  add_index "recruitment_tags", ["name"], :name => "index_recruitment_tags_on_name"

  create_table "recruitments", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.datetime "publish_time"
    t.string   "location"
    t.integer  "recruitment_type", :limit => 1
    t.string   "source_name"
    t.string   "source_link"
    t.boolean  "active",                         :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",       :limit => 11
    t.boolean  "delta"
  end

  add_index "recruitments", ["publish_time"], :name => "index_recruitments_on_publish_time"
  add_index "recruitments", ["location"], :name => "index_recruitments_on_location"
  add_index "recruitments", ["recruitment_type"], :name => "index_recruitments_on_recruitment_type"
  add_index "recruitments", ["source_link"], :name => "index_recruitments_on_source_link"
  add_index "recruitments", ["active"], :name => "index_recruitments_on_active"
  add_index "recruitments", ["created_at"], :name => "index_recruitments_on_created_at"
  add_index "recruitments", ["updated_at"], :name => "index_recruitments_on_updated_at"

  create_table "recruitments_recruitment_tags", :id => false, :force => true do |t|
    t.integer "recruitment_id",     :limit => 11
    t.integer "recruitment_tag_id", :limit => 11
  end

  add_index "recruitments_recruitment_tags", ["recruitment_id"], :name => "index_recruitments_recruitment_tags_on_recruitment_id"
  add_index "recruitments_recruitment_tags", ["recruitment_tag_id"], :name => "index_recruitments_recruitment_tags_on_recruitment_tag_id"

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

  create_table "service_applications", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",   :limit => 11, :default => 0
    t.integer  "service_id",   :limit => 11
    t.boolean  "closed",                     :default => false
    t.string   "real_name"
    t.string   "school"
    t.string   "major"
    t.string   "grade"
    t.string   "mobile"
    t.string   "email"
    t.string   "requester_ip", :limit => 40
    t.boolean  "delta"
  end

  add_index "service_applications", ["created_at"], :name => "index_service_applications_on_created_at"
  add_index "service_applications", ["account_id"], :name => "index_service_applications_on_account_id"
  add_index "service_applications", ["service_id"], :name => "index_service_applications_on_service_id"
  add_index "service_applications", ["closed"], :name => "index_service_applications_on_closed"
  add_index "service_applications", ["delta"], :name => "index_service_applications_on_delta"

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

  create_table "talk_answers", :force => true do |t|
    t.integer  "talk_id",     :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",  :limit => 11
    t.integer  "updater_id",  :limit => 11
    t.integer  "question_id", :limit => 11
    t.integer  "talker_id",   :limit => 11
    t.text     "answer"
    t.string   "summary"
    t.boolean  "delta"
  end

  add_index "talk_answers", ["talk_id"], :name => "index_talk_answers_on_talk_id"
  add_index "talk_answers", ["created_at"], :name => "index_talk_answers_on_created_at"
  add_index "talk_answers", ["creator_id"], :name => "index_talk_answers_on_creator_id"
  add_index "talk_answers", ["updater_id"], :name => "index_talk_answers_on_updater_id"
  add_index "talk_answers", ["question_id"], :name => "index_talk_answers_on_question_id"
  add_index "talk_answers", ["talker_id"], :name => "index_talk_answers_on_talker_id"
  add_index "talk_answers", ["delta"], :name => "index_talk_answers_on_delta"

  create_table "talk_comments", :force => true do |t|
    t.integer  "talk_id",    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id", :limit => 11
    t.string   "content",    :limit => 1000
    t.boolean  "delta"
  end

  add_index "talk_comments", ["talk_id"], :name => "index_talk_comments_on_talk_id"
  add_index "talk_comments", ["account_id"], :name => "index_talk_comments_on_account_id"
  add_index "talk_comments", ["created_at"], :name => "index_talk_comments_on_created_at"
  add_index "talk_comments", ["delta"], :name => "index_talk_comments_on_delta"

  create_table "talk_question_categories", :force => true do |t|
    t.integer  "talk_id",    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id", :limit => 11
    t.integer  "updater_id", :limit => 11
    t.string   "name"
    t.string   "desc",       :limit => 1000
    t.boolean  "delta"
  end

  add_index "talk_question_categories", ["created_at"], :name => "index_talk_question_categories_on_created_at"
  add_index "talk_question_categories", ["talk_id"], :name => "index_talk_question_categories_on_talk_id"
  add_index "talk_question_categories", ["creator_id"], :name => "index_talk_question_categories_on_creator_id"
  add_index "talk_question_categories", ["updater_id"], :name => "index_talk_question_categories_on_updater_id"

  create_table "talk_questions", :force => true do |t|
    t.integer  "talk_id",     :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",  :limit => 11
    t.integer  "updater_id",  :limit => 11
    t.string   "question"
    t.string   "summary"
    t.integer  "category_id", :limit => 11
    t.boolean  "delta"
  end

  add_index "talk_questions", ["talk_id"], :name => "index_talk_questions_on_talk_id"
  add_index "talk_questions", ["created_at"], :name => "index_talk_questions_on_created_at"
  add_index "talk_questions", ["creator_id"], :name => "index_talk_questions_on_creator_id"
  add_index "talk_questions", ["updater_id"], :name => "index_talk_questions_on_updater_id"
  add_index "talk_questions", ["category_id"], :name => "index_talk_questions_on_category_id"
  add_index "talk_questions", ["delta"], :name => "index_talk_questions_on_delta"

  create_table "talk_questions_job_tags", :id => false, :force => true do |t|
    t.integer "talk_question_id", :limit => 11
    t.integer "job_tag_id",       :limit => 11
  end

  add_index "talk_questions_job_tags", ["talk_question_id"], :name => "index_talk_questions_job_tags_on_talk_question_id"
  add_index "talk_questions_job_tags", ["job_tag_id"], :name => "index_talk_questions_job_tags_on_job_tag_id"

  create_table "talk_reporters", :force => true do |t|
    t.integer  "talk_id",    :limit => 11
    t.datetime "created_at"
    t.string   "name"
    t.boolean  "delta"
  end

  add_index "talk_reporters", ["talk_id"], :name => "index_talk_reporters_on_talk_id"
  add_index "talk_reporters", ["created_at"], :name => "index_talk_reporters_on_created_at"
  add_index "talk_reporters", ["delta"], :name => "index_talk_reporters_on_delta"

  create_table "talk_talkers", :force => true do |t|
    t.integer  "talk_id",    :limit => 11
    t.datetime "created_at"
    t.integer  "talker_id",  :limit => 11
    t.boolean  "delta"
  end

  add_index "talk_talkers", ["talk_id"], :name => "index_talk_talkers_on_talk_id"
  add_index "talk_talkers", ["created_at"], :name => "index_talk_talkers_on_created_at"
  add_index "talk_talkers", ["talker_id"], :name => "index_talk_talkers_on_talker_id"
  add_index "talk_talkers", ["delta"], :name => "index_talk_talkers_on_delta"

  create_table "talkers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "real_name",  :limit => 50
    t.boolean  "gender"
    t.string   "age"
    t.string   "nick"
    t.string   "company"
    t.string   "position"
    t.string   "experience", :limit => 1000
    t.string   "email"
    t.string   "mobile",     :limit => 25
    t.string   "phone",      :limit => 25
    t.string   "msn"
    t.string   "gtalk"
    t.string   "qq",         :limit => 20
    t.string   "skype"
    t.string   "other",      :limit => 1000
    t.boolean  "delta"
  end

  add_index "talkers", ["real_name"], :name => "index_talkers_on_real_name"
  add_index "talkers", ["delta"], :name => "index_talkers_on_delta"

  create_table "talks", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id", :limit => 11
    t.integer  "updater_id", :limit => 11
    t.string   "title"
    t.text     "info"
    t.string   "sn"
    t.string   "place"
    t.datetime "begin_at"
    t.datetime "end_at"
    t.boolean  "published",                :default => false
    t.datetime "publish_at"
    t.boolean  "delta"
  end

  add_index "talks", ["created_at"], :name => "index_talks_on_created_at"
  add_index "talks", ["creator_id"], :name => "index_talks_on_creator_id"
  add_index "talks", ["updater_id"], :name => "index_talks_on_updater_id"
  add_index "talks", ["sn"], :name => "index_talks_on_sn"
  add_index "talks", ["begin_at"], :name => "index_talks_on_begin_at"
  add_index "talks", ["end_at"], :name => "index_talks_on_end_at"
  add_index "talks", ["published"], :name => "index_talks_on_published"
  add_index "talks", ["publish_at"], :name => "index_talks_on_publish_at"
  add_index "talks", ["delta"], :name => "index_talks_on_delta"

  create_table "talks_companies", :id => false, :force => true do |t|
    t.integer "talk_id",    :limit => 11
    t.integer "company_id", :limit => 11
  end

  add_index "talks_companies", ["talk_id"], :name => "index_talks_companies_on_talk_id"
  add_index "talks_companies", ["company_id"], :name => "index_talks_companies_on_company_id"

  create_table "talks_industries", :id => false, :force => true do |t|
    t.integer "talk_id",     :limit => 11
    t.integer "industry_id", :limit => 11
  end

  add_index "talks_industries", ["talk_id"], :name => "index_talks_industries_on_talk_id"
  add_index "talks_industries", ["industry_id"], :name => "index_talks_industries_on_industry_id"

  create_table "talks_job_positions", :id => false, :force => true do |t|
    t.integer "talk_id",         :limit => 11
    t.integer "job_position_id", :limit => 11
  end

  add_index "talks_job_positions", ["talk_id"], :name => "index_talks_job_positions_on_talk_id"
  add_index "talks_job_positions", ["job_position_id"], :name => "index_talks_job_positions_on_job_position_id"

  create_table "talks_job_processes", :id => false, :force => true do |t|
    t.integer "talk_id",        :limit => 11
    t.integer "job_process_id", :limit => 11
  end

  add_index "talks_job_processes", ["talk_id"], :name => "index_talks_job_processes_on_talk_id"
  add_index "talks_job_processes", ["job_process_id"], :name => "index_talks_job_processes_on_job_process_id"

  create_table "timezones", :force => true do |t|
    t.string  "name"
    t.integer "offset", :limit => 11
    t.boolean "delta"
  end

  add_index "timezones", ["name"], :name => "index_timezones_on_name"
  add_index "timezones", ["delta"], :name => "index_timezones_on_delta"

  create_table "trash_records", :force => true do |t|
    t.string   "trashable_type"
    t.integer  "trashable_id",   :limit => 11
    t.binary   "data",           :limit => 16777215
    t.datetime "created_at"
  end

  add_index "trash_records", ["trashable_type", "trashable_id"], :name => "index_trash_records_on_trashable_type_and_trashable_id"
  add_index "trash_records", ["created_at", "trashable_type"], :name => "index_trash_records_on_created_at_and_trashable_type"

  create_table "view_counters", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "counter_key", :limit => 11
    t.integer  "view_count",  :limit => 11
    t.boolean  "delta"
  end

  add_index "view_counters", ["updated_at"], :name => "index_view_counters_on_updated_at"
  add_index "view_counters", ["created_at"], :name => "index_view_counters_on_created_at"
  add_index "view_counters", ["counter_key"], :name => "index_view_counters_on_counter_key"
  add_index "view_counters", ["view_count"], :name => "index_view_counters_on_view_count"
  add_index "view_counters", ["delta"], :name => "index_view_counters_on_delta"

  create_table "vote_categories", :force => true do |t|
    t.string  "name"
    t.boolean "delta"
  end

  add_index "vote_categories", ["name"], :name => "index_vote_categories_on_name"
  add_index "vote_categories", ["delta"], :name => "index_vote_categories_on_delta"

  create_table "vote_comments", :force => true do |t|
    t.integer  "vote_topic_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",    :limit => 11
    t.string   "content",       :limit => 1000
    t.boolean  "delta"
  end

  add_index "vote_comments", ["vote_topic_id"], :name => "index_vote_comments_on_vote_topic_id"
  add_index "vote_comments", ["account_id"], :name => "index_vote_comments_on_account_id"
  add_index "vote_comments", ["created_at"], :name => "index_vote_comments_on_created_at"
  add_index "vote_comments", ["delta"], :name => "index_vote_comments_on_delta"

  create_table "vote_images", :force => true do |t|
    t.integer  "vote_topic_id", :limit => 11
    t.datetime "updated_at"
    t.integer  "photo_id",      :limit => 11
    t.boolean  "delta"
  end

  add_index "vote_images", ["vote_topic_id"], :name => "index_vote_images_on_vote_topic_id"
  add_index "vote_images", ["photo_id"], :name => "index_vote_images_on_photo_id"
  add_index "vote_images", ["delta"], :name => "index_vote_images_on_delta"

  create_table "vote_options", :force => true do |t|
    t.datetime "created_at"
    t.integer  "account_id",    :limit => 11
    t.integer  "vote_topic_id", :limit => 11
    t.string   "title"
    t.string   "color",         :limit => 7
    t.boolean  "delta"
  end

  add_index "vote_options", ["created_at"], :name => "index_vote_options_on_created_at"
  add_index "vote_options", ["account_id"], :name => "index_vote_options_on_account_id"
  add_index "vote_options", ["vote_topic_id"], :name => "index_vote_options_on_vote_topic_id"
  add_index "vote_options", ["color"], :name => "index_vote_options_on_color"
  add_index "vote_options", ["delta"], :name => "index_vote_options_on_delta"

  create_table "vote_records", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",     :limit => 11
    t.integer  "vote_topic_id",  :limit => 11
    t.integer  "vote_option_id", :limit => 11
    t.string   "voter_ip",       :limit => 40
    t.boolean  "delta"
  end

  add_index "vote_records", ["created_at"], :name => "index_vote_records_on_created_at"
  add_index "vote_records", ["updated_at"], :name => "index_vote_records_on_updated_at"
  add_index "vote_records", ["account_id"], :name => "index_vote_records_on_account_id"
  add_index "vote_records", ["vote_topic_id"], :name => "index_vote_records_on_vote_topic_id"
  add_index "vote_records", ["vote_option_id"], :name => "index_vote_records_on_vote_option_id"
  add_index "vote_records", ["voter_ip"], :name => "index_vote_records_on_voter_ip"
  add_index "vote_records", ["delta"], :name => "index_vote_records_on_delta"

  create_table "vote_topics", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "desc",               :limit => 1000
    t.integer  "account_id",         :limit => 11
    t.integer  "category_id",        :limit => 11
    t.boolean  "multiple",                           :default => false
    t.boolean  "allow_add_option",                   :default => false
    t.integer  "group_id",           :limit => 11,   :default => 0
    t.boolean  "delta"
    t.boolean  "allow_clear_record",                 :default => false
    t.boolean  "allow_anonymous",                    :default => false
  end

  add_index "vote_topics", ["created_at"], :name => "index_vote_topics_on_created_at"
  add_index "vote_topics", ["account_id"], :name => "index_vote_topics_on_account_id"
  add_index "vote_topics", ["category_id"], :name => "index_vote_topics_on_category_id"
  add_index "vote_topics", ["multiple"], :name => "index_vote_topics_on_multiple"
  add_index "vote_topics", ["allow_add_option"], :name => "index_vote_topics_on_allow_add_option"
  add_index "vote_topics", ["delta"], :name => "index_vote_topics_on_delta"
  add_index "vote_topics", ["allow_anonymous"], :name => "index_vote_topics_on_allow_anonymous"

end
