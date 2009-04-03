namespace :exp do
  
  desc "save all collected new exp messages"
  task :save_all_new_messages => :environment do
    Exp.save_new_messages(ENV["start_page"].to_i, ENV["page_count"].to_i)
  end
  
  desc "save collected new exp messages of one vendor"
  task :save_new_messages_of_one_vendor => :environment do
    Exp.save_new_messages_of_one_vendor(ENV["vendor"], ENV["start_page"].to_i, ENV["page_count"].to_i)
  end
  
end


