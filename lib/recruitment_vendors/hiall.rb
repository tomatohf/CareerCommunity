module RecruitmentVendor

  class Hiall
    include Singleton # use .instance() to return the single instance object
    include RecruitmentVendor::Base
    
    def source_name
      "Hiall"
    end
    
    def root_url
      "http://hiall.com.cn"
    end
    
    def list_url_fulltime
      "http://hiall.com.cn/hiall_home/m.php?name=hr&mo_catid=1"
    end
    
    def list_url_fulltime_important
      "http://hiall.com.cn/hiall_home/m.php?name=hr&mo_catid=9"
    end
    
    def list_url_parttime
      "http://hiall.com.cn/hiall_home/m.php?name=hr&mo_catid=2"
    end
    
    def list_url_lecture
      "http://hiall.com.cn/hiall_home/m.php?name=hr&mo_catid=3"
    end
    
    def urls(link, start_page = 1, page_count = 1)
      u = []
      start_page.upto(start_page + page_count - 1) { |page|
        u << "#{link}&page=#{page}"
      }
      u
    end
    
    
    
    def before_filter_replace_match_rules
      super << {
        :content => [
          Proc.new { |match, match_data|
            href = match_data[1]
            text = match_data[2]
            if href.downcase.include?("hiall")
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
        [list_url_fulltime, Recruitment::Type_fulltime],
        [list_url_fulltime_important, Recruitment::Type_fulltime],
        # [list_url_lecture, Recruitment::Type_lecture], # disable to retrieve lecture messages
        [list_url_parttime, Recruitment::Type_parttime]
      ].each { |item|
        init_values = { :recruitment_type => item[1] }
        link = item[0]
        new_links.merge!(
          urls(link, start_page, page_count).collect { |url|
            get_hiall_new_links(url)
          }.flatten.to_hash_keys{
            init_values
          }
        )
      }
      
      new_links
    end

    def save_new_messages(start_page = 1, page_count = 1)
      [
        [list_url_fulltime, Recruitment::Type_fulltime],
        [list_url_fulltime_important, Recruitment::Type_fulltime],
        # [list_url_lecture, Recruitment::Type_lecture], # disable to retrieve lecture messages
        [list_url_parttime, Recruitment::Type_parttime]
      ].each { |item|
        init_values = { :recruitment_type => item[1] }
        link = item[0]
        start_page.upto(start_page + page_count - 1) { |page|
          url = "#{link}&page=#{page}"
          gotten_new_links = get_hiall_new_links(url)
          
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
    
    def build_recruitment(link, init_values = {})
      doc = get_doc_from_url(link, true)
      
      return nil if doc.nil?
      
      r = Recruitment.new
      init_values.each_pair { |key, value| r.send("#{key}=", value) }
      
      content_xpath = "//div[@class='models-articletitle']"
      content_div = doc.search(content_xpath)
      
      title_elements = content_div.search("/h1")
      if title_elements.size > 0
        h1_element = title_elements[0]
        
        h1_sub_div_elements = h1_element.search("//div")
        r.title = h1_sub_div_elements[0].inner_html if h1_sub_div_elements.size > 0
        
        h1_element.search("").remove
      end
      
      tag_text = []
      info_exp = /^.*?<a.*?>.*?<\/a>\s*$/im
      
      p_elements = content_div.search("/p")
      p_elements.select { |p|
        p_inner_html = p.inner_html
        p_inner_html && p_inner_html.size < 300 && p_inner_html =~ info_exp
      }.each{ |p|
        p.search("/a").each { |a| tag_text << a.inner_html }
        p.search("").remove
      }
      
      r.content = content_div.to_html
      
      info_xpath = "//div[@class='models-minfield']"
      info_div = doc.search(info_xpath)
      
      info_div.search("/ul/li").each{ |li|
        li_content = li.inner_html
        case li_content
          when /.*?工作地区.*/im
            locations = []
            li.search("/a").each{ |a|
              locations << a.inner_html unless a.inner_html =~ /^\s*$/im
            }
            
            # only use the first the location
            # r.location = locations.join(" ")
            r.location = locations[0] if (locations.size > 0)
          when /.*?发布时间.*?\d{4}-\d{1,2}-\d{1,2}.*/im
            publish_time = li.inner_html.scan(/\d{4}-\d{1,2}-\d{1,2}/)[0]
            r.publish_time = DateTime.parse(publish_time) unless publish_time.nil?
          else
            li.search("/a").each { |a| tag_text << a.inner_html }
        end
      }
      
      # add the fixed attributes
      r.source_name = source_name
      r.source_link = link
      
      # tags
      tag_text.uniq!
      tag_text.each { |tag| r.recruitment_tags << RecruitmentTag.get_tag(tag) if tag && (tag.strip != "") }
      
      r
      
    end
    
    def get_hiall_new_links(url)
      doc = get_doc_from_url(url, false)
      
      return [] if doc.nil?
      
      list_xpath = "//div[@class='models-articlelist no_top_bg']"
      lists = doc.search(list_xpath)
      
      return [] if lists.size < 1
      
      p_xpath = "/div[@class='models-article']/div[@class='models-articlelistinfo']/p[@class='title']"
      
      paragraphs = lists[0].search(p_xpath)
      paragraphs.collect { |p|
        p.search("//a").collect{|a| 
          href = a["href"].strip
          href += "/" if href[-1, 1] != "/"
          href = (root_url + href) unless href[0, 4] == "http"
          
          href
        }.select { |href| href =~ /action-model-name-hr-itemid-\d*/ }
      }.flatten
      
    end
    
  end
  
end


