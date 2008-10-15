ActionController::Routing::Routes.draw do |map|
  
  # map.connect "/community/search/:scope/:query", :controller => "community", :action => "search"
    
  map.resources :accounts, :collection => {
  
    :send_register_confirmation => :get,
    
    :login_form => :get,
    :login => :post,
    
    :logout => :any,
    
    :forgot_password => :get,
    :send_password => :post
    
  }, :member => {
  
    :register_confirmation => :get,
    
    :update_password => :post
  
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
  
  
  map.connect "/photos/show_edit/:id/comment/:page", :controller => "photos", :action => "show_edit", :id => /\d+/, :page => /\d+/
  map.connect "/photos/:id/comment/:page", :controller => "photos", :action => "show", :id => /\d+/, :page => /\d+/
  map.resources :photos, :member => {
    :create_comment => :post,
    
    :move_to_other_album => :post
  }
  
  
  map.connect "/blogs/list/:id/:page", :controller => "blogs", :action => "list", :id => /\d+/, :page => /\d+/
  map.connect "/blogs/show_edit/:id/comment/:page", :controller => "blogs", :action => "show_edit", :id => /\d+/, :page => /\d+/
  map.connect "/blogs/:id/comment/:page", :controller => "blogs", :action => "show", :id => /\d+/, :page => /\d+/
  map.resources :blogs, :member => {
    :create_comment => :post
  }
  
  
  map.connect "/spaces/wall_edit/:id/:page", :controller => "spaces", :action => "wall_edit", :id => /\d+/, :page => /\d+/
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
  
  
  map.connect "/groups/list_edit/:id/:page", :controller => "groups", :action => "list_edit", :id => /\d+/, :page => /\d+/
  map.connect "/groups/list/:id/:page", :controller => "groups", :action => "list", :id => /\d+/, :page => /\d+/
  map.connect "/groups/list_admin_edit/:id/:page", :controller => "groups", :action => "list_admin_edit", :id => /\d+/, :page => /\d+/
  map.connect "/groups/list_admin/:id/:page", :controller => "groups", :action => "list_admin", :id => /\d+/, :page => /\d+/
  map.connect "/groups/all/:page", :controller => "groups", :action => "all", :page => /\d+/
  map.connect "/groups/members/:id/:page", :controller => "groups", :action => "members", :id => /\d+/, :page => /\d+/
  map.connect "/groups/members_edit/:id/:page", :controller => "groups", :action => "members_edit", :id => /\d+/, :page => /\d+/
  map.connect "/groups/members_master/:id/:page", :controller => "groups", :action => "members_master", :id => /\d+/, :page => /\d+/
  map.connect "/groups/unapproved/:id/:page", :controller => "groups", :action => "unapproved", :id => /\d+/, :page => /\d+/
  map.connect "/groups/post/:id/:page", :controller => "groups", :action => "post", :id => /\d+/, :page => /\d+/
  map.connect "/groups/activity/:id/:page", :controller => "groups", :action => "activity", :id => /\d+/, :page => /\d+/
  map.connect "/groups/photo/:id/:page", :controller => "groups", :action => "photo", :id => /\d+/, :page => /\d+/
  map.connect "/groups/all_post/:id/:page", :controller => "groups", :action => "all_post", :id => /\d+/, :page => /\d+/
  map.connect "/groups/all_activity/:id/:page", :controller => "groups", :action => "all_activity", :id => /\d+/, :page => /\d+/
  map.connect "/groups/all_photo/:id/:page", :controller => "groups", :action => "all_photo", :id => /\d+/, :page => /\d+/
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
    :update_master => :post
  }, :collection => {
    :photo_selector_for_group_image => :get,
    
    :all => :get
  }
  
  
  map.connect "/:post_type/posts/:id/comment/:page", :controller => "posts", :action => "show", :id => /\d+/, :page => /\d+/
  map.resources :posts, :path_prefix => "/:post_type", :member => {
    :create_comment => :post,
    :delete_comment => :post,
    
    :top => :post,
    :untop => :post
  }
  map.connect "/:post_type/posts/:action/:id", :controller => "posts"
  
  
  map.connect "/activities/recent_index", :controller => "activities", :action => "recent_index"
  map.connect "/activities/list_join_edit/:id/:page", :controller => "activities", :action => "list_join_edit", :id => /\d+/, :page => /\d+/
  map.connect "/activities/list_join/:id/:page", :controller => "activities", :action => "list_join", :id => /\d+/, :page => /\d+/
  map.connect "/activities/list_create_edit/:id/:page", :controller => "activities", :action => "list_create_edit", :id => /\d+/, :page => /\d+/
  map.connect "/activities/list_create/:id/:page", :controller => "activities", :action => "list_create", :id => /\d+/, :page => /\d+/
  map.connect "/activities/list_interest_edit/:id/:page", :controller => "activities", :action => "list_interest_edit", :id => /\d+/, :page => /\d+/
  map.connect "/activities/list_interest/:id/:page", :controller => "activities", :action => "list_interest", :id => /\d+/, :page => /\d+/
  map.connect "/activities/list_notbegin_join_edit/:id/:page", :controller => "activities", :action => "list_notbegin_join_edit", :id => /\d+/, :page => /\d+/
  map.connect "/activities/list_notbegin_join/:id/:page", :controller => "activities", :action => "list_notbegin_join", :id => /\d+/, :page => /\d+/
  map.connect "/activities/list_attend/:id/:page", :controller => "activities", :action => "list_attend", :id => /\d+/, :page => /\d+/
  map.connect "/activities/list_absent/:id/:page", :controller => "activities", :action => "list_absent", :id => /\d+/, :page => /\d+/
  map.connect "/activities/post/:id/:page", :controller => "activities", :action => "post", :id => /\d+/, :page => /\d+/
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
    
    :approve_member => :post,
    :reject_member => :post,
    
    :invite_member => :post,
    
    :add_absent => :post,
    :del_absent => :post,
    
    :del_interest => :post,
    
    :check_profile => :any
    
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
  
  
  map.connect "/recruitments/p/:page", :controller => "recruitments", :action => "index", :page => /\d+/
  map.resources :recruitments, :collection => {
    
    :tag => :get,
    :location => :get,
    :recruitment_type => :get
    
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
