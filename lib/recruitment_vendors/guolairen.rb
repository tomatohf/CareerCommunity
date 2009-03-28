module RecruitmentVendor

  class Guolairen
    include Singleton # use .instance() to return the single instance object
    include RecruitmentVendor::Base
    
    def source_name
      "过来人"
    end
    
    def root_url
      "http://www.guolairen.com"
    end
    
    def list_url_fulltime
      "http://job.guolairen.com"
    end
    
    def list_url_parttime
      "http://intern.guolairen.com"
    end
    
    def list_url_lecture
      "http://meeting.guolairen.com"
    end
    
    def list_url_jobfair
      "http://jobfair.guolairen.com"
    end
    
    def urls(link, start_page = 1, page_count = 1)
      u = []
      start_page.upto(start_page + page_count - 1) { |page|
        u << link.include?("meeting") ? lecture_page_url(link, page) : page_url(link, page)
      }
      u
    end
    
    def page_url(link, page)
      "#{link}/archive_list_#{page}.html"
    end
    
    def lecture_page_url(link, page)
      "#{link}/index_#{page}.html"
    end
    
    
    
    def before_filter_replace_match_rules
      super << {
        :content => [
          Proc.new { |match, match_data|
            href = match_data[1]
            text = match_data[2]
            if href.downcase.include?("guolairen")
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
        [list_url_fulltime, Recruitment::Type_fulltime],
        [list_url_lecture, Recruitment::Type_lecture],
        [list_url_jobfair, Recruitment::Type_jobfair]
      ].each { |item|
        init_values = { :recruitment_type => item[1] }
        link = item[0]
        new_links.merge!(
          urls(link, start_page, page_count).collect { |url|
            get_guolairen_new_links(url)
          }.flatten.to_hash { |link_info|
            [link_info.keys[0], init_values.merge({:publish_time => link_info.values[0]})]
          }
        )
      }
      
      new_links
    end

    def save_new_messages(start_page = 1, page_count = 1)
      # adjust since guolairen has fewer items per page
      adjusted_page_count = page_count * 2
      
      [
        [list_url_parttime, Recruitment::Type_parttime],
        [list_url_fulltime, Recruitment::Type_fulltime],
        [list_url_jobfair, Recruitment::Type_jobfair]
      ].each { |item|
        init_values = { :recruitment_type => item[1] }
        link = item[0]
        start_page.upto(start_page + adjusted_page_count - 1) { |page|
          url = page_url(link, page)
          gotten_new_link_infos = get_guolairen_new_links(url).to_hash { |link_info|
            [link_info.keys[0], link_info.values[0]]
          }
          gotten_new_links = gotten_new_link_infos.keys
          
          existing_links = Recruitment.find(:all, :conditions => ["source_link in (?)", gotten_new_links]).collect { |r| r.source_link }
          non_existing_links = gotten_new_links.delete_if { |l| existing_links.include?(l) }
          
          non_existing_links.each do |msg_link|
            puts "retrieving message from link: " + msg_link.inspect
            recruitment = get_recruitment(msg_link, init_values.merge({:publish_time => gotten_new_link_infos[msg_link]}))
            recruitment.save if recruitment
          end
        }
      }
      
      
      # handle lecture, since it's different with other recruitment type
      start_page.upto(start_page + page_count - 1) { |page|
        url = lecture_page_url(list_url_lecture, page)
        gotten_new_links = get_guolairen_lecture_new_links(url)
        
        existing_links = Recruitment.find(:all, :conditions => ["source_link in (?)", gotten_new_links]).collect { |r| r.source_link }
        non_existing_links = gotten_new_links.delete_if { |l| existing_links.include?(l) }
        
        non_existing_links.each do |msg_link|
          puts "retrieving message from link: " + msg_link.inspect
          recruitment = get_recruitment(msg_link, { :recruitment_type => Recruitment::Type_lecture })
          recruitment.save if recruitment
        end
      }
    end
    
    def get_guolairen_new_links(url)
      doc = get_doc_from_url(url, false, "UTF-8")
      
      return [] if doc.nil?
      
      list_xpath = "//div[@class='main_list']"
      lists = doc.search(list_xpath)
      
      return [] if lists.size < 1
      
      li_xpath = "/ul/li"
      
      lis = lists[0].search(li_xpath)
      lis.collect { |li|
        {
          li.search("//a")[0]["href"].strip => li.search("//span")[0].inner_html
        }
      }
    end
    
    def get_guolairen_lecture_new_links(url)
      doc = get_doc_from_url(url, false, "UTF-8")
      
      return [] if doc.nil?
      
      list_xpath = "//table[@class='bluelink2']"
      lists = doc.search(list_xpath)
      
      return [] if lists.size < 1
      
      tr_xpath = "//tr"
      
      trs = lists[0].search(tr_xpath)
      trs.delete_at(0)
      trs.collect { |tr|
        as = tr.search("//td")[5].search("//a")
        as.size > 0 ? as[0]["href"].strip : nil
      }.compact
    end
    
    def build_recruitment(link, init_values = {})
      doc = get_doc_from_url(link, true, "UTF-8")
      
      return nil if doc.nil?
      
      r = Recruitment.new
      init_values.each_pair { |key, value| r.send("#{key}=", value) }
      
      r.publish_time ||= DateTime.now
      
      
      content_xpath = "//div[@class='article']"
      content_div = doc.search(content_xpath)
      
      title_elements = content_div.search("/h2")
      if title_elements.size > 0
        h2_element = title_elements[0]
        
        r.title = h2_element.inner_html
        
        h2_element.search("").remove
      end
      
      r.content = content_div.search("//div[@class='paginate_content']")[0].inner_html
      
      
      # add the fixed attributes
      r.source_name = source_name
      r.source_link = link
      
      
      # tags
      tag_span = doc.search("//span[@class='fright color_orange']")
      tag_text = tag_span.search("//a").collect { |tag_a| tag_a.inner_html }
      tag_text.uniq!
      tag_text.delete_at(0) if tag_text.size > 1
      tag_text.each { |tag| r.recruitment_tags << RecruitmentTag.get_tag(tag) if tag && (tag.strip != "") }
      
      r
      
    end
    
  end
  
end


