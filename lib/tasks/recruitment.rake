namespace :recruitment do
  
  # desc "collect all new recruitment messages"
  # task :collect_all_new_messages => :environment do
  #   messages = Recruitment.collect_new_messages(ENV["start_page"].to_i, ENV["page_count"].to_i).values.flatten
  #   puts messages.inspect
  # end
  
  desc "save all collected new recruitment messages"
  task :save_all_new_messages => :environment do
    Recruitment.save_new_messages(ENV["start_page"].to_i, ENV["page_count"].to_i)
  end
  
  desc "save collected new recruitment messages of one vendor"
  task :save_new_messages_of_one_vendor => :environment do
    Recruitment.save_new_messages_of_one_vendor(ENV["vendor"], ENV["start_page"].to_i, ENV["page_count"].to_i)
  end
  
end


