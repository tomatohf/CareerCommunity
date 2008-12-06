require "msn/msn"

module CareerCommunity
  
  module Contact
    
    module InstanceMethods
    
      private
    
      def default_wait_time
        10
      end
    
      def default_wait_step
        1
      end
      
      def default_timeout_seconds
        30.seconds
      end
    
      def fetch_msn_contacts(user_id, user_pwd)
        wait_time = 20
        wait_step = 2
        timeout_seconds = 40.seconds
      
        contacts = []
        
        SystemTimer.timeout(timeout_seconds) do
          msn = MSNConnection.new(user_id, user_pwd)
          msn.start
          
          # it seems msn requires lots of time to update contact list ...
          sleep 10

          contact_list = wait_collect_contacts(wait_time, wait_step) { msn.contactlists["AL"].list }
      
          contacts = contact_list.values.collect { |contact| [contact.email, CGI.unescape(contact.nick || get_name_from_email(contact.email))] }
      
          msn.close
        end
      
        contacts
      end
    
      def fetch_gtalk_contacts(user_id, user_pwd)
        user_mail = "#{user_id}@gmail.com"
        
        contacts = []
        
        SystemTimer.timeout(default_timeout_seconds) do
          gtalk = Jabber::Simple.new(user_mail, user_pwd)
        
          roster_items = wait_collect_contacts { gtalk.roster.items.values }
      
          contacts = roster_items.collect { |item| [(jid = item.jid.strip.to_s), item.iname || get_name_from_email(jid)] }
      
          gtalk.disconnect
        end
      
        contacts
      end
    
    
      def wait_collect_contacts(wait_time = nil, wait_step = nil)
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
    
      def get_name_from_email(email)
        email.split("@")[0]
      end
    
    end
    
  end
  
end


