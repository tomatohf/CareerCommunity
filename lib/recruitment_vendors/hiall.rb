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
    
    # how many pages will be checked to retrieve new links
    def page_count
      1
    end
    
    def urls(link)
      u = []
      1.upto(page_count) { |page|
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
      super << {
        :all => [/hiall/i]
      }
    end
    
    
    
    def get_new_links
      new_links = {}
      [
        [list_url_fulltime, "全职"],
        [list_url_fulltime_important, "全职"],
        # [list_url_lecture, "宣讲会"], # disable to retrieve lecture messages
        [list_url_parttime, "兼职"]
      ].each{ |item|
        init_values = { :type => item[1] }
        link = item[0]
        new_links.merge!(
          urls(link).collect { |url|
            get_hiall_new_links(url)
          }.flatten.to_hash_keys{
            init_values
          }
        )
      }
      new_links
    end
    
    def build_recruitment(link, init_values = {})
      doc = get_doc_from_url(link)
      
      return nil if doc.nil?
      
      r = Recruitment.new
      init_values.each_pair { |key, value| r.send("#{key}=", value) }
      
      content_xpath = "//div[@class='models-articletitle']"
      content_div = doc.search(content_xpath)
      
      title_elements = content_div.search("/h1")
      if title_elements.size > 0
        h1_element = title_elements[0]
        r.title = h1_element.inner_html
        h1_element.search("").remove
      end
      
      tag_text = []
      info_exp = /^.*?<a.*?>.*?<\/a>\s*$/im
      
      p_elements = content_div.search("/p")
      p_elements.select { |p|
        p.inner_html =~ info_exp
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
            r.location = locations.join(" ")
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
      tag_text.each { |tag| r.recruitment_tags << RecruitmentTag.get_tag(tag) }
      
      r
      
    end
    
    def get_hiall_new_links(url)
      doc = get_doc_from_url(url, false)
      
      return [] if doc.nil?
      
      list_xpath = "//div[@class='models-articlelist']"
      lists = doc.search(list_xpath)
      
      return [] if lists.size < 2
      
      p_xpath = "/div[@class='models-article']/div[@class='models-articlelistinfo']/p[@class='title']"
      
      # just collect the second list
      paragraphs = lists[1].search(p_xpath)
      paragraphs.collect{ |p|
        p.search("//a").collect{|a| 
          href = a["href"].strip
          href += "/" if href[-1, 1] != "/"
          root_url + href
        }.select { |href| href =~ /action-model-name-hr-itemid-\d*/ }
      }.flatten
      
    end
    
  end
  
end