atom_feed(:language => "zh_CN", :schema_date => Time.now.year, "xmlns:app" => "http://www.w3.org/2007/app") do |feed|
  
  feed.title("目标 #{h(Goal.get_goal(@goal_id).name)} 的讨论话题 - 乔布圈")
  feed.updated(@posts.first && @posts.first.updated_at)

  for post in @posts
    feed.entry(post, :url => "/goal/posts/#{post.id}") do |entry|
      entry.title(h(post.title))
      
      entry.url("http://www.qiaobutang.com/goal/posts/#{post.id}")
      
      entry.published(post.created_at)
      entry.updated(post.updated_at)
      
      entry_content = ""
      
      entry_content += %Q!<img src="/images/groups/good_small.gif" border="0" alt="精华" title="精华" />
  			                    &nbsp;&nbsp;&nbsp;! if post.good
  			                    
      entry_content += %Q!由
                            &nbsp;
                            <a href="/spaces/show/#{post.account_id}">#{h(post.account.get_nick)}</a>
  			                    &nbsp;
  			                    发表!
      
      entry_content += sanitize_tinymce(post.content)
      
      entry.content(entry_content, :type => "html")
    end
  end
  
end


