namespace :job_target do
  
  desc "send email for step reminding if it's configured"
  task :send_step_email_remind => :environment do
    steps = JobStep.find(
      :all,
      :conditions => ["remind_at = ?", Date.today],
      :include => [:account, :job_target, :job_target]
    )
  end
  
end


