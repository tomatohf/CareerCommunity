class Postman < ActionMailer::Base
  
  helper :application
  
  
  def self.source
    "乔布堂"
  end
  
  def self.from
    "#{source} <noreply@qiaobutang.com>"
  end
  
  def self.host
    "http://qiaobutang.com"
  end
  
  # this method is only for test uasage
  def test(other = "")
    recipients(
      [
        "Tomato.HF@gmail.com",
        "Tomato_HF@hotmail.com"
      ]
    )
    from(self.class.from)
    subject("Hello 娃哈哈")
    body(:content => "This is for test ~~ 和一些中文 ... !!\n#{other}")
    content_type "text/html"
  end
  
  def register_confirmation(account)
    # email header info MUST be added here
    recipients(account.email)
    from(self.class.from)
    subject("#{self.class.source} 注册确认")

    # email body substitutions go here
    body(:nick => account.get_nick, :source => self.class.source, :uid => account.id, :key => account.get_key, :host => self.class.host)
    content_type "text/html"
  end
  
  def password_remind(account)
    recipients(account.email)
    from(self.class.from)
    subject("#{self.class.source} 密码提醒")

    body(:nick => account.get_nick, :source => self.class.source, :password => account.password, :host => self.class.host)
    content_type "text/html"
  end
  
  
  def course_application_remind(course_applications)
    recipients(
      [
        "Tomato.HF@gmail.com",
        "hefan@qiaobutang.com",
        "shenkai@qiaobutang.com",
        "rick@qiaobutang.com"
      ]
    )
    
    from(self.class.from)
    subject("[#{DateTime.now.strftime("%Y-%m-%d")}] 有 #{course_applications.size} 个需要回应的报名课程/咨询详情的记录")
    body(:course_applications => course_applications)
  end
  
  def message_remind(account, msg_count, sys_msg_count)
    recipients(
      [
        account.email
      ]
    )
    
    from(self.class.from)
    subject("[乔布圈] 你有 #{msg_count + sys_msg_count} 条未读消息")
    body(:nick => account.get_nick, :account_id => account.id, :msg_count => msg_count, :sys_msg_count => sys_msg_count)
    content_type "text/html"
  end
  
  def group_invitation(account, invitor_account, group, invitation_words)
    recipients(
      [
        account.email
      ]
    )
    
    from(self.class.from)
    
    invitor_nick = invitor_account.get_nick
    group_name = group.name
    subject("#{invitor_nick} 邀请你加入圈子 #{group_name}")
    body(
      :nick => account.get_nick,
      :account_id => account.id,
      :invitor_nick => invitor_nick,
      :invitor_account_id => invitor_account.id,
      :group => group,
      :invitation_words => invitation_words
    )
    content_type "text/html"
  end
  
  def activity_invitation(account, invitor_account, activity, invitation_words)
    recipients(
      [
        account.email
      ]
    )
    
    from(self.class.from)
    
    invitor_nick = invitor_account.get_nick
    activity_title = activity.get_title
    subject("#{invitor_nick} 邀请你参加活动 #{activity_title}")
    body(
      :nick => account.get_nick,
      :account_id => account.id,
      :invitor_nick => invitor_nick,
      :invitor_account_id => invitor_account.id,
      :activity => activity,
      :invitation_words => invitation_words
    )
    content_type "text/html"
  end
  
  def vote_invitation(account, invitor_account, vote_topic, invitation_words)
    recipients(
      [
        account.email
      ]
    )
    
    from(self.class.from)
    
    invitor_nick = invitor_account.get_nick
    vote_topic_title = vote_topic.title
    vote_topic_category = VoteCategory.get_category(vote_topic.category_id)
    subject("[#{vote_topic_category}] #{invitor_nick} 邀请你参与投票 #{vote_topic_title}")
    body(
      :nick => account.get_nick,
      :account_id => account.id,
      :invitor_nick => invitor_nick,
      :invitor_account_id => invitor_account.id,
      :vote_topic => vote_topic,
      :vote_options => VoteOption.get_vote_topic_options(vote_topic.id),
      :invitation_words => invitation_words
    )
    content_type "text/html"
  end
  
  def activity_contact_invitation(email, invitor_account, activity, invitation_words)
    recipients(
      [
        email
      ]
    )
    
    from(self.class.from)
    
    invitor_nick = invitor_account.get_nick
    activity_title = activity.get_title
    subject("#{invitor_nick} 邀请你参加活动 #{activity_title}")
    body(
      :invitor_nick => invitor_nick,
      :invitor_account_id => invitor_account.id,
      :activity => activity,
      :invitation_words => invitation_words
    )
    content_type "text/html"
  end
  
  def group_contact_invitation(email, invitor_account, group, invitation_words)
    recipients(
      [
        email
      ]
    )
    
    from(self.class.from)
    
    invitor_nick = invitor_account.get_nick
    group_name = group.name
    subject("#{invitor_nick} 邀请你加入圈子 #{group_name}")
    body(
      :invitor_nick => invitor_nick,
      :invitor_account_id => invitor_account.id,
      :group => group,
      :invitation_words => invitation_words
    )
    content_type "text/html"
  end
  
  def vote_contact_invitation(email, invitor_account, vote_topic, invitation_words)
    recipients(
      [
        email
      ]
    )
    
    from(self.class.from)
    
    invitor_nick = invitor_account.get_nick
    vote_topic_title = vote_topic.title
    vote_topic_category = VoteCategory.get_category(vote_topic.category_id)
    subject("[#{vote_topic_category}] #{invitor_nick} 邀请你参与投票 #{vote_topic_title}")
    body(
      :invitor_nick => invitor_nick,
      :invitor_account_id => invitor_account.id,
      :vote_topic => vote_topic,
      :vote_options => VoteOption.get_vote_topic_options(vote_topic.id),
      :invitation_words => invitation_words
    )
    content_type "text/html"
  end
  
end
