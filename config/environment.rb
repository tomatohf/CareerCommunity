# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')



# added by Tomato
Using_Libmemcached = true

Cache_Store_Name, MemCache_Options = if Using_Libmemcached
  [
    :libmemcached_store,
    {
      :prefix_key => "community:",
      :default_ttl => 0
    }
  ]
else
  [
    :mem_cache_store,
    {
      :namespace => "community",
      :readonly => false
    }
  ]
end



Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.load_paths += %W( #{RAILS_ROOT}/app/sweepers )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :key => '_CareerCommunity_session',
    :secret => '5f6fe7958ee4a9f7f2e9f26de75c307a1f85ac96d29642bf11d5fd1feb7ef8f9e83d3a00298285850b5d75ed4cb2935f5ce058d5b24fd0ea12df6c361b3a6aa0',
    :expire_after => 60*15 # set the session expire time to 60 * 15 = 15 minutes
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # enable memcached to store sessions
  # config.action_controller.session_store = :mem_cache_store
  config.action_controller.session_store = Cache_Store_Name
  
  # enable memcached to store fragment cache
  # config.action_controller.fragment_cache_store = :mem_cache_store, "127.0.0.1", {}
  # config.cache_store = :mem_cache_store, "127.0.0.1", MemCache_Options
  config.cache_store = Cache_Store_Name, "127.0.0.1", MemCache_Options

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
end



# added by Tomato
# in seconds
Cache_TTL = 1.day.to_i
