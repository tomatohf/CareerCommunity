module RecruitmentVendor

  class Yingjiesheng
    include Singleton # use .instance() to return the single instance object
    include RecruitmentVendor::Base
    
    def source_name
      "应届生"
    end
    
    def root_url
      "http://yingjiesheng.com"
    end
    
    def list_url_fulltime
      "http://yingjiesheng.com/commend_job/fulltime_1.html"
    end
    
    def list_url_parttime
      "http://yingjiesheng.com/commend_job/parttime_1.html"
    end
    
    def list_url_lecture
      ""
    end
    
    def list_url_jobfair
      ""
    end
    
    def urls(link, start_page = 1, page_count = 1)
      u = []
      start_page.upto(start_page + page_count - 1) { |page|
        u << if link.include?("fulltime")
          fulltime_page_url(link, page)
        elsif link.include?("parttime")
          parttime_page_url(link, page)
        else
          page_url(link, page)
        end
      }
      u
    end
    
    def fulltime_page_url(link, page)
      link.gsub("fulltime_1", "fulltime_#{page}")
    end
    
    def parttime_page_url(link, page)
      link.gsub("parttime_1", "parttime_#{page}")
    end
    
    def page_url(link, page)
      ""
    end
    
    
    
    def before_filter_replace_match_rules
      super << {
        :content => [
          Proc.new { |match, match_data|
            href = match_data[1]
            text = match_data[2]
            if href.downcase.include?("yingjiesheng")
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
    
    
    
    def get_new_links(start_page = 1, page_count = 1)
      new_links = {}
      [
        [list_url_parttime, Recruitment::Type_parttime],
        [list_url_fulltime, Recruitment::Type_fulltime]
      ].each { |item|
        init_values = { :recruitment_type => item[1] }
        link = item[0]
        new_links.merge!(
          urls(link, start_page, page_count).collect { |url|
            get_maiwo_new_links(url)
          }.flatten.to_hash_keys{
            init_values
          }
        )
      }
      
      new_links
    end

    def save_new_messages(start_page = 1, page_count = 1)
      # adjust since yingjiesheng has fewer items per page
      adjusted_page_count = page_count * 7
      
      [
        [list_url_parttime, Recruitment::Type_parttime],
        [list_url_fulltime, Recruitment::Type_fulltime]
      ].each { |item|
        init_values = { :recruitment_type => item[1] }
        link = item[0]
        urls(link, start_page, adjusted_page_count).each { |url|
          gotten_new_links = get_maiwo_new_links(url)
          
          existing_links = Recruitment.find(:all, :conditions => ["source_link in (?)", gotten_new_links]).collect { |r| r.source_link }
          non_existing_links = gotten_new_links.delete_if { |l| existing_links.include?(l) }
          
          non_existing_links.each do |msg_link|
            puts "retrieving message from link: " + msg_link.inspect
            recruitment = get_recruitment(msg_link, init_values)
            recruitment.save if recruitment
          end
        }
      }
    end
    
    def get_maiwo_new_links(url)
      doc = get_doc_from_url(url, false)
      
      return [] if doc.nil?
      
      doc.search("//div[@class='job_item']").collect { |div|
        left_divs = div.search("//div[@class='left']")
        left_divs.size > 0 ? (root_url + left_divs[0].search("//a")[0]["href"].strip) : nil
      }.compact
    end
    
    def build_recruitment(link, init_values = {})
      doc = get_doc_from_url(link, true)
      
      return nil if doc.nil?
      
      r = Recruitment.new
      init_values.each_pair { |key, value| r.send("#{key}=", value) }
      

      content_xpath = "//div[@id='item_content']"
      content_div = doc.search(content_xpath)
      
      center = content_div.search("/center")[0]
      center_html = center.inner_html;
      the_times = center_html.scan(/\d\d\d\d-\d{1,2}-\d{1,2} \d{1,2}:\d{1,2}/)
      r.publish_time = the_times.size > 0 ? the_times[0] : DateTime.now
      
      title_elements = content_div.search("//h1")
      if title_elements.size > 0
        h1_element = title_elements[0]
        
        r.title = h1_element.inner_html
        
        h1_element.search("").remove
      end
      
      r.content = content_div.search("//div[@id='contentadad']")[0].inner_html
      
      
      # add the fixed attributes
      r.source_name = source_name
      r.source_link = link
      
      
      # tags
      tag_div = doc.search("//div[@class='tag']")
      tag_text = tag_div.search("//a").collect { |tag_a| tag_a.inner_html }
      tag_text.uniq!
      tag_text.each { |tag| r.recruitment_tags << RecruitmentTag.get_tag(tag) if tag && (tag.strip != "") }
      
      r
      
    end
    
  end
  
end


