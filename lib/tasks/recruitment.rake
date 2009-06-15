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
  
  
  
  desc "archive old/out recruitments and their related data(relationship db records)"
  task :archive_old_recruitments => :environment do
    created_at_threshold = Date.parse(ENV["created_at"]) rescue nil
    
    return unless created_at_threshold
    
    old_recruitments = Recruitment.find(
      :all,
      :conditions => ["created_at < ?", created_at_threshold],
      :include => [:recruitment_tags, :companies, :job_positions]
    )
    old_recruitments.each do |r|
      rid = r.id
      
      puts "BEGIN archive recruitment #{rid}"
      
      puts "... ... begin archive recruitment #{rid}"
      # archive recruitments
      archived_recruitment = ArchivedRecruitment.find_or_initialize_by_id(rid)
      archived_recruitment.attributes = {
        :id => rid,
        
        :title => r.title,
        :content => r.content,

        :publish_time => r.publish_time,
        :location => r.location,
        :recruitment_type => r.recruitment_type,

        :source_name => r.source_name,
        :source_link => r.source_link,

        :active => r.active,

        :created_at => r.created_at,
        :updated_at => r.updated_at,

        :account_id => r.account_id,

        :delta => r.delta
      }
      archived_recruitment.save!
      
      puts "... ... begin archive recruitment #{rid} tags"
      # archive recruitments and tags relationship
      r.recruitment_tags.each do |tag|
        archived_recruitment_tags = archived_recruitment.recruitment_tags
        archived_recruitment_tags << tag unless archived_recruitment_tags.exists?(tag)
      end
      
      puts "... ... begin archive recruitment #{rid} companies"
      # archive recruitments and companies relationship
      r.companies.each do |company|
        archived_recruitment_companies = archived_recruitment.companies
        archived_recruitment_companies << company unless archived_recruitment_companies.exists?(company)
      end
      
      puts "... ... begin archive recruitment #{rid} job_positions"
      # archive recruitments and job_positions relationship
      r.job_positions.each do |job_position|
        archived_recruitment_job_positions = archived_recruitment.job_positions
        archived_recruitment_job_positions << job_position unless archived_recruitment_job_positions.exists?(job_position)
      end
      
      # destroy recruitment with its relationship data
      r.destroy
      
      puts "END archive recruitment #{rid}"
    end
  end
  
end


