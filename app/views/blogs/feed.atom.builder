atom_feed(:language => "zh_CN", :schema_date => 2008, "xmlns:app" => "http://www.w3.org/2007/app") do |feed|
  
  feed.title("#{h(@owner_nick_pic[0])}的博客 - 乔布圈")
  feed.updated(@blogs.first && @blogs.first.updated_at)

  for b in @blogs
    feed.entry(b) do |entry|
      entry.title(h(b.title))
      
      entry.url("http://qiaobutang.com/blogs/#{b.id}")
      
      entry.published(b.created_at)
      entry.updated(b.updated_at)
      
      entry.content(sanitize_tinymce(b.content), :type => "html")
    end
  end
  
end


