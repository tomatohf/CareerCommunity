module ExpVendor

  class Esojob
    include Singleton # use .instance() to return the single instance object
    include ExpVendor::Base
    
    def source_name
      "面经e网"
    end
    
    def root_url
      "http://www.esojob.com"
    end
    
    def list_url_1
      "http://www.esojob.com/b/b.asp?B=1006"
    end
    
    def list_url_2
      "http://www.esojob.com/b/b.asp?B=1030"
    end
    
    def urls(link, start_page = 1, page_count = 1)
      u = []
      start_page.upto(start_page + page_count - 1) { |page|
        u << page_url(link, page)
      }
      u
    end
    
    def page_url(link, page)
      page > 1 ? "#{link}&r=4264&Upflag=0&p=0&q=#{page-1}" : link
    end
    
    
    
    def before_filter_replace_match_rules
      super << {
        :content => [
          Proc.new { |match, match_data|
            href = match_data[1]
            text = match_data[2]
            if href.downcase.include?("esojob")
              # should disable the link
              text
            else
              # do not change
              match_data[0]
            end
          }, 
          /<a.*?href="(.*?)".*?>(.*?)<\/a>/im
        ]
      }
    end
    
    def filter_match_rules
      # the sample of how to override this method
      
      super << {
        :all => [/esojob\.com/i]
      }
    end
    
    
    
    def save_new_messages(start_page = 1, page_count = 1)
      [
        list_url_1,
        list_url_2
      ].each { |item|
        link = item
        urls(link, start_page, page_count).each { |url|
          gotten_new_links_info = get_esojob_new_links(url).build_hash { |info| [info[0], info[1]] }
          gotten_new_links = gotten_new_links_info.keys
          
          existing_links = Exp.find(
            :all, 
            :select => "source_link", 
            :conditions => ["source_link in (?)", gotten_new_links]
          ).collect { |e| e.source_link }
          non_existing_links = gotten_new_links.delete_if { |l| existing_links.include?(l) }
          
          non_existing_links.each do |msg_link|
            puts "retrieving message from link: " + msg_link.inspect
            exp = get_info_obj(msg_link, {:title => gotten_new_links_info[msg_link]})
            exp.save if exp
          end
        }
      }
    end
    
    def get_esojob_new_links(url)
      doc = get_doc_from_url(url, false)
      
      return [] if doc.nil?
      
      doc.search("//tr[@class='TBBG9']").collect { |tr|
        link = nil
        
        tds = tr.search("/td")
        if tds.size > 2
          td = tds[1]
          
          as = td.search("/a")
          if as.size > 0
            a = as[0]
            href =  a["href"] && a["href"].strip
            if href && href =~ /a\.asp\?B=\d+&ID=\d+/
              link = [root_url + href[2..-1], a.inner_html]
            end
          end
        end
        
        link
      }.compact
    end
    
    def build_info_obj(link, init_values = {})
      doc = get_doc_from_url(link, true)
      
      return nil if doc.nil?
      
      exp = Exp.new
      init_values.each_pair { |key, value| exp.send("#{key}=", value) }
      

      content_xpath = "//span[@id^='Content']"
      content_span = doc.search(content_xpath)[0]
      
      exp.content = content_span.inner_html
      
      
      first_publish_time = doc.to_s.scan(/发表\s\d\d\d\d-\d{1,2}-\d{1,2} \d{1,2}:\d{1,2}/)[0]
      the_times = first_publish_time.scan(/\d\d\d\d-\d{1,2}-\d{1,2} \d{1,2}:\d{1,2}/)
      exp.publish_time = the_times.size > 0 ? the_times[0] : DateTime.now
      
      
      
      
      # add the fixed attributes
      exp.source_name = source_name
      exp.source_link = link
      
      
      return nil if exp.content.nil? || (exp.content.size < 500)
      
      exp
      
    end
    
  end
  
end


