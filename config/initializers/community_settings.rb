# enable UTF-8 support
require 'jcode'
$KCODE = 'u'

# require "i18n"

##################################################
### END
##################################################





##################################################
### require gem files
##################################################

require "digest/sha1"

require "date"

require "paperclip"

require "mime/types"

require "will_paginate"

require "hpricot"
Hpricot.buffer_size = 131072 # 16384 bytes (16k) default. increase to 128K here.
require "open-uri"

require "select_with_include"

require "RMagick"

require "pathname"
require "fileutils"

require "iconv"

require "xmpp4r-simple"

require "system_timer"

require "redcloth"

##################################################
### END
##################################################





##################################################
### require middlewares
##################################################



##################################################
### END
##################################################





##################################################
### require lib files
##################################################

require "util"
require "noisy_image"

require "recruitment_vendors/base"

require "contact"

require "exp_vendors/base"

require "goal_follow_types/base"

require_dependency "career_tests/base"

##################################################
### END
##################################################





##################################################
### SMTP setting for email sending
##################################################

require "smtp_tls"

ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_charset = "utf-8"

ActionMailer::Base.raise_delivery_errors = true
# setting for Gmail
#ActionMailer::Base.smtp_settings = {
#  :address => "smtp.gmail.com",
#  :port => "587",
#  :authentication => :plain,
#  :user_name => "votingchina",
#  :password => "***REMOVED***"
#}

# setting for localhost smtp
# ActionMailer::Base.smtp_settings = {
#   #:address =>  "localhost",
#   :address =>  "qiaobutang.com",
#   :domain =>  "qiaobutang.com",
#   :authentication => :plain,
#   :user_name => "noreply@qiaobutang.com",
#   :password => "***REMOVED***"
# }

# setting for QQ exmail smtp
ActionMailer::Base.smtp_settings = {
  :address =>  "smtp.exmail.qq.com",
  :domain =>  "qiaobutang.com",
  :authentication => :plain,
  :user_name => "noreply@qiaobutang.com",
  :password => "***REMOVED***"
}

# within Rails 2.3.3 a bug within the ActionMailer was introduced.
# You can see the ticket over here Ticket #2340
# It's resolved in 2-3-stable and master so it will be fixed in 3.x and 2.3.6.
# For fixing the problem within 2.3.* you can use the code provided within the ticket comments:
module ActionMailer
  class Base
    def perform_delivery_smtp(mail)
      destinations = mail.destinations
      mail.ready_to_send
      sender = (mail['return-path'] && mail['return-path'].spec) || Array(mail.from).first

      smtp = Net::SMTP.new(smtp_settings[:address], smtp_settings[:port])
      smtp.enable_starttls_auto if smtp_settings[:enable_starttls_auto] && smtp.respond_to?(:enable_starttls_auto)
      smtp.start(
        smtp_settings[:domain],
        smtp_settings[:user_name],
        smtp_settings[:password],
        smtp_settings[:authentication]
      ) do |smtp|
        smtp.sendmail(mail.encoded, sender, destinations)
      end
    end
  end
end

##################################################
### END
##################################################
