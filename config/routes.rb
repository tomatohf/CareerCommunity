ActionController::Routing::Routes.draw do |map|
  
  # map.connect "/community/search/:scope/:query", :controller => "community", :action => "search"
    
  map.resources :accounts, :collection => {
  
    :send_register_confirmation => :get,
    
    :logon => :get,
    :login_form => :get,
    :login => :post,
    
    :logout => :any,
    
    :forgot_password => :get,
    :send_password => :post,
    
    :return_original_page => :any
    
  }, :member => {
  
    :register_confirmation => :get,
    
    :update_password => :post,
    
    :edit_email => :get,
    :update_email => :post
  
  }
  
  
  map.resources :profiles, :collection => {
  
    :educations_del => :post,
    :auto_complete_for_edu_name => :post,
    
    :photo_selector_for_pic_profile => :get,
    
    :jobs_del => :post,
    :auto_complete_for_job_name => :post
    
  }, :member => {
  
    :basic => :any,
    :contact => :any,
    :hobby => :any,
    
    :educations => :get,
    :educations_add => :post,
    
    :jobs => :any,
    :jobs_add => :post,
    
    :pic => :any
    
  }
  

  map.resources :albums, :member => {
  
    :upload => :get,
    :upload_simple => :get,
    :create_photo => :post,
    :create_photo_simple => :post,
    
    :fetch_photos => :get
    
  }, :collection => {
    :create_photo_from_photo_selector => :post,
    
    :photo_selector => :get
  }
  
  
  map.connect "/photos/:id/comment/:page", :controller => "photos", :action => "show", :id => /\d+/, :page => /\d+/
  map.resources :photos, :member => {
    :create_comment => :post,
    
    :move_to_other_album => :post,
    
    :update_photo_title => :post
  }
  
  
  map.connect "/blogs/list/:id/:page", :controller => "blogs", :action => "list", :id => /\d+/, :page => /\d+/
  map.connect "/blogs/:id/comment/:page", :controller => "blogs", :action => "show", :id => /\d+/, :page => /\d+/
  map.resources :blogs, :member => {
    :create_comment => :post
  }
  
  
  map.connect "/spaces/wall/:id/:page", :controller => "spaces", :action => "wall", :id => /\d+/, :page => /\d+/
  map.connect "/spaces/actions/:id/:page", :controller => "spaces", :action => "actions", :id => /\d+/, :page => /\d+/
  map.connect "/spaces/friend_actions/:id/:page", :controller => "spaces", :action => "friend_actions", :id => /\d+/, :page => /\d+/
  
  map.connect "/spaces/actions/:id/:action_type", :controller => "spaces", :action => "actions", :id => /\d+/
  map.connect "/spaces/friend_actions/:id/:action_type", :controller => "spaces", :action => "friend_actions", :id => /\d+/
  map.connect "/spaces/actions/:id/:action_type/:page", :controller => "spaces", :action => "actions", :id => /\d+/, :page => /\d+/
  map.connect "/spaces/friend_actions/:id/:action_type/:page", :controller => "spaces", :action => "friend_actions", :id => /\d+/, :page => /\d+/
  
  
  map.resources :friends


  map.connect "/messages/inbox/:id/:page", :controller => "messages", :action => "inbox", :id => /\d+/, :page => /\d+/
  map.connect "/messages/outbox/:id/:page", :controller => "messages", :action => "outbox", :id => /\d+/, :page => /\d+/
  map.connect "/messages/sys/:id/:page", :controller => "messages", :action => "sys", :id => /\d+/, :page => /\d+/
  map.connect "/messages/thread/:id/:other_id/:reply_to_id", :controller => "messages", :action => "thread", :id => /\d+/, :other_id => /\d+/, :reply_to_id => /\d+/
  map.resources :messages
  
  
  map.connect "/groups/recent_index", :controller => "groups", :action => "recent_index"
  map.connect "/groups/list/:id/:page", :controller => "groups", :action => "list", :id => /\d+/, :page => /\d+/
  map.connect "/groups/list_admin/:id/:page", :controller => "groups", :action => "list_admin", :id => /\d+/, :page => /\d+/
  map.connect "/groups/all/:page", :controller => "groups", :action => "all", :page => /\d+/
  map.connect "/groups/members/:id/:page", :controller => "groups", :action => "members", :id => /\d+/, :page => /\d+/
  map.connect "/groups/members_edit/:id/:page", :controller => "groups", :action => "members_edit", :id => /\d+/, :page => /\d+/
  map.connect "/groups/members_master/:id/:page", :controller => "groups", :action => "members_master", :id => /\d+/, :page => /\d+/
  map.connect "/groups/unapproved/:id/:page", :controller => "groups", :action => "unapproved", :id => /\d+/, :page => /\d+/
  map.connect "/groups/post/:id/:page", :controller => "groups", :action => "post", :id => /\d+/, :page => /\d+/
  map.connect "/groups/good_post/:id/:page", :controller => "groups", :action => "good_post", :id => /\d+/, :page => /\d+/
  map.connect "/groups/picture/:id/:page", :controller => "groups", :action => "picture", :id => /\d+/, :page => /\d+/
  map.connect "/groups/good_picture/:id/:page", :controller => "groups", :action => "good_picture", :id => /\d+/, :page => /\d+/
  map.connect "/groups/activity/:id/:page", :controller => "groups", :action => "activity", :id => /\d+/, :page => /\d+/
  map.connect "/groups/vote/:id/:page", :controller => "groups", :action => "vote", :id => /\d+/, :page => /\d+/
  map.connect "/groups/photo/:id/:page", :controller => "groups", :action => "photo", :id => /\d+/, :page => /\d+/
  map.connect "/groups/bookmark/:id/:page", :controller => "groups", :action => "bookmark", :id => /\d+/, :page => /\d+/
  map.connect "/groups/all_post/:id/:page", :controller => "groups", :action => "all_post", :id => /\d+/, :page => /\d+/
  map.connect "/groups/all_activity/:id/:page", :controller => "groups", :action => "all_activity", :id => /\d+/, :page => /\d+/
  map.connect "/groups/all_vote/:id/:page", :controller => "groups", :action => "all_vote", :id => /\d+/, :page => /\d+/
  map.connect "/groups/all_photo/:id/:page", :controller => "groups", :action => "all_photo", :id => /\d+/, :page => /\d+/
  map.connect "/groups/all_picture/:id/:page", :controller => "groups", :action => "all_picture", :id => /\d+/, :page => /\d+/
  map.connect "/groups/all_bookmark/:id/:page", :controller => "groups", :action => "all_bookmark", :id => /\d+/, :page => /\d+/
  map.connect "/groups/created_post/:id/:page", :controller => "groups", :action => "created_post", :id => /\d+/, :page => /\d+/
  map.connect "/groups/commented_post/:id/:page", :controller => "groups", :action => "commented_post", :id => /\d+/, :page => /\d+/
  map.resources :groups, :member => {
    :edit_image => :get,
    :update_image => :post,
    
    :update_access => :post,
    
    :join => :post,
    :quit => :post,
    
    :del_member => :post,
    
    :add_admin => :post,
    :del_admin => :post,
    
    :approve_member => :post,
    :reject_member => :post,
    :approve_all => :post,
    
    :invite_member => :post,
    
    :edit_master => :get,
    :update_master => :post,
    
    :remove_activity => :post,
    :remove_vote => :post,
    
    :send_contact_invitations => :post
    
  }, :collection => {
    :photo_selector_for_group_image => :get,
    
    :all => :get
  }
  
  
  map.connect "/:post_type/posts/:id/comment/:page", :controller => "posts", :action => "show", :id => /\d+/, :page => /\d+/
  map.resources :posts, :path_prefix => "/:post_type", :member => {
    :create_comment => :post,
    :delete_comment => :post,
    
    :top => :post,
    :untop => :post,
    
    :good => :post,
    :ungood => :post,
    
    :new_attachment => :get,
    :create_attachment => :post,
    :delete_attachment => :post
  }
  map.connect "/:post_type/posts/:action/:id", :controller => "posts"
  
  
  map.connect "/activities/recent_index", :controller => "activities", :action => "recent_index"
  map.connect "/activities/list_group_index", :controller => "activities", :action => "list_group_index"
  map.connect "/activities/list_join/:id/:page", :controller => "activities", :action => "list_join", :id => /\d+/, :page => /\d+/
  map.connect "/activities/list_create/:id/:page", :controller => "activities", :action => "list_create", :id => /\d+/, :page => /\d+/
  map.connect "/activities/list_interest/:id/:page", :controller => "activities", :action => "list_interest", :id => /\d+/, :page => /\d+/
  map.connect "/activities/list_notbegin_join/:id/:page", :controller => "activities", :action => "list_notbegin_join", :id => /\d+/, :page => /\d+/
  map.connect "/activities/list_attend/:id/:page", :controller => "activities", :action => "list_attend", :id => /\d+/, :page => /\d+/
  map.connect "/activities/list_absent/:id/:page", :controller => "activities", :action => "list_absent", :id => /\d+/, :page => /\d+/
  map.connect "/activities/post/:id/:page", :controller => "activities", :action => "post", :id => /\d+/, :page => /\d+/
  map.connect "/activities/good_post/:id/:page", :controller => "activities", :action => "good_post", :id => /\d+/, :page => /\d+/
  map.connect "/activities/picture/:id/:page", :controller => "activities", :action => "picture", :id => /\d+/, :page => /\d+/
  map.connect "/activities/good_picture/:id/:page", :controller => "activities", :action => "good_picture", :id => /\d+/, :page => /\d+/
  map.connect "/activities/created_post/:id/:page", :controller => "activities", :action => "created_post", :id => /\d+/, :page => /\d+/
  map.connect "/activities/commented_post/:id/:page", :controller => "activities", :action => "commented_post", :id => /\d+/, :page => /\d+/
  map.connect "/activities/photo/:id/:page", :controller => "activities", :action => "photo", :id => /\d+/, :page => /\d+/
  map.connect "/activities/activity_groups/", :controller => "activities", :action => "activity_groups"
  map.connect "/activities/interest/:id/:page", :controller => "activities", :action => "interest", :id => /\d+/, :page => /\d+/
  map.connect "/activities/members/:id/:page", :controller => "activities", :action => "members", :id => /\d+/, :page => /\d+/
  map.connect "/activities/members_edit/:id/:page", :controller => "activities", :action => "members_edit", :id => /\d+/, :page => /\d+/
  map.connect "/activities/absent/:id/:page", :controller => "activities", :action => "absent", :id => /\d+/, :page => /\d+/
  map.connect "/activities/absent_edit/:id/:page", :controller => "activities", :action => "absent_edit", :id => /\d+/, :page => /\d+/
  map.connect "/activities/all/:page", :controller => "activities", :action => "all", :page => /\d+/
  map.connect "/activities/all_join_post/:id/:page", :controller => "activities", :action => "all_join_post", :id => /\d+/, :page => /\d+/
  map.connect "/activities/all_interest_post/:id/:page", :controller => "activities", :action => "all_interest_post", :id => /\d+/, :page => /\d+/
  map.connect "/activities/all_photo/:id/:page", :controller => "activities", :action => "all_photo", :id => /\d+/, :page => /\d+/
  map.connect "/activities/all_picture/:id/:page", :controller => "activities", :action => "all_picture", :id => /\d+/, :page => /\d+/
  map.connect "/activities/coming_day/:page", :controller => "activities", :action => "coming_day", :page => /\d+/
  map.connect "/activities/coming_week/:page", :controller => "activities", :action => "coming_week", :page => /\d+/
  map.connect "/activities/coming_month/:page", :controller => "activities", :action => "coming_month", :page => /\d+/
  map.connect "/activities/coming_half_year/:page", :controller => "activities", :action => "coming_half_year", :page => /\d+/
  map.connect "/activities/day/:date", :controller => "activities", :action => "day", :date => /\d\d\d\d\d\d\d\d/
  map.connect "/activities/day/:date/:page", :controller => "activities", :action => "day", :date => /\d\d\d\d\d\d\d\d/, :page => /\d+/
  map.connect "/activities/unapproved/:id/:page", :controller => "activities", :action => "unapproved", :id => /\d+/, :page => /\d+/
  map.connect "/activities/members_info/:id/:page", :controller => "activities", :action => "members_info", :id => /\d+/, :page => /\d+/
  map.resources :activities, :member => {
    :edit_image => :get,
    :update_image => :post,
    
    :update_desc => :post,
    :update_access => :post,
    
    :join => :post,
    :quit => :post,
    
    :add_interest => :post,
    
    :del_member => :post,
    
    :add_admin => :post,
    :del_admin => :post,
    
    :approve_member => :post,
    :reject_member => :post,
    
    :invite_member => :post,
    
    :edit_master => :get,
    :update_master => :post,
    
    :add_absent => :post,
    :del_absent => :post,
    
    :del_interest => :post,
    
    :check_profile => :any,
    
    :cancel => :post,
    :recover => :post,
    
    :send_contact_invitations => :post,
    
    :cache_point => :post
    
  }, :collection => {
    :new_in_groups => :post,
    
    :photo_selector_for_activity_image => :get,
    
    :all => :get,
    :coming_day => :get,
    :coming_week => :get,
    :coming_month => :get,
    :coming_half_year => :get
  }
  
  
  map.resources :linked_photos, :path_prefix => "/:linked_photo_type", :member => {
    :create_link => :post
  }, :collection => {
    :photo_selector_for_linked_photo => :get
  }
  map.connect "/:linked_photo_type/linked_photos/:action/:id", :controller => "linked_photos"
  
  
  map.connect "/recruitments/recruitment_type/:id/:page", :controller => "recruitments", :action => "recruitment_type", :id => /\d+/, :page => /\d+/
  map.resources :recruitments, :collection => {
    
    :tag => :get,
    
    :search => :get,
    
    :location => :get,
    
    :feed => :get
    
  }, :member => {
    
  }
  
  
  map.connect "/votes/list_group_index", :controller => "votes", :action => "list_group_index"
  map.connect "/votes/latest/:page", :controller => "votes", :action => "latest", :page => /\d+/
  map.connect "/votes/hotest/:page", :controller => "votes", :action => "hotest", :page => /\d+/
  map.connect "/votes/category/:id/:page", :controller => "votes", :action => "category", :id => /\d+/, :page => /\d+/
  map.connect "/votes/list/:id/:page", :controller => "votes", :action => "list", :id => /\d+/, :page => /\d+/
  map.resources :votes, :collection => {
    
    :latest => :get,
    :hotest => :get,
    
    :new_in_group => :post,
    
    :photo_selector_for_vote_image => :get
    
  }, :member => {
    
    :edit_image => :get,
    :update_image => :post,
    
    :edit_option => :get,
    :create_new_option => :post,
    :add_new_option => :get,
    :delete_others_option => :post,
    
    :create_comment => :post,
    :delete_comment => :post,
    
    :vote_to_option => :post,
    
    :clear_vote_record => :post,
    
    :invite_member => :post,
    
    :send_contact_invitations => :post
    
  }
  map.connect "/votes/:id/comment/:page", :controller => "votes", :action => "show", :id => /\d+/, :page => /\d+/
  map.connect "/votes/:id/:chart_type", :controller => "votes", :action => "show", :id => /\d+/
  map.connect "/votes/:id/:chart_type/comment/:page", :controller => "votes", :action => "show", :id => /\d+/, :page => /\d+/
  
  
  map.connect "/bookmarks/list_personal_index", :controller => "bookmarks", :action => "list_personal_index"
  map.connect "/bookmarks/list_group_index", :controller => "bookmarks", :action => "list_group_index"
  map.connect "/bookmarks/personal/:page", :controller => "bookmarks", :action => "personal", :page => /\d+/
  map.connect "/bookmarks/group/:page", :controller => "bookmarks", :action => "group", :page => /\d+/
  map.connect "/bookmarks/list_personal/:id/:page", :controller => "bookmarks", :action => "list_personal", :id => /\d+/, :page => /\d+/
  map.resources :bookmarks, :collection => {
    
    :personal => :get,
    :group => :get,
    
    :new_group_bookmark => :post,
    
    :inline_add_form => :any,
    :create_inline => :post
    
  }, :member => {
    
  }
  
  
  map.connect "/job_targets/list_closed/:id/:page", :controller => "job_targets", :action => "list_closed", :id => /\d+/, :page => /\d+/
  map.resources :job_targets, :collection => {
    
    :new_for_position => :any,
    
    :add_account_process => :post,
    :create_account_process => :post,
    :create_account_status => :post,
    
    :system_status => :get,
    :create_system_status => :post,
    
    :system_process => :get,
    :create_system_process => :post,
    
    :create_account_item => :post
    
  }, :member => {
    
    :add_steps => :post,
    
    :adjust_step_order => :post,
    :set_current_step => :post,
    :update_step_label => :post,
    :update_step_process => :post,
    :del_step => :post,
    :create_step => :post,
    :update_step_date => :post,
    :update_step_remind_date => :post,
    :update_step_status => :post,
    :close_target => :post,
    :open_target => :post,
    :star_target => :post,
    :unstar_target => :post,
    
    :status_update => :post,
    :status_destroy => :post,
    
    :process_update => :post,
    :process_destroy => :post,
    
    :account_job_item_update => :post,
    :account_job_item_destroy => :post,
    
    :edit_target_job_item => :get,
    :update_target_job_item => :post
    
  }
  
  
  map.connect "/:picture_type/pictures/image/:id/:style", :controller => "pictures", :action => "image", :id => /\d+/
  map.connect "/:picture_type/pictures/:id/comment/:page", :controller => "pictures", :action => "show", :id => /\d+/, :page => /\d+/
  map.resources :pictures, :path_prefix => "/:picture_type", :member => {
    
    :create_comment => :post,
    :delete_comment => :post,
    
    :top => :post,
    :untop => :post,
    
    :good => :post,
    :ungood => :post,
    
    :create_picture => :post,
    :create_picture_simple => :post
    
  }, :collection => {
    
  }
  map.connect "/:picture_type/pictures/:action/:id", :controller => "pictures"
  
  
  map.connect "/talks/p/:page.:format", :controller => "talks", :action => "index", :page => /\d+/
  map.connect "/talks/unpublished/p/:page", :controller => "talks", :action => "unpublished", :page => /\d+/
  map.connect "/talks/talker_index/p/:page", :controller => "talks", :action => "talker_index", :page => /\d+/
  map.connect "/talks/:id/comment/:page", :controller => "talks", :action => "show", :id => /\d+/, :page => /\d+/
  map.resources :talks, :collection => {
    
    :talker_index => :get,
    :talker_new => :get,
    :talker_create => :post,
    
    :unpublished => :get,
    
    :feed => :get,
    
    :auto_complete_for_job_tags => :post
    
  }, :member => {
    
    :create_comment => :post,
    :delete_comment => :post,
    
    :publish => :post,
    :cancel_publish => :post,
    
    :manage => :get,
    
    :add_reporter => :post,
    :del_reporter => :post,
    
    :add_talker => :post,
    :del_talker => :post,
    
    :add_question_category => :post,
    :del_question_category => :post,
    
    :question_category_edit => :get,
    :question_category_update => :post,
    
    :talker_edit => :get,
    :talker_update => :post,
    :talker_destroy => :post,
    
    :add_question => :post,
    
    :question_edit => :get,
    :question_update => :post,
    :question_destroy => :post,
    
    :answer_new => :get,
    :answer_create => :post,
    
    :answer_edit => :get,
    :answer_update => :post,
    :answer_destroy => :post,
    
    :select_job_item => :any,
    :add_job_item => :post,
    :del_job_item => :post,
    
    :job_tags => :get,
    :add_job_tag => :post,
    :del_job_tag => :post,
    
    :add_job_process => :post,
    :del_job_process => :post
    
  }
  
  
  map.connect "/:item_type/job_items/p/:page", :controller => "job_items", :action => "index", :page => /\d+/
  map.resources :job_items, :path_prefix => "/:item_type", :collection => {
    
    :search => :any
    
  }, :member => {
    
    :manage_company_industries => :get,
    :add_company_industry => :post,
    :del_company_industry => :post,
    
    :info => :get,
    :info_new => :get,
    :info_create => :post,
    :info_edit => :get,
    :info_update => :post,
    :info_destroy => :post,
    
    :manage_job_position_info_items => :get,
    :add_job_position_info_item => :post,
    :del_job_position_info_item => :post
    
  }
  
  
  map.connect "/job_infos/p/:page", :controller => "job_infos", :action => "index", :page => /\d+/
  map.resources :job_infos, :collection => {
    
    :search => :any,
    
    :categories => :get,
    :category_new => :get,
    :category_create => :post
    
  }, :member => {
    
    :category_edit => :get,
    :category_update => :post,
    :category_destroy => :post,
    
    :select_job_item => :any,
    :add_job_item => :post,
    :del_job_item => :post,
    
    :add_job_process => :post,
    :del_job_process => :post,
    
    :add_category => :post,
    :del_category => :post
    
  }
  
  
  map.connect "/exps/list/p/:page", :controller => "exps", :action => "list", :page => /\d+/
  map.resources :exps, :collection => {
    
    :list => :get,
    
    :company => :get,
    
    :search => :get,
    
    :feed => :get,
    
    :zz => :get
    
  }, :member => {
    
  }

  
  

  
  
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  map.root :controller => "index"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
