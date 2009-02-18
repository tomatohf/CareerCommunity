namespace :counter do
  
  desc "set cache view counter values to db"
  task :update_view_counter_db => :environment do
    ViewCounter.get_expired_view_counters.each do |kind, ids|
      ids.each do |id|
        ViewCounter.set_db_count(kind, id)
      end
    end
    
    ViewCounter.clear_expired_view_counters_cache
  end
  
end


