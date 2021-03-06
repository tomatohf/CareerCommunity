class BlogsController < ApplicationController
  
  Comment_Page_Size = 100
  Blog_Page_Size = 15
  
  New_Comment_Size = 30
  
  layout "community"
  before_filter :check_current_account, :only => [:list_index]
  before_filter :check_login, :only => [:new, :create, :edit, :update, :destroy,
                                        :create_comment, :delete_comment]
  before_filter :check_limited, :only => [:create, :update, :destroy, :create_comment, :delete_comment]
  before_filter :check_blog_access, :only => [:edit, :update, :destroy]
  
  before_filter :check_comment_owner, :only => [:delete_comment]
  
  
  
  ACKP_blogs_account_feed = :ac_blogs_account_feed
  ACKP_blogs_all_feed = :ac_blogs_all_feed
  Blog_All_Feed_ID = "all"
  
  caches_action :feed,
    :cache_path => Proc.new { |controller|
      owner_id = controller.params[:id]
      (owner_id == Blog_All_Feed_ID) ? ACKP_blogs_all_feed.to_s : "#{ACKP_blogs_account_feed}_#{owner_id}"
    },
    :if => Proc.new { |controller|
      controller.request.format.atom?
    }
  
  
  
  def index
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @blogs = Blog.paginate(
      :page => page,
      :per_page => Blog_Page_Size,
      :order => "created_at DESC"
    )
    
    @new_comments = BlogComment.find(
      :all,
      :limit => New_Comment_Size,
      :order => "id DESC"
    )
  end
  
  # ! current account needed !
  def list_index
    jump_to("/blogs/list/#{session[:account_id]}")
  end
  
  def list
    @owner_id = params[:id]

    @edit = session[:account_id].to_s == @owner_id
    
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @blogs = Blog.paginate(
      :page => page,
      :per_page => Blog_Page_Size,
      :conditions => ["account_id = ?", @owner_id],
      :order => "created_at DESC"
    )
    
    @new_comments = BlogComment.find(
      :all,
      :limit => New_Comment_Size,
      :conditions => ["blog_id in (?)", @blogs],
      :order => "id DESC"
    )
  end
  
  def feed
    @owner_id = params[:id]
    
    @is_all = (@owner_id == Blog_All_Feed_ID)
    
    respond_to do |format|
      format.html {
        jump_to(
          @is_all ? "/blogs" : "/blogs/list/#{@owner_id}"
        )
      }
      
      format.atom {
        if @is_all
          @blogs = Blog.find(
            :all,
            :limit => Blog_Page_Size,
            :include => [:account],
            :order => "created_at DESC"
          )
        else
          @owner_nick_pic = Account.get_nick_and_pic(@owner_id)
        
          @blogs = Blog.find(
            :all,
            :limit => Blog_Page_Size,
            :conditions => ["account_id = ?", @owner_id],
            :order => "created_at DESC"
          )
        end
        
        render :layout => false
      }
    end
  end
  
  # ! login required !
  def new
    @blog = Blog.new
  end
  
  def create
    @blog = Blog.new(:account_id => session[:account_id])
    
    @blog.title = params[:blog_title] && params[:blog_title].strip
    @blog.content = params[:blog_content] && params[:blog_content].strip
    
    if @blog.save
      # record account action
      AccountAction.create_new(session[:account_id], "add_blog", {
        :blog_id => @blog.id,
        :blog_title => @blog.title
      })
      
      jump_to("/blogs/#{@blog.id}")
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
      render :action => "new"
    end
    
  end
  
  def show
    @blog ||= Blog.find(params[:id])
    
    @edit = (@blog.account_id == session[:account_id])
    
    @owner_nick_pic = Account.get_nick_and_pic(@blog.account_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @blog_comments = @blog.comments.paginate(
      :page => page,
      :per_page => Comment_Page_Size,
      :total_entries => BlogComment.get_count(@blog.id),
      :include => [:account => [:profile_pic]],
      :order => "created_at ASC"
    )
  end
  
  def edit
    
  end
  
  def update
    @blog.title = params[:blog_title] && params[:blog_title].strip
    @blog.content = params[:blog_content] && params[:blog_content].strip
    
    if @blog.save
      flash.now[:message] = "已成功保存"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end

    render :action => "edit"
  end
  
  def destroy
    @blog.destroy
    
    jump_to("/blogs/list/#{session[:account_id]}")
  end
  
  def create_comment
    blog_comment = BlogComment.new(:account_id => session[:account_id])
    
    content = params[:blog_comment]
    blog_id = params[:id]
    
    comment_saved = false
    if blog_id && content
      blog_comment.content = content.strip
      blog_comment.blog_id = blog_id
      comment_saved = blog_comment.save
    end
    
    
    if comment_saved
      AccountAction.create_new(session[:account_id], "add_blog_comment", {
        :blog_id => blog_comment.blog_id,
        :comment_id => blog_comment.id,
        :comment_content => blog_comment.content
      })
    end
    
    
    total_count = BlogComment.get_count(blog_comment.blog_id)
    last_page = total_count > 0 ? (total_count.to_f/Comment_Page_Size).ceil : 1
    
    jump_to("/blogs/#{blog_id}/comment/#{last_page}#{"#comment_#{blog_comment.id}" if comment_saved}")
  end
  
  def delete_comment
    @blog_comment.destroy
    
    jump_to("/blogs/#{@blog_comment.blog_id}")
  end
  
  
  
  private
  
  def check_blog_access
    no_blog_access unless check_blog_owner
  end
  
  def check_blog_owner
    @blog = Blog.find(params[:id])
    @blog.account_id == session[:account_id]
  end
  
  def no_blog_access
    jump_to("/errors/forbidden")
  end
  
  def check_comment_owner
    @blog_comment = BlogComment.find(params[:id])
    jump_to("/errors/forbidden") unless session[:account_id] == (@blog_comment.blog && @blog_comment.blog.account_id)
  end
  
end