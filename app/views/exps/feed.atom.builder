atom_feed(:language => "zh_CN", :schema_date => 2008, "xmlns:app" => "http://www.w3.org/2007/app") do |feed|
  
  feed.title("最新面经 - 乔布圈")
  feed.updated((@exps.first.updated_at))

  for exp in @exps
    feed.entry(exp) do |entry|
      entry.title(h(exp.title))
      
      entry.url("http://www.qiaobutang.com/exps/#{exp.id}")
      
      entry.published(exp.publish_time)
      entry.updated(exp.updated_at)
      
      entry_content = ""
			
      entry_content += sanitize_tinymce(exp.content)
      entry.content(entry_content, :type => "html")
    end
  end
  
end


