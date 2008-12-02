namespace :notification do
  
  desc "send email for reminding if there is any new course application"
  task :send_course_application_notification => :environment do
    sa = ServiceApplication.get_to_be_notified_service_applications
    
    if sa.size > 0
      Postman.deliver_course_application_remind(sa)
      ServiceApplication.clear_to_be_notified_service_applications_cache
    end
  end
  
  
  desc "send email for reminding if there is any unread message"
  task :send_message_notification => :environment do
    s = Date.today
    e = 1.days.since(s)
    
    msgs = Message.find(
      :all,
      :select => "id, receiver_id, created_at, has_read, count(id) as count",
      :conditions => ["has_read = ? and created_at > ? and created_at < ?", false, s, e],
      :include => [:receiver => [:setting]],
      :group => "receiver_id"
    )
    
    sys_msgs = SysMessage.find(
      :all,
      :select => "id, account_id, created_at, has_read, count(id) as count",
      :conditions => ["has_read = ? and created_at > ? and created_at < ?", false, s, e],
      :include => [:account => [:setting]],
      :group => "account_id"
    )
    
    accounts = {}
    msg_counts = {}
    sys_msg_counts = {}
    
    account_ids = msgs.collect { |m|
      account_id = m.receiver_id
      accounts[account_id] = m.receiver
      msg_counts[account_id] = m.count.to_i
      account_id
    } + sys_msgs.collect { |m|
      account_id = m.account_id
      accounts[account_id] = m.account
      sys_msg_counts[account_id] = m.count.to_i
      account_id
    }.uniq
    
    account_ids.each do |account_id|
      account = accounts[account_id]
      msg_count = msg_counts[account_id] || 0
      sys_msg_count = sys_msg_counts[account_id] || 0
      
      setting = account.setting
      AccountSetting.set_account_setting_cache(account.id, setting)
      
      if !account.limited? && setting.get_setting_value(:email_message_notify) == "true" && (msg_count + sys_msg_count > 0)
        begin
          Postman.deliver_message_remind(account, msg_count, sys_msg_count)
        rescue
        end
      end
    end
    
  end
  
  
end


