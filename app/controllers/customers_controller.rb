class CustomersController < ApplicationController
  
  Post_List_Size = 50
  Customer_List_Size = 35

  
  layout "community"
  
  before_filter :check_login #, :only => []
  # before_filter :check_limited, :only => []
  
  before_filter :check_teacher, :only => [:index, :all]
  before_filter :check_customer_access, :only => [:post, :good_post]



  def index
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @posts = CustomerPost.paginate(
      :page => page,
      :per_page => Post_List_Size,
      :select => "id, created_at, customer_id, top, good, account_id, title, responded_at, responded_by",
      :order => "responded_at DESC"
    )
  end
  
  def all
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @customers = RoleProfile.paginate(
      :page => page,
      :per_page => Customer_List_Size,
      :conditions => ["role_type = ?", RoleProfile.ids.customer_role_id],
      :order => "updated_at DESC"
    )
  end
  
  def post
    
    @account_nick_pic = Account.get_nick_and_pic(@account_id)
    
    @top_posts = CustomerPost.find(
      :all,
      :select => "id, created_at, customer_id, top, good, account_id, title, responded_at, responded_by",
      :conditions => ["customer_id = ? and top = ?", @account_id, true],
      :order => "responded_at DESC"
    )
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @posts = CustomerPost.paginate(
      :page => page,
      :per_page => Post_List_Size,
      :select => "id, created_at, customer_id, top, good, account_id, title, responded_at, responded_by",
      :conditions => ["customer_id = ? and top = ?", @account_id, false],
      :order => "responded_at DESC"
    )
    
  end
  
  def good_post
    url = "/customers/post/#{params[:id]}"
    
    page = params[:page] && params[:page].strip
    url += "/#{page}" if page && page != ""
    
    jump_to(url)
  end
  
  
  
  private
  
  def check_teacher
    jump_to("/errors/forbidden") unless teacher?
  end
  
  def check_customer_access
    @account_id = params[:id]
    @is_teacher = teacher?
    
    jump_to("/errors/forbidden") unless @is_teacher || (session[:account_id].to_s == @account_id)
  end
  
  def teacher?
    ApplicationController.helpers.teacher?(session[:account_id])
  end
  
end

