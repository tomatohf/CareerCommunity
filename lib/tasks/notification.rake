namespace :notification do
  
  desc "send email for reminding if there is any new course application"
  task :send_course_application_notification => :environment do
    sa = ServiceApplication.get_to_be_notified_service_applications
    
    if sa.size > 0
      Postman.deliver_course_application_remind(sa)
      ServiceApplication.clear_to_be_notified_service_applications_cache
    end
  end
  
  
end


