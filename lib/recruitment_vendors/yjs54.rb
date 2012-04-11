module RecruitmentVendor

  class Yjs54
    include Singleton # use .instance() to return the single instance object
    include RecruitmentVendor::Base
    
    def source_name
      "我是应届生"
    end
    
    def root_url
      "http://www.54yjs.cn"
    end
    
    def list_url_fulltime
      "http://www.54yjs.cn/xyzp/?"
    end
    
    def list_url_parttime
      "http://www.54yjs.cn/sx/?"
    end
    
    def list_url_lecture
      "http://www.54yjs.cn/xjh/?"
    end
    
    
    
    def before_filter_replace_match_rules
      super << {
        :content => [
          Proc.new { |match, match_data|
            href = match_data[1]
            text = match_data[2]
            if href.downcase.include?("54yjs")
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
    
    
    
    def get_new_links(start_page = 1, page_count = 1)
      new_links = {}
      
      new_links
    end

    def save_new_messages(start_page = 1, page_count = 1)
      [
        [list_url_lecture, Recruitment::Type_lecture],
        [list_url_parttime, Recruitment::Type_parttime],
        [list_url_fulltime, Recruitment::Type_fulltime]
      ].each { |item|
        init_values = { :recruitment_type => item[1] }
        link = item[0]
        start_page.upto(start_page + page_count - 1) { |page|
          url = "#{link}&page=#{page}"
          gotten_new_links = get_yjs54_new_links(url)
          
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
    end
    
    def build_info_obj(link, init_values = {})
      doc = get_doc_from_url(link, true)
      
      return nil if doc.nil?
      
      r = Recruitment.new
      init_values.each_pair { |key, value| r.send("#{key}=", value) }
      
      h1 = doc.search("//div[@class=bodys]/h1")
      return nil unless h1.size > 0
      r.title = h1[0].inner_html
      
      fubiaoti = doc.search("//div[@class=fubiaoti]")
      return nil unless fubiaoti.size > 0
      datetimes = fubiaoti.to_s.scan(/\d{4}-\d{1,2}-\d{1,2}/)
      r.publish_time = if datetimes.size > 0
        DateTime.parse(datetimes[0])
      else
        DateTime.now
      end
      spans = fubiaoti.search("/span/a")
      if spans.size > 0
        r.location = spans[0].inner_html      
        tag_text = []
        spans[1..-1].each { |span| tag_text << span.inner_html }
        tag_text.uniq!
        tag_text.each { |tag| r.recruitment_tags << RecruitmentTag.get_tag(tag) if tag && (tag.strip != "") }
      end
      
      bodys2 = doc.search("//div[@class=bodys2]")
      return nil unless bodys2.size > 0
      bodys2.search("/div").remove
      r.content = bodys2.to_s
      return nil if r.content.blank?
      
      # add the fixed attributes
      r.source_name = source_name
      r.source_link = link
      
      r
    end
    
    def get_yjs54_new_links(url)
      doc = get_doc_from_url(url, false)
      
      return [] if doc.nil?
      
      doc.search(
        url.include?("xjh") ? "//div[@class=chakan]/a" : "//div[@class=danwei]/a"
      ).collect { |a|
        href = a["href"].strip
        root_url + href unless href[0, 4] == "http"
      }.select { |href| href =~ /\d+\.html$/ }
    end
    
  end
  
end


