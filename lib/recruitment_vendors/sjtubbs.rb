module RecruitmentVendor

  class Sjtubbs
    include Singleton # use .instance() to return the single instance object
    include RecruitmentVendor::Base
    
    def source_name
      "上海交通大学 饮水思源站"
    end
    
    def root_url
      "http://bbs.sjtu.edu.cn"
    end
    
    def list_url_fulltime
      "http://bbs.sjtu.edu.cn/bbstdoc?board=JobInfo"
    end
    
    def list_url_parttime
      "http://bbs.sjtu.edu.cn/bbstdoc?board=PartTime"
    end
    
    
    
    def get_new_links(start_page = 1, page_count = 1)
      {}
    end
    
    def save_new_messages(start_page = 1, page_count = 1)
      [
        [list_url_fulltime, { :recruitment_type => "全职", :location => "上海" }],
        [list_url_parttime, { :recruitment_type => "兼职", :location => "上海" }]
      ].each { |item|
        init_values = item[1]
        link = item[0]
        
        # to find out current page number
        first_page = nil
        first_page_doc = get_doc_from_url!(link, false)
        page_a_list = first_page_doc.search("a[@href^=bbstdoc?board=]")
        if page_a_list.size > 0
          last_page_a = page_a_list[0]
          numbers = last_page_a[:href].scan(/\d+/)
          first_page = numbers[0].to_i + 1 if numbers.size > 0
        end
        
        if first_page
          
          start_page_num = first_page - start_page + 1

          start_page_num.downto(start_page_num - page_count + 1) { |num|
            url = "#{link}&page=#{num}"
            
            gotten_new_links = get_sjtubbs_new_links(url)
            
            existing_links = Recruitment.find(:all, :conditions => ["source_link in (?)", gotten_new_links.collect { |l| l[0] }]).collect { |r| r.source_link }
            non_existing_links = gotten_new_links.delete_if { |l| existing_links.include?(l[0]) }

            non_existing_links.each do |msg_link_info|
              puts "retrieving message from link: " + msg_link_info[0].inspect
              recruitment = get_recruitment(msg_link_info[0], init_values.merge(msg_link_info[1]))
              recruitment.save if recruitment
            end
          }
        end
        
      }
    end
    
    def build_recruitment(link, init_values = {})
      doc = get_doc_from_url(link, true)
      
      return nil if doc.nil?
      
      return nil if init_values[:title] && init_values[:title].include?("合集")
      
      r = Recruitment.new
      init_values.each_pair { |key, value| r.send("#{key}=", value) }
      
      # add the fixed attributes
      r.source_name = source_name
      r.source_link = link
      
      floor_xpath = "//table[@class='show_border']"
      floors = doc.search(floor_xpath)
      
      return nil unless floors.size > 0
      
      top_floor = floors[0]
      
      pres = top_floor.search("//pre")
      
      return nil unless pres.size > 0
      
      un_processed_content = pres[0]
      
      # remove foot text
      un_processed_content.search("//font[@class=c33]").remove
      
      extracted_content = un_processed_content.inner_html.gsub(/^.*?发信站: 饮水思源 \(.*?\)(, 站内信件)*/im, "")
      
      # check content size to filter "water post"
      if extracted_content.size < 500
        nil
      else
        r.content = "<pre>#{extracted_content}</pre>"
        r
      end
    end
    
    def test
      s = %Q!
        [<a href="bbspst?board=JobInfo&amp;file=M.1224222708.A">回复本文</a>] 发信人: <a href="bbsqry?userid=splendor">splendor</a>(splendor), 信区: JobInfo
        标  题: 上海通用汽车网申截止了吗？
        发信站: 饮水思源 (2008年10月17日13:51:48 星期五), 站内信件

        谁给个链接？谢谢。 
        --

        
      !
      m = "发信站: 饮水思源 (2008年10月17日13:51:48 星期五)"
      
      s2 = %Q!
        [<a href="bbspst?board=JobInfo&amp;file=M.1224222708.A">回复本文</a>] 发信人: <a href="bbsqry?userid=splendor">splendor</a>(splendor), 信区: JobInfo
        标  题: 上海通用汽车网申截止了吗？
        发信站: 饮水思源 (2008年10月17日13:51:48 星期五)

        谁给个链接？谢谢。 
        --

        
      !
      
      puts s
      puts "================="
      puts s.gsub(/^.*?发信站: 饮水思源 \(.*?\)(, 站内信件)*/im, "")
      puts s2.gsub(/^.*?发信站: 饮水思源 \(.*?\)(, 站内信件)*/im, "")
    end
    
    def test2
      doc = get_doc_from_url(list_url_fulltime, false)
      
      puts doc
    end
    
    def get_sjtubbs_new_links(url)
      doc = get_doc_from_sjtubbs_url(url, false)
      
      return [] if doc.nil?
      
      list_xpath = "//table[@width='670']"
      lists = doc.search(list_xpath)
      
      return [] if lists.size < 1
      
      table = lists[0]
      
      tr_xpath = "//tr"
      
      rows = table.search(tr_xpath)
      
      rows.select { |tr|
        tds = tr.search("/td")
        first_td = tds[1]
        author = tds[3]
        first_td && first_td.inner_html =~ /^\d+$/ && !(author.at("a").inner_html.strip =~ /^SJTUBBS$/i)
      }.collect { |tr|
        
        tds = tr.search("/td")
        date_td = tds[4]
        title_td = tds[5]
        
        title_a = title_td.at("a")
        
        init_values = {
          :publish_time => DateTime.parse(date_td.inner_html),
          :title => title_a.inner_html.gsub("○", "").gsub(/转帖|转载|zz|zt/i, "").gsub("()", "").strip
        }
        
        href = title_a[:href].strip
        
        ["#{root_url}/#{href}", init_values]
      }
    end
    
    def fix_tr_td_close_issue(table_html)
      table_html.gsub("<td", "</td><td").gsub("<tr", "</td></tr><tr").gsub("</table>", "</td></tr></table>")
    end
    
    def get_doc_from_sjtubbs_url!(url, handle, document_encoding = "GBK")
      ic = Iconv.new("UTF-8//IGNORE", "#{document_encoding}//IGNORE")
      page = open(
        url,        
        "User-Agent" => "Mozilla"
      )
      page_content = ic.iconv(page.read)
      doc = Hpricot(fix_tr_td_close_issue(page_content))
      
      if handle
        
        # remove troublesome elemtns
        troublesome_elements.each {|element| doc.search("//#{element}").remove }
        
      end
      
      doc
    end

    def get_doc_from_sjtubbs_url(url, handle, document_encoding = "GBK")
      begin
        doc = get_doc_from_sjtubbs_url!(url, handle, document_encoding)
      rescue
        doc = nil
      end
    
      doc
    end
  end
  
end


