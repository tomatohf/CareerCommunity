module ExpVendor

  class Mianjing51
    include Singleton # use .instance() to return the single instance object
    include ExpVendor::Base
    
    def source_name
      "面经网"
    end
    
    def root_url
      "http://www.51mianjing.cn"
    end
    
    def list_url_1
      "http://www.51mianjing.cn/class.asp?id=2"
    end
    
    def list_url_2
      "http://www.51mianjing.cn/class.asp?id=17"
    end
    
    def urls(link, start_page = 1, page_count = 1)
      u = []
      start_page.upto(start_page + page_count - 1) { |page|
        u << page_url(link, page)
      }
      u
    end
    
    def page_url(link, page)
      "#{link}&page=#{page}"
    end
    
    
    
    def before_filter_replace_match_rules
      super << {
        :content => [
          Proc.new { |match, match_data|
            href = match_data[1]
            text = match_data[2]
            if href.downcase.include?("51mianjing")
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
      
      #super << {
      #  :all => [/hiall/i]
      #}
      
      super
    end
    
    
    
    def save_new_messages(start_page = 1, page_count = 1)
      [
        list_url_1,
        list_url_2
      ].each { |item|
        link = item
        urls(link, start_page, page_count).each { |url|
          gotten_new_links = get_mianjing51_new_links(url)
          
          existing_links = Exp.find(:all, :conditions => ["source_link in (?)", gotten_new_links]).collect { |e| e.source_link }
          non_existing_links = gotten_new_links.delete_if { |l| existing_links.include?(l) }
          
          non_existing_links.each do |msg_link|
            puts "retrieving message from link: " + msg_link.inspect
            exp = get_info_obj(msg_link)
            exp.save if exp
          end
        }
      }
    end
    
    def get_mianjing51_new_links(url)
      doc = get_doc_from_url(url, false)
      
      return [] if doc.nil?
      
      doc.search("//li[@class='titlesa']").collect { |li|
        li_a = li.search("/a")
        li_a.size > 0 ? (root_url + "/" + li_a[0]["href"].strip) : nil
      }.compact
    end
    
    def build_info_obj(link, init_values = {})
      doc = get_doc_from_url(link, true)
      
      return nil if doc.nil?
      
      exp = Exp.new
      init_values.each_pair { |key, value| exp.send("#{key}=", value) }
      

      content_xpath = "//div[@id='news']"
      content_div = doc.search(content_xpath)
      
      h1 = content_div.search("/h1")[0]
      exp.title = h1.inner_html
      
      the_times = content_div.search("/div[@class='times']")[0].inner_html.scan(/\d\d\d\d-\d{1,2}-\d{1,2} \d{1,2}:\d{1,2}/)
      exp.publish_time = the_times.size > 0 ? the_times[0] : DateTime.now
      
      
      text_div = content_div.search("//div[@id='textbody']")[0]
      divs_in_text = text_div.search("/div")
      if (divs_in_text.size > 3)
        divs_in_text[3].search("").remove
        divs_in_text[2].search("").remove
      end
      
      text_tags_in_text_div = text_div.search("/div[@class='text_tag']")
      text_tags_in_text_div[0].search("").remove if text_tags_in_text_div.size > 0
      
      text_notes_in_text_div = text_div.search("/div[@class='note']")
      text_notes_in_text_div[0].search("").remove if text_notes_in_text_div.size > 0
      
      exp.content = text_div.inner_html
      
      
      # add the fixed attributes
      exp.source_name = source_name
      exp.source_link = link
      
      exp
      
    end
    
  end
  
end


