namespace :job_target do
  
  desc "send email for step reminding if it's configured"
  task :send_step_email_remind => :environment do
    steps = JobStep.find(
      :all,
      :conditions => ["remind_at = ?", Date.today],
      :include => [:account, :job_process, {:job_target => [:company, :job_position]}]
    )
    
    steps.each do |step|
      account = step.account
      
      process = step.job_process
      JobProcess.set_process_cache(process)
      
      target = step.job_target
      
      company = target.company
    	Company.set_company_cache(company)

    	position = target.job_position
    	JobPosition.set_position_cache(position)
      
      unless account.limited?
        begin
          Postman.deliver_step_email_remind(account, step, process, target, company, position)
        rescue
        end
      end
    end
  end
  
end


