namespace :notification do
  
  desc "send email for reminding if there is any new course application"
  task :send_course_application_notification => :environment do
    sa = ServiceApplication.get_to_be_notified_service_applications
    ServiceApplication.clear_to_be_notified_service_applications_cache
    
    if sa.size > 0
      sa.sort! { |x, y| x.service_id <=> y.service_id }
      
      group_value = sa.first.service_id
      groups = []
      group = []
      
      sa.each do |a|
        if a.service_id != group_value
          groups << group
          
          group = []
          group_value = a.service_id
        end
        
        group << a
      end
      
      groups << group
      
      groups.each do |g|
        begin
          Postman.deliver_course_application_remind(g) if g.size > 0
        rescue
        end
      end
      
    end
  end
  
  
  desc "send group invitation emails"
  task :send_group_invitations => :environment do
    invitations = Group.get_group_invitations
    Group.clear_group_invitations_cache
    
    invitations.each do |invitation|
      begin
        group_id = invitation[:group_id]
        invitor_account_id = invitation[:invitor_account_id]
        invited_account_ids = invitation[:invited_account_ids]
        invitation_words = invitation[:invitation_words]
      
        group, group_image = Group.get_group_with_image(group_id)
        invitor_account = Account.find_enabled(invitor_account_id)
        
        if invitor_account
          invited_accounts = Account.enabled.find(
            :all,
            :conditions => ["id in (?)", invited_account_ids],
            :include => [:setting]
          )
          
          invited_accounts.each do |invited_account|
            setting = invited_account.setting
            AccountSetting.set_account_setting_cache(invited_account.id, setting)

            if !invited_account.limited? && setting.get_setting_value(:email_group_invitation_notify) == "true"
              Postman.deliver_group_invitation(invited_account, invitor_account, group, invitation_words)
            end
          end
        end
      rescue
      end
    end
  end
  
  desc "send activity invitation emails"
  task :send_activity_invitations => :environment do
    invitations = Activity.get_activity_invitations
    Activity.clear_activity_invitations_cache
    
    invitations.each do |invitation|
      begin
        activity_id = invitation[:activity_id]
        invitor_account_id = invitation[:invitor_account_id]
        invited_account_ids = invitation[:invited_account_ids]
        invitation_words = invitation[:invitation_words]
      
        activity, activity_image = Activity.get_activity_with_image(activity_id)
        invitor_account = Account.find_enabled(invitor_account_id)
        
        if invitor_account
          invited_accounts = Account.enabled.find(
            :all,
            :conditions => ["id in (?)", invited_account_ids],
            :include => [:setting]
          )
          
          invited_accounts.each do |invited_account|
            setting = invited_account.setting
            AccountSetting.set_account_setting_cache(invited_account.id, setting)

            if !invited_account.limited? && setting.get_setting_value(:email_activity_invitation_notify) == "true"
              Postman.deliver_activity_invitation(invited_account, invitor_account, activity, invitation_words)
            end
          end
        end
      rescue
      end
    end
  end
  
  desc "send vote invitation emails"
  task :send_vote_invitations => :environment do
    invitations = VoteTopic.get_vote_invitations
    VoteTopic.clear_vote_invitations_cache
    
    invitations.each do |invitation|
      begin
        vote_topic_id = invitation[:vote_topic_id]
        invitor_account_id = invitation[:invitor_account_id]
        invited_account_ids = invitation[:invited_account_ids]
        invitation_words = invitation[:invitation_words]
      
        vote_topic, vote_image = VoteTopic.get_vote_topic_with_image(vote_topic_id)
        invitor_account = Account.find_enabled(invitor_account_id)
        
        if invitor_account
          invited_accounts = Account.enabled.find(
            :all,
            :conditions => ["id in (?)", invited_account_ids],
            :include => [:setting]
          )
          
          invited_accounts.each do |invited_account|
            setting = invited_account.setting
            AccountSetting.set_account_setting_cache(invited_account.id, setting)

            if !invited_account.limited? && setting.get_setting_value(:email_vote_invitation_notify) == "true"
              puts "send vote invitation mail to #{invited_account.email} ..."
              Postman.deliver_vote_invitation(invited_account, invitor_account, vote_topic, invitation_words)
            end
          end
        end
      rescue
      end
    end
  end
  
  
  desc "send activity contact invitation emails"
  task :send_activity_contact_invitations => :environment do
    invitations = Activity.get_activity_contact_invitations
    Activity.clear_activity_contact_invitations_cache
    
    invitations.each do |invitation|
      begin
        activity_id = invitation[:activity_id]
        invitor_account_id = invitation[:invitor_account_id]
        invited_emails = invitation[:invited_emails]
        invitation_words = invitation[:invitation_words]
      
        activity, activity_image = Activity.get_activity_with_image(activity_id)
        invitor_account = Account.find_enabled(invitor_account_id)
        
        if invitor_account
          invited_emails.each do |email|
            puts "send activity contact invitation mail to #{email} ..."
            Postman.deliver_activity_contact_invitation(email, invitor_account, activity, invitation_words)
          end
        end
      rescue
      end
    end
  end
  
  
  desc "send group contact invitation emails"
  task :send_group_contact_invitations => :environment do
    invitations = Group.get_group_contact_invitations
    Group.clear_group_contact_invitations_cache
    
    invitations.each do |invitation|
      begin
        group_id = invitation[:group_id]
        invitor_account_id = invitation[:invitor_account_id]
        invited_emails = invitation[:invited_emails]
        invitation_words = invitation[:invitation_words]
      
        group, group_image = Group.get_group_with_image(group_id)
        invitor_account = Account.find_enabled(invitor_account_id)
        
        if invitor_account
          invited_emails.each do |email|
            puts "send group contact invitation mail to #{email} ..."
            Postman.deliver_group_contact_invitation(email, invitor_account, group, invitation_words)
          end
        end
      rescue
      end
    end
  end
  
  
  desc "send vote contact invitation emails"
  task :send_vote_contact_invitations => :environment do
    invitations = VoteTopic.get_vote_contact_invitations
    VoteTopic.clear_vote_contact_invitations_cache
    
    invitations.each do |invitation|
      begin
        vote_topic_id = invitation[:vote_topic_id]
        invitor_account_id = invitation[:invitor_account_id]
        invited_emails = invitation[:invited_emails]
        invitation_words = invitation[:invitation_words]
      
        vote_topic, vote_image = VoteTopic.get_vote_topic_with_image(vote_topic_id)
        invitor_account = Account.find_enabled(invitor_account_id)
        
        if invitor_account
          invited_emails.each do |email|
            puts "send vote contact invitation mail to #{email} ..."
            Postman.deliver_vote_contact_invitation(email, invitor_account, vote_topic, invitation_words)
          end
        end
      rescue
      end
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
  
  
  desc "send problem group notification emails"
  task :send_problem_group_notifications => :environment do
    notifications = GroupPost.get_problem_group_notifications
    GroupPost.clear_problem_group_notifications

    notifications.each do |notification|
      begin
        post_id = notification[:post_id]
        poster_id = notification[:poster_id]
        post_title = notification[:post_title]
        observers_id = notification[:observers_id]

        poster = Account.find_enabled(poster_id)

        if poster
          observers = Account.enabled.find(
            :all,
            :conditions => ["id in (?)", observers_id]
          )

          observers.each do |observer|
            Postman.deliver_problem_group_notification(poster, observer, post_id, post_title)
          end
        end
      rescue
      end
    end
  end
  
  
end


