class CompaniesController < ApplicationController
  
  Company_Post_Num = 15
  Company_Exp_Num = 10
  Company_Talk_Num = 5
  
  Post_List_Size = 50
  Exp_List_Size = 30
  Talk_List_Size = 15
  
  
  layout "community"
  
  before_filter :check_login, :only => [:edit_property, :update_property,
                                        :edit_image, :update_image]
  before_filter :check_limited, :only => [:update_property, :update_image]
  
  before_filter :check_system_company, :only => [:show, :exp, :talk, 
                                                :edit_property, :update_property,
                                                :edit_image, :update_image, 
                                                :post, :good_post]
  
  before_filter :check_info_editor, :only => [:edit_property, :update_property,
                                                :edit_image, :update_image]
  
  
  
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
  
  def show
    @industries = Industry.get_company_industries(@company.id)
    
    profile = CompanyProfile.get_profile(@company.id)
    if profile
      @photo = Photo.get_photo(profile.photo_id) if profile.photo_id && profile.photo_id > 0
      @info = profile.get_info
    end
    
    
    @top_posts = CompanyPost.find(
      :all,
      :select => "id, created_at, company_id, top, good, account_id, title, responded_at, responded_by",
      :conditions => ["company_id = ? and top = ?", @company.id, true],
      :order => "responded_at DESC"
    )
    
    @posts = CompanyPost.find(
      :all,
      :limit => Company_Post_Num,
      :select => "id, created_at, company_id, top, good, account_id, title, responded_at, responded_by",
      :conditions => ["company_id = ? and top = ?", @company.id, false],
      :order => "responded_at DESC"
    )
    
    @exps = Exp.find(
      :all,
      :limit => Company_Exp_Num,
      :select => "exps.id, exps.title",
      :joins => " INNER JOIN exps_companies ON exps.id = exps_companies.exp_id",
      :conditions => ["exps_companies.company_id = ?", @company.id],
      :order => "exps_companies.exp_id DESC"
    )
    
    @talks = Talk.find(
      :all,
      :limit => Company_Talk_Num,
      :select => "talks.id, talks.title, talks.published, talks.publish_at",
      :joins => " INNER JOIN talks_companies ON talks.id = talks_companies.talk_id",
      :conditions => ["talks_companies.company_id = ? and talks.published = ?", @company.id, true],
      :order => "talks_companies.talk_id DESC"
    )
  end
  
  def exp
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @exps = Exp.paginate(
      :page => page,
      :per_page => Exp_List_Size,
      :select => "exps.id, exps.title, exps.publish_time",
      :joins => " INNER JOIN exps_companies ON exps.id = exps_companies.exp_id",
      :conditions => ["exps_companies.company_id = ?", @company.id],
      :order => "exps_companies.exp_id DESC"
    )
  end
  
  def talk
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @talks = Talk.paginate(
      :page => page,
      :per_page => Talk_List_Size,
      :select => "talks.id, talks.title, talks.published, talks.publish_at, talks.info",
      :joins => " INNER JOIN talks_companies ON talks.id = talks_companies.talk_id",
      :conditions => ["talks_companies.company_id = ? and talks.published = ?", @company.id, true],
      :order => "talks_companies.talk_id DESC"
    )
  end
  
  def edit_property
    @profile = CompanyProfile.get_profile(@company.id) || CompanyProfile.new(:company_id => @company.id)
  end
  
  def update_property
    @profile = CompanyProfile.get_profile(@company.id) || CompanyProfile.new(:company_id => @company.id)
    @profile.updater_id = session[:account_id]
    
    company_info = {}
    CompanyProfile::Properties.each do |property|
      company_info[property[0]] = params[property[0]] && params[property[0]].strip
    end
    company_info[:desc] = params[:company_desc]
    @profile.update_info(company_info)
    
    if @profile.save
      flash.now[:message] = "公司信息已成功保存"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render(:action => "edit_property")
  end
  
  def edit_image
    @profile = CompanyProfile.get_profile(@company.id) || CompanyProfile.new
  end
  
  def update_image
    @profile = CompanyProfile.get_profile(@company.id) || CompanyProfile.new(:company_id => @company.id)
    @profile.updater_id = session[:account_id]
    
    old_photo_id = @profile.photo_id
    @profile.photo_id = params[:photo_id]
    
    # validate the photo
    if @profile.photo_id && @profile.photo_id != old_photo_id
      photo = Photo.get_photo(@profile.photo_id)
      if photo && photo.account_id == session[:account_id]
        if @profile.save
          flash.now[:message] = "已成功保存"
        else
          flash.now[:error_msg] = "操作失败, 再试一次吧"
        end
      else
        jump_to("/errors/forbidden")
      end
    end
  end
  
  def photo_selector_for_company_image
    albums = Album.get_all_names_by_account_id(session[:account_id])
    render :partial => "/albums/photo_selector", :locals => {:albums => albums, :photo_list_template => "/profiles/album_photo_list_for_face"}
  end
  
  def post
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
  
  def industry
    industry_id = params[:id]
    
    all
    
    filter_industries = @industries.select { |industry| industry.id.to_s == industry_id }
    return jump_to("/errors/forbidden") unless filter_industries.size > 0 && (@industry = filter_industries[0]).account_id == 0
    
    render :action => "all"
  end
  
  
  private
  
  def check_info_editor
    return jump_to("/errors/forbidden") unless ApplicationController.helpers.info_editor?(session[:account_id])
  end
  
  def check_system_company
    @company = Company.get_company(params[:id])
    
    return jump_to("/errors/forbidden") unless @company.account_id == 0
  end
  
end

