namespace :code do
  
  desc "send the test purpose mail"
  task :send_mail => :environment do
    Postman.deliver_test("I'm sent from Rake task !!!")
    puts "test mail has been sent ..."
  end
  
end