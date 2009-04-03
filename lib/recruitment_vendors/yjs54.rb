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
          
          existing_links = Recruitment.find(:all, :conditions => ["source_link in (?)", gotten_new_links]).collect { |r| r.source_link }
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
      link.include?("xjh") ? build_recruitment_for_xjh(link, init_values) : build_recruitment_for_non_xjh(link, init_values)
    end
    
    def build_recruitment_for_xjh(link, init_values = {})
      doc = get_doc_from_url(link, true)
      
      return nil if doc.nil?
      
      r = Recruitment.new
      init_values.each_pair { |key, value| r.send("#{key}=", value) }
      
      context_xpath = "//div[@class='context']"
      context_divs = doc.search(context_xpath)
      
      return nil unless context_divs.size > 0
      
      context_div = context_divs[0]
      
      title_element = context_div.at("/h1")
      r.title = title_element.inner_html
      
      return nil if Recruitment.find(:first, :conditions => ["recruitment_type = '宣讲会' and title = ?", r.title])
      
      
      title_element.search("").remove
      
      context_div.search("//div[@class^=zph]").remove
      context_div.search("//a[@href^=/xjh/]").remove
      
      
      r.content = context_div.inner_html
      
      
      # add the fixed attributes
      r.source_name = source_name
      r.source_link = link
      
      r.publish_time = DateTime.now
      
      
      r
    end
    
    def build_recruitment_for_non_xjh(link, init_values = {})
      doc = get_doc_from_url(link, true)
      
      return nil if doc.nil?
      
      r = Recruitment.new
      init_values.each_pair { |key, value| r.send("#{key}=", value) }
      
      content_xpath = "//div[@class='infoer']"
      content_divs = doc.search(content_xpath)
      
      return nil unless content_divs.size > 0
      
      content_div = content_divs[0]
      
      title_element = content_div.at("/h1")
      r.title = title_element.inner_html
      
      texter_divs = content_div.search("/div[@class=texter]")
      return nil unless texter_divs.size > 1
      
      content_text_divs = texter_divs[0].search("/div[@class=c]")
      return nil unless content_text_divs.size > 0
      
      r.content = content_text_divs[0].inner_html
      
      
      tag_text = []
      info_exp = /^.*?<a.*?>.*?<\/a>\s*$/im
      
      spans = content_div.search("/span")
      return nil if spans.size < 3
      
      r.location = spans[0].inner_html
      
      r.publish_time = DateTime.parse(spans[2].inner_html)
      
      tag_text << spans[1].inner_html
      
      
      # add the fixed attributes
      r.source_name = source_name
      r.source_link = link
      
      # tags
      tag_text.uniq!
      tag_text.each { |tag| r.recruitment_tags << RecruitmentTag.get_tag(tag) if tag && (tag.strip != "") }
      
      r
      
    end
    
    def get_yjs54_new_links(url)
      doc = get_doc_from_url(url, false)
      
      return [] if doc.nil?
      
      if url.include?("xjh")
        
        list_xpath = "//a[@href^=/xjhhtml/]"
        list = doc.search(list_xpath)
        
        list.collect { |a|
          href = a["href"].strip
          root_url + href unless href[0, 4] == "http"
        }.select { |href| href =~ /\d+\.html$/ }
                
      else
        
        list_xpath = "//td[@class='company']"
        list = doc.search(list_xpath)
      
        list.collect { |td|
          a = td.at("a")
          href = a["href"].strip
          root_url + href unless href[0, 4] == "http"
        }.select { |href| href =~ /\d+\.html$/ }
        
      end
      
    end
    
  end
  
end


