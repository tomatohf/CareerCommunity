require "msn/msn"

module CareerCommunity
  
  module Contact
    
    private
    
    def default_wait_time
      10
    end
    
    def default_wait_step
      1
    end
    
    def fetch_msn_contacts(user_id, user_pwd, wait_time = nil, wait_step = nil)
      
    end
    
    def fetch_gtalk_contacts(user_id, user_pwd, wait_time = nil, wait_step = nil)
      user_mail = "#{user_id}@gmail.com"
      
      gtalk = Jabber::Simple.new(user_mail, user_pwd)
      
      roster_items = wait_collect_contacts(wait_time, wait_step) { gtalk.roster.items.values }
      
      contacts = roster_items.collect { |item| [(jid = item.jid.strip.to_s), item.iname || jid.split("@")[0]] }
      
      gtalk.disconnect
      
      contacts
    end
    
    
    def wait_collect_contacts(wait_time, wait_step)
      seconds = 0
      contacts = []
      contacts_in_last = []
      while seconds < (wait_time || default_wait_time) &&
            ((contacts = yield).size <= 0 || contacts.size > contacts_in_last.size)
        contacts_in_last = contacts

        step = wait_step || default_wait_step
        seconds += step
        sleep step
      end
      
      contacts
    end
    
  end
  
end


