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
      "http://my.yingjiesheng.com/index.php/personal/xjhinfo.htm"
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
        elsif link.include?("xjhinfo")
          lecture_page_url(link, page)
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
    
    def lecture_page_url(link, page)
      "#{link}/?page=#{page}"
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
            get_yingjiesheng_new_links(url)
          }.flatten.to_hash_keys{
            init_values
          }
        )
      }
      
      new_links
    end

    def save_new_messages(start_page = 1, page_count = 1)
      [
        [list_url_parttime, Recruitment::Type_parttime],
        [list_url_fulltime, Recruitment::Type_fulltime]
      ].each { |item|
        init_values = { :recruitment_type => item[1] }
        link = item[0]
        urls(link, start_page, page_count).each { |url|
          gotten_new_links = get_yingjiesheng_new_links(url)
          
          existing_links = Recruitment.find(
            :all, 
            :select => "source_link", 
            :conditions => ["source_link in (?)", gotten_new_links]
          ).collect { |r| r.source_link }
          non_existing_links = gotten_new_links.delete_if { |l| existing_links.include?(l) }
          
          non_existing_links.each do |msg_link|
            puts "retrieving message from link: " + msg_link.inspect
            recruitment = get_info_obj(msg_link, init_values)
            recruitment.save if recruitment
          end
        }
      }
      
      # handle lecture, since it's different with other recruitment type
      urls(list_url_lecture, start_page, page_count).each { |url|
        gotten_new_links = get_yingjiesheng_lecture_new_links(url)
        
        existing_links = Recruitment.find(
          :all, 
          :select => "source_link", 
          :conditions => ["source_link in (?)", gotten_new_links]
        ).collect { |r| r.source_link }
        non_existing_links = gotten_new_links.delete_if { |l| existing_links.include?(l) }
        
        non_existing_links.each do |msg_link|
          puts "retrieving message from link: " + msg_link.inspect
          recruitment = get_info_obj(msg_link, { :recruitment_type => Recruitment::Type_lecture })
          recruitment.save if recruitment
        end
      }
    end
    
    def get_yingjiesheng_new_links(url)
      doc = get_doc_from_url(url, false)
      
      return [] if doc.nil?
      
      list_xpath = "//div[@class='jobList']/table"
      lists = doc.search(list_xpath)
      
      return [] if lists.size < 1
      
      trs = lists[0].search("//tr")
      trs.collect { |tr|
        link = nil
        tds = tr.search("//td")
        
        if tds.size > 0
          td = tds[0]
          
          as = td.search("//a")
          
          if as.size > 0
            a = as[0]
            
            href = (a["href"] || "").strip
            href = (root_url + href) unless (href[0, 4] == "http")

            link = href if href =~ /jobshow_\d+.html/i
          end
        end
        
        link
      }.compact
    end
    
    def get_yingjiesheng_lecture_new_links(url)
      doc = get_doc_from_url(url, false)
      
      return [] if doc.nil?
      
      list_xpath = "//table[@class='campusTalk']"
      tables = doc.search(list_xpath)
      
      return [] unless tables.size > 1
      
      # remove table header row
      tables.delete_at(0)
      
      tables.collect { |table|
        
        trs = table.search("//tr")
        
        trs.collect { |tr|
          link = nil
          tds = tr.search("//td")

          if tds.size > 5
            td = tds[5]

            as = td.search("//a")

            if as.size > 0
              a = as[0]

              href = (a["href"] || "").strip
              href = (root_url + href) unless (href[0, 4] == "http")

              link = href if href =~ /jobshow_\d+.html/i
            end
          end

          link
        }
        
      }.flatten.compact
    end
    
    def build_info_obj(link, init_values = {})
      doc = get_doc_from_url(link, true)
      
      return nil if doc.nil?
      
      r = Recruitment.new
      init_values.each_pair { |key, value| r.send("#{key}=", value) }
      

      content_xpath = "//div[@class='jobDetails']"
      job_details = doc.search(content_xpath)
      
      return nil unless job_details.size > 0
      
      content_div = job_details[0]
      
      h3s = content_div.search("/h3[@class='jobTitle']")
      
      return nil unless h3s.size > 0
      
      h3 = h3s[0]
      
      date_span = h3.search("/span[@class='memo']")[0]
      
      the_times = date_span.inner_html.scan(/\d\d\d\d-\d{1,2}-\d{1,2}/)
      r.publish_time = the_times.size > 0 ? the_times[0] : DateTime.now
      
      date_span.search("").remove
      
      r.title = h3.inner_html.strip
      
      
      info_div = content_div.search("/div[@class='basicInfo']")[0]
      info_lis = info_div.search("//li")
      location_li = info_lis[0]
      location_label = location_li.search("/strong")[0]
      location_label.search("").remove
      location_text = location_li.inner_html.strip || ""
      r.location = location_text.split(/\s/)[0]
      
      job_name_li = info_lis[1]
      job_name = job_name_li.search("/span[@class='jobName']")[0].inner_html
      
      
      content_container = content_div.search("//div[@class='jobContent']")[0].search("/span/div")[0]
      
      content_ps = content_container.search("/p")
      if content_ps.size > 0
        content_ps.delete_if { |p|
          as = p.search("/a")
          (as.size == 1) && (as[0]["href"].nil? || as[0]["href"].include?("yingjiesheng"))
        }
      
        r.content = content_ps.collect{ |p| p.to_html }.join("\n")
      else
        content_tables = content_container.search("/div[@id='job_txt']")
        
        if content_tables.size > 0
          r.content = content_tables[0].inner_html
        end
      end
      
      return nil unless r.content && r.content.strip != ""
      
      
      # add the fixed attributes
      r.source_name = source_name
      r.source_link = link
      
      
      # tags
      tag_text = job_name.split(/\s|、/)
      tag_text.uniq!
      tag_text.each { |tag| r.recruitment_tags << RecruitmentTag.get_tag(tag) if tag && (tag.strip != "") }
      
      r
      
    end
    
  end
  
end


