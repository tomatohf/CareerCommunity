set :application, "CareerCommunity"
set :repository,  "http://www.votingchina.com:800/svn/votechina/trunk/CareerCommunity"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"
set :deploy_to, "/home/tomato/websites/app/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :subversion

role :app, "qiaobutang.com"
role :web, "qiaobutang.com"
role :db,  "qiaobutang.com", :primary => true


set :user, "tomato"
set :password, "!t0m@t0#"

set :svn_username, "tomato"
set :svn_password, "!t0m@t0#"

set :use_sudo, false

set :rails_env, "production"



desc "fix permissions" 
task :after_update_code do
  run "find #{release_path}/public -type d -exec chmod 0755 {} \\;"
  run "find #{release_path}/public -type f -exec chmod 0644 {} \\;"
  run "chmod 0755 #{release_path}/public/dispatch.*"
end
