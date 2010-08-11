atom_feed(:language => "zh_CN", :schema_date => Time.now.year, "xmlns:app" => "http://www.w3.org/2007/app") do |feed|
  
  feed.title("乔布堂周三访谈录")
  feed.updated(@talks.first && @talks.first.publish_at)

  for talk in @talks
    feed.entry(talk) do |entry|
      entry.title(h(talk.title))
      
      entry.url("http://www.qiaobutang.com/talks/#{talk.id}")
      
      entry.published(talk.publish_at)
      entry.updated(talk.publish_at)
      
      entry_content = simple_format(h(extract_text(talk.get_info[:desc])))
      entry_content += %Q!<p><a href="/talks/#{talk.id}">完整阅读这篇访谈录</a></p>!
      
      entry.content(entry_content, :type => "html")
    end
  end
  
end


