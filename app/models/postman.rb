class Postman < ActionMailer::Base
  
  def self.source
    "乔布堂"
  end
  
  def self.from
    "#{source} <noreply@qiaobutang.com>"
  end
  
  def self.host
    "qiaobutang.com"
  end
  
  # this method is only for test uasage
  def test(other = "")
    recipients(["Tomato.HF@gmail.com"])
    from(self.class.from)
    subject("Hello 用户")
    body(:content => "This is for test ~~ 和一些中文 ... !!\n#{other}")
  end
  
  def register_confirmation(account)
    # email header info MUST be added here
    recipients(account.email)
    from(self.class.from)
    subject("#{self.class.source} 注册确认")

    # email body substitutions go here
    body(:nick => account.get_nick, :source => self.class.source, :uid => account.id, :key => account.get_key, :host => self.class.host)
  end
  
  def password_remind(account)
    recipients(account.email)
    from(self.class.from)
    subject("#{self.class.source} 密码提醒")

    body(:nick => account.get_nick, :source => self.class.source, :password => account.password, :host => self.class.host)
  end
  
end
