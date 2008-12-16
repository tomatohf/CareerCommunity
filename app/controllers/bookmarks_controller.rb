class BookmarksController < ApplicationController
  
  Bookmark_List_Size = 20
  
  layout "community"
  before_filter :check_current_account, :only => [:list_personal_index]
  before_filter :check_login, :only => [:new, :create, :destroy,
                                        :new_group_bookmark, :create_inline]
  before_filter :check_limited, :only => [:create, :destroy, :create_inline]
  
  before_filter :check_bookmark_access, :only => [:destroy]
  
  

  def index
    jump_to("/bookmarks/personal")
  end
  
  def personal
    @page_title = "成员最新推荐"
    
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
  
  
  def new
    @bookmark = PersonalBookmark.new
  end
  
  def new_group_bookmark
    group_id = params[:group_id] && params[:group_id].strip
    
    @bookmark = GroupBookmark.new(
      :group_id => group_id
    )
    
    render :action => "new"
  end
  
  def inline_add_form
    unless has_login?
      return render :inline => %Q!
        <div style="padding: 30px">
          添加收藏前,
          请先
          <a href="/accounts/logon" target="_blank" onclick="setTimeout('parent.parent.GB_hide();', 1000*1); return true;">
            登录</a>
        </div>
      !
    end
    
    @bookmark = PersonalBookmark.new(
      :title => params[:title],
      :url => params[:url]
    )
    
    render :layout => false
  end
  
  def create_inline
    create_template("inline_add_form", false) { |bookmark|
      render :inline => %Q@
        <script type="text/javascript">
          parent.parent.GB_hide();
        </script>
      @, :layout => false
    }
  end
  
  def create
    create_template("new") { |bookmark|
      jump_to_target = if bookmark.kind_of?(GroupBookmark)
        "/groups/bookmark/#{bookmark.group_id}"
      else
        "/bookmarks/personal"
      end
      jump_to(jump_to_target)
    }
  end
  
  def list_personal_index
    jump_to("/bookmarks/list_personal/#{session[:account_id]}")
  end
  
  def list_personal
    @owner_id = params[:id] && params[:id].strip
    @edit = (session[:account_id].to_s == @owner_id)
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @bookmarks = PersonalBookmark.paginate(
      :page => page,
      :per_page => Bookmark_List_Size,
      :conditions => ["account_id = ?", @owner_id],
      :include => [:account => [:profile_pic]],
      :order => "created_at DESC"
    )
  end
  
  def destroy
    @bookmark.destroy
    
    jump_to_target = if @bookmark.kind_of?(GroupBookmark)
      "/groups/bookmark/#{@bookmark.group_id}"
    else
      "/bookmarks/list_personal/#{session[:account_id]}"
    end
    jump_to(jump_to_target)
  end
  
  
  
  private
  
  def create_template(new_action, use_layout = true)
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
    
    if validate_bookmark_url(@bookmark.is_absolute_url ? @bookmark.url : "http://qiaobutang.com" + @bookmark.url)
      if @bookmark.save
        # record account action
        AccountAction.create_new(session[:account_id], "add_bookmark", {
          :bookmark_class_name => @bookmark.class.to_s,
          :bookmark_id => @bookmark.id,
          :bookmark_title => @bookmark.title,
          :bookmark_url => @bookmark.url,
          :bookmark_desc => @bookmark.desc
        })
        
        return yield(@bookmark)
      else
        flash.now[:error_msg] = "操作失败, 再试一次吧"
      end
    else
      flash.now[:error_msg] = "请输入格式正确并且可访问的地址"
    end
    
    render :action => new_action, :layout => use_layout
  end
  
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
  
  
  def check_bookmark_access
    @bookmark_id = params[:id]
    bookmark_type = params[:bookmark_type] && params[:bookmark_type].strip
    
    @bookmark = PersonalBookmark.find(@bookmark_id) if bookmark_type == "personal"
    @bookmark = GroupBookmark.find(@bookmark_id) if bookmark_type == "group"
    
    jump_to("/errors/forbidden") unless (@bookmark && can_delete_bookmark(@bookmark))
  end
  
  def can_delete_bookmark(bookmark)
    (bookmark.account_id == session[:account_id]) ||
    (bookmark.kind_of?(GroupBookmark) && GroupMember.is_group_admin(bookmark.group_id, session[:account_id]))
  end
  
  
end