class BookmarksController < ApplicationController
  
  Bookmark_List_Size = 2
  
  layout "community"
  before_filter :check_current_account, :only => [:list_personal_index]
  before_filter :check_login, :only => [:new, :create]
  before_filter :check_limited, :only => [:create]
  
  

  def index
    jump_to("/bookmarks/personal")
  end
  
  def personal
    @page_title = "最新会员推荐"
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @bookmarks = PersonalBookmark.paginate(
      :page => page,
      :per_page => Bookmark_List_Size,
      :include => [:account => [:profile_pic]],
      :order => "created_at DESC"
    )
    
    render :action => "list"
  end
  
  def group
    @page_title = "最新圈子收藏"
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @bookmarks = GroupBookmark.paginate(
      :page => page,
      :per_page => Bookmark_List_Size,
      :include => [{:account => [:profile_pic]}, {:group => [:image]}],
      :order => "created_at DESC"
    )
    
    render :action => "list"
  end
  
  
  def new
    @bookmark = PersonalBookmark.new
  end
  
  def create
    title = params[:bookmark_title] && params[:bookmark_title].strip
    url = params[:bookmark_url] && params[:bookmark_url].strip
    desc = params[:bookmark_desc] && params[:bookmark_desc].strip
    
    bookmark_type = params[:bookmark_type]
    @bookmark = (bookmark_type == "group") ? GroupBookmark.new(:group_id => params[:group_id]) : PersonalBookmark.new
    
    # check group member
    return jump_to("/errors/forbidden") if @bookmark.kind_of?(GroupBookmark) && !(GroupMember.is_group_member(@bookmark.group_id, session[:account_id]))
    
    @bookmark.account_id = session[:account_id]
    
    @bookmark.title = title
    @bookmark.url = url
    @bookmark.desc = desc
    
    if validate_bookmark_url(@bookmark.url[0, 4] == "http" ? @bookmark.url : "http://qiaobutang.com" + @bookmark.url)
      if @bookmark.save
        # record account action
        AccountAction.create_new(session[:account_id], "add_bookmark", {
          :bookmark_class_name => @bookmark.class.to_s,
          :bookmark_id => @bookmark.id,
          :bookmark_title => @bookmark.title,
          :bookmark_url => @bookmark.url,
          :bookmark_desc => @bookmark.desc
        })
        
        return jump_to("/bookmarks/#{@bookmark.kind_of?(GroupBookmark) ? "group" : "personal"}")
      else
        flash.now[:error_msg] = "操作失败, 再试一次吧"
      end
    else
      flash.now[:error_msg] = "请输入格式正确并且可访问的地址"
    end
    
    render :action => "new"
  end
  
  def list_personal_index
    jump_to("/bookmarks/list_personal/#{session[:account_id]}")
  end
  
  def list_personal
    owner_id = params[:id] && params[:id].strip
    @edit = (session[:account_id].to_s == owner_id)
    
    owner_nick_pic = Account.get_nick_and_pic(owner_id) unless @edit
    @page_title = "#{@edit ? "我" : owner_nick_pic[0]} 的所有推荐"
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @bookmarks = PersonalBookmark.paginate(
      :page => page,
      :per_page => Bookmark_List_Size,
      :conditions => ["account_id = ?", owner_id],
      :include => [:account => [:profile_pic]],
      :order => "created_at DESC"
    )
    
    render :action => "list"
  end
  
  
  
  private
  
  def validate_bookmark_url(url)
    begin
      page = open(
        url,        
        "User-Agent" => "Mozilla"
      )
    rescue
      page = nil
    end
    
    page
  end
  
  
end