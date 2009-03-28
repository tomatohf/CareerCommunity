module RecruitmentVendor

  class Utomorrow
    include Singleton # use .instance() to return the single instance object
    include RecruitmentVendor::Base
    
    def source_name
      "大学明天"
    end
    
    def get_doc_from_url_for_utomorrow(url, handle)
      doc = get_doc_from_url(url, handle, choose_document_encoding(url))
      
      unless doc.nil?
        doc.search("//span[@style*=none]").remove
        doc.search("//font[@style*=0px]").remove
      end
      
      doc
    end
    
    def choose_document_encoding(url)
      is_url_bbs?(url) ? "GBK" : "UTF-8"
    end
    
    def root_url
      "http://www.utomorrow.com"
    end
    
    def url_job_prefix
      "http://www.utomorrow.com/job/"
    end
    
    def url_bbs_prefix
      "http://www.utomorrow.com/bbs/"
    end
    
    def list_url_job
      "http://www.utomorrow.com/job/search.php?a=a"
    end
    
    def list_url_bbs_fulltiime
      "http://www.utomorrow.com/bbs/forumdisplay.php?fid=56&filter=type&typeid=1"
    end
    
    def list_url_bbs_parttiime
      "http://www.utomorrow.com/bbs/forumdisplay.php?fid=56&filter=type&typeid=2"
    end
    
    def list_url_bbs_intern
      "http://www.utomorrow.com/bbs/forumdisplay.php?fid=56&filter=type&typeid=30"
    end
    
    
    
    def filter_match_rules
      super << {
        :all => [/utomorrow/i],
        :content => [/本帖最后由/]
      }
    end
    
    
    
    def get_new_links(start_page = 1, page_count = 1)
      new_links = {}
      
      # to be implemented
      
      new_links
    end
    
    def save_new_messages(start_page = 1, page_count = 1)
      [
        [list_url_job, {}],
        [list_url_bbs_parttiime, {:recruitment_type => Recruitment::Type_parttime}],
        [list_url_bbs_intern, {:recruitment_type => Recruitment::Type_parttime}],
        [list_url_bbs_fulltiime, {:recruitment_type => Recruitment::Type_fulltime}]
      ].each { |item|
        init_values = item[1]
        link = item[0]
        start_page.upto(start_page + page_count - 1) { |page|
          url = "#{link}&page=#{page}"
          gotten_new_links = get_utomorrow_new_links(url)
          
          existing_links = Recruitment.find(:all, :conditions => ["source_link in (?)", gotten_new_links.collect { |l| l[0] }]).collect { |r| r.source_link }
          non_existing_links = gotten_new_links.delete_if { |l| existing_links.include?(l[0]) }
          
          non_existing_links.each do |msg_link_info|
            puts "retrieving message from link: " + msg_link_info[0].inspect
            recruitment = get_recruitment(msg_link_info[0], init_values.merge(msg_link_info[1]))
            recruitment.save if recruitment
          end
        }
      }
    end
    
    def build_recruitment(link, init_values = {})
      doc = get_doc_from_url_for_utomorrow(link, true)
      
      return nil if doc.nil?
      
      r = Recruitment.new
      init_values.each_pair { |key, value| r.send("#{key}=", value) }
      
      # add the fixed attributes
      r.source_name = source_name
      r.source_link = link
      
      is_url_bbs?(link) ? construct_recruitment_from_url_bbs(doc, r) : construct_recruitment_from_url_job(doc, r)
    end
    
    def construct_recruitment_from_url_job(doc, recruitment)
      recruitment_content = nil
      
      tds_with_strong = doc.search("//td[strong]")
      tds_with_strong.each { |td|
        strong = td.at("strong")
        if strong.inner_html =~ /职位描述/im
          recruitment_content = td.at("span").inner_html
          break
        end
      }
      
      if recruitment_content && recruitment_content != "" && recruitment_content.size > 300
        recruitment.content = recruitment_content
        recruitment
      else
        nil
      end
    end
    
    def construct_recruitment_from_url_bbs(doc, recruitment)
      recruitment_content = nil
      
      content_closest_parent_div_list = doc.search("//div[@id^=postmessage_]")
      if content_closest_parent_div_list.size > 0
        container_td_list = content_closest_parent_div_list[0].search("//td")
        if container_td_list.size > 0
          recruitment_content = container_td_list[0].inner_html
        end
      end
      
      if recruitment_content && recruitment_content != "" && recruitment_content.size > 300
        recruitment.content = recruitment_content
        recruitment
      else
        nil
      end
    end
    
    def get_utomorrow_new_links(url)
      is_url_bbs?(url) ? get_utomorrow_new_links_from_url_bbs(url) : get_utomorrow_new_links_from_url_job(url)
    end
    
    def get_utomorrow_new_links_from_url_job(url)
      doc = get_doc_from_url_for_utomorrow(url, false)
      
      return [] if doc.nil?
      
      list_xpath = "//table[form[@id='searchlist']]"
      lists = doc.search(list_xpath)
      
      return [] if lists.size < 1
      
      tr_xpath = "//tr"
      
      rows = lists[0].search(tr_xpath)
      rows.select { |tr|
        tds = tr.search("/td")
        if tds.size >= 6
          first_td = tds[0]
          input_in_first_td = first_td.search("/input")
          input_in_first_td.size > 0
        else
          false
        end
      }.collect { |tr|
        
        tds = tr.search("/td")
        title_td = tds[0]
        location_td = tds[2]
        type_td = tds[3]
        publish_time_td = tds[5]

        title_a = title_td.at("a")

        init_values = {
          :title => title_a.inner_html,
          :location => location_td.inner_html,
          :recruitment_type => type_td.inner_html.gsub("实习", "兼职").gsub("家教", "兼职").gsub("兼职", Recruitment::Type_parttime),
          :publish_time => publish_time_td.inner_html
        }
        
        href = title_a["href"].strip
        
        href = (url_job_prefix + href) unless href[0, 4] == "http"
        
        [href, init_values]
      }.select { |link_info| link_info[0] =~ /job\/jobshow-\d*\.html$/ }
    end

    def get_utomorrow_new_links_from_url_bbs(url)
      doc = get_doc_from_url_for_utomorrow(url, false)
      
      return [] if doc.nil?
      
      list_xpath = "//table[@id='forum_56']"
      lists = doc.search(list_xpath)
      
      return [] if lists.size < 1
      
      tr_xpath = "/tbody/tr"
      
      rows = lists[0].search(tr_xpath)
      
      rows.collect { |tr|
        
        title_td = tr.at("th")
        author_and_date_td = tr.search("/td")[2]

        title_a = title_td.at("span/a")

        init_values = {
          :title => title_a.inner_html,
          :publish_time => author_and_date_td.at("em").inner_html
        }

        href = title_a["href"].strip

        
        href = (url_bbs_prefix + href) unless href[0, 4] == "http"
        
        [href, init_values]
      }.select { |link_info| link_info[0] =~ /viewthread.php\?tid=\d*/ }
    end
    
    
    def is_url_bbs?(link)
      link.include?("/bbs/")
    end
    
    
    
    private
    
    def test2
      test(list_url_bbs_fulltiime, {:recruitment_type => Recruitment::Type_fulltime})
    end
    
    def test1
      test(list_url_job, {})
    end
    
    def test(link, init_values)
      url = "#{link}&page=1"
      gotten_new_links = get_utomorrow_new_links(url)
      
      existing_links = Recruitment.find(:all, :conditions => ["source_link in (?)", gotten_new_links.collect { |l| l[0] }]).collect { |r| r.source_link }
      non_existing_links = gotten_new_links.delete_if { |l| existing_links.include?(l[0]) }
      
      non_existing_links[0..1].each do |msg_link_info|
        puts "retrieving message from link: " + msg_link_info[0].inspect
        recruitment = get_recruitment(msg_link_info[0], init_values.merge(msg_link_info[1]))
        puts recruitment.inspect
      end
    end

  end

end

