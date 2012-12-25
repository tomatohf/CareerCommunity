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
      "http://hiall.com.cn/info/index.php?"
    end
    
    def list_url_parttime
      "http://hiall.com.cn/info/part.php?"
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
        [list_url_parttime, Recruitment::Type_parttime]
      ].each { |item|
        init_values = { :recruitment_type => item[1] }
        link = item[0]
        new_links.merge!(
          urls(link, start_page, page_count).collect { |url|
            get_hiall_new_links(url)
          }.flatten.build_hash_keys{
            init_values
          }
        )
      }
      
      new_links
    end

    def save_new_messages(start_page = 1, page_count = 1)
      [
        [list_url_fulltime, Recruitment::Type_fulltime],
        [list_url_parttime, Recruitment::Type_parttime]
      ].each { |item|
        init_values = { :recruitment_type => item[1] }
        link = item[0]
        start_page.upto(start_page + page_count - 1) { |page|
          url = "#{link}&page=#{page}"
          gotten_new_links = get_hiall_new_links(url)
          
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
      doc = get_doc_from_url(link, true, "UTF-8")
      
      return nil if doc.nil?
      
      r = Recruitment.new
      init_values.each_pair { |key, value| r.send("#{key}=", value) }
      
      h1 = doc.search("//h1[@class=positiontitle]")
      return nil unless h1.size > 0
      r.title = h1[0].inner_html
      
      job_detail = doc.search("//div[@class=job_detail]")
      return nil unless job_detail.size > 0
      job_detail.search("/p/span").each do |span|
        chars = span.inner_html.strip.split("")
        r.location = chars[5..-1].join if chars[0, 4].join == "工作地区"
        r.publish_time = DateTime.parse(chars[5..-1].join) if chars[0, 4].join == "更新时间"
      end
      r.publish_time ||= DateTime.now
      
      # job_detail.search("/h1").remove
      # job_detail.search("/p").remove
      # job_detail.search("/div[@class]").remove
      # job_detail.search("/div[@style]").remove
      # r.content = job_detail.at("div").inner_html.strip
      box = doc.search("//div[@class=box]")
      return nil unless box.size > 0
      r.content = box[0].inner_html.strip
      return nil if r.content.blank?
      
      # add the fixed attributes
      r.source_name = source_name
      r.source_link = link
      
      r
    end
    
    def get_hiall_new_links(url)
      doc = get_doc_from_url(url, false)
      
      return [] if doc.nil?
      
      doc.search("//div.list_midcontent/a").collect { |a|
        href = a["href"].strip
        root_url + href unless href[0, 4] == "http"
      }.select { |href| href =~ /\d+\.html$/ }
    end
    
  end
  
end


