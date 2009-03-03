atom_feed(:language => "zh_CN", :schema_date => 2008, "xmlns:app" => "http://www.w3.org/2007/app") do |feed|
  
  feed.title("最新招聘信息 - 乔布圈")
  feed.updated((@recruitments.first.updated_at))

  for r in @recruitments
    feed.entry(r) do |entry|
      entry.title(h(r.title))
      
      entry.url("http://www.qiaobutang.com/recruitments/#{r.id}")
      
      entry.published(r.publish_time)
      entry.updated(r.updated_at)
      
      entry_content = ""
      
      entry_content += %Q!类型: <a href="#{root_url}recruitments/recruitment_type?name=#{h(r.recruitment_type)}">#{h(r.recruitment_type)}</a> <br />! if r.recruitment_type && r.recruitment_type != ""
      entry_content += %Q!地区: <a href="#{root_url}recruitments/location?name=#{h(r.location)}">#{h(r.location)}</a> <br />! if r.location && r.location != ""
      
      tags = r.recruitment_tags
			if tags.size > 0
				entry_content += "标签: "
				
				tags.each do |tag|
					entry_content += %Q!<a href="#{root_url}recruitments/tag?name=#{h(tag.name)}">#{h(tag.name)}</a>!
				end
			end
  		
			entry_content += "<br />"
			
      entry_content += sanitize_tinymce(r.content)
      entry.content(entry_content, :type => "html")
    end
  end
  
end


