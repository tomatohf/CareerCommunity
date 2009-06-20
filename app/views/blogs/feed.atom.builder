atom_feed(:language => "zh_CN", :schema_date => 2008, "xmlns:app" => "http://www.w3.org/2007/app") do |feed|
  
  feed.title(
    @is_all ? "最新博客 - 乔布圈 - 乔布堂" : "#{h(@owner_nick_pic[0])}的博客 - 乔布圈 - 乔布堂"
  )
  feed.updated(@blogs.first && @blogs.first.updated_at)

  for b in @blogs
    feed.entry(b) do |entry|
      entry.title(h(b.title))
      
      entry.url("http://www.qiaobutang.com/blogs/#{b.id}")
      
      entry.published(b.created_at)
      entry.updated(b.updated_at)
      
      blog_content = ""
      
      blog_content += %Q!
        由
        &nbsp;
        <a href="/spaces/show/#{b.account_id}">#{h(b.account.get_nick)}</a>
        &nbsp;
        发表
      ! if @is_all
      
      blog_content += sanitize_tinymce(b.content)
      
      entry.content(blog_content, :type => "html")
    end
  end
  
end


