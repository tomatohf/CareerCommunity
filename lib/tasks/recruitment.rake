namespace :recruitment do
  
  desc "collect all new recruitment messages"
  task :collect_all_new_messages => :environment do
    messages = Recruitment.collect_new_messages.values.flatten
    puts messages.inspect
  end
  
end