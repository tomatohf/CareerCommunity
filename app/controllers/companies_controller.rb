class CompaniesController < ApplicationController
  
  Post_List_Size = 50
  
  
  layout "community"
  
  # before_filter :check_login, :only => []
  # before_filter :check_limited, :only => []
  
  
  
  ACKP_posts_company_feed = :ac_posts_company_feed
  
  caches_action :feed,
    :cache_path => Proc.new { |controller|
      company_id = controller.params[:id]
      "#{ACKP_posts_company_feed}_#{company_id}"
    },
    :if => Proc.new { |controller|
      controller.request.format.atom?
    }
  
  
  
  def feed
    @company_id = params[:id]
    
    respond_to do |format|
      # no specific company show page
      format.html { jump_to("/community") }

      format.atom {
        @posts = CompanyPost.find(
          :all,
          :limit => Post_List_Size,
          :conditions => ["company_id = ?", @company_id],
          :include => [:account],
          :order => "responded_at DESC"
        )

        render :layout => false
      }
    end
  end
    
    
  def index
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @posts = CompanyPost.paginate(
      :page => page,
      :per_page => Post_List_Size,
      :select => "id, created_at, company_id, top, good, account_id, title, responded_at, responded_by",
      :order => "responded_at DESC"
    )
  end
  
  def post
    @company = Company.get_company(params[:id])
    
    @top_company_posts = CompanyPost.find(
      :all,
      :select => "id, created_at, company_id, top, good, account_id, title, responded_at, responded_by",
      :conditions => ["company_id = ? and top = ?", @company.id, true],
      :order => "responded_at DESC"
    )
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @company_posts = CompanyPost.paginate(
      :page => page,
      :per_page => Post_List_Size,
      :select => "id, created_at, company_id, top, good, account_id, title, responded_at, responded_by",
      :conditions => ["company_id = ? and top = ?", @company.id, false],
      :order => "responded_at DESC"
    )
  end
  
  def good_post
    @company = Company.get_company(params[:id])
    
    @top_company_posts = CompanyPost.good.find(
      :all,
      :select => "id, created_at, company_id, top, good, account_id, title, responded_at, responded_by",
      :conditions => ["company_id = ? and top = ?", @company.id, true],
      :order => "responded_at DESC"
    )
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @company_posts = CompanyPost.good.paginate(
      :page => page,
      :per_page => Post_List_Size,
      :select => "id, created_at, company_id, top, good, account_id, title, responded_at, responded_by",
      :conditions => ["company_id = ? and top = ?", @company.id, false],
      :order => "responded_at DESC"
    )
  end
  
  
  def all
    @industries = Industry.system.find(
      :all,
      :include => [:companies]
    )
  end
  
  
  private
  
end

