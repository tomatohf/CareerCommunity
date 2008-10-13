class ProfilesController < ApplicationController
  
  layout "community"
  before_filter :check_current_account, :only => [:index, :new, :edit, :show]
  before_filter :check_login_for_profile, :only => [:basic, :contact, :hobby, :educations, :jobs, :pic]
  before_filter :check_login, :check_limited, :only => [:educations_add, :educations_del, :jobs_add, :jobs_del]
  before_filter :check_login, :only => [:photo_selector_for_pic_profile]
  before_filter :check_limited_for_profile, :only => [:basic, :contact, :hobby, :pic]
  
  skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_edu_name, :auto_complete_for_job_name]
  
  # ! current account needed !
  def index
    jump_to("/profiles/#{session[:account_id]}/basic")
  end
  
  # ! current account needed !
  def new
    jump_to("/profiles/#{session[:account_id]}/basic")
  end
  
  # ! current account needed !
  def edit
    jump_to("/profiles/#{session[:account_id]}/basic")
  end
  
  # ! current account needed !
  def show
    jump_to("/profiles/#{session[:account_id]}/basic")
  end
  
  # ! login required !
  def basic
    @profile ||= BasicProfile.new(:account_id => session[:account_id])
    
    provinces_cities = Province.get_all_provinces_cities
    @provinces = provinces_cities.keys
    @js_provinces_cities = %Q!{"placeholder":"placeholder" !
    provinces_cities.each { |k, v|
      @js_provinces_cities += %Q!,"#{k[0]}":#{v.inspect} !
    }
    @js_provinces_cities += "}"
    
    
    if request.post?
      # ! unlimited required !
        
      @profile.real_name = params[:real_name] && params[:real_name].strip
      
      @profile.gender = case params[:gender]
        when "true"
          true
        when "false"
          false
        else
          nil
      end
      
      birthday_year = params[:birthday_year]
      birthday_month = params[:birthday_month]
      birthday_date = params[:birthday_date]
      begin
        @profile.birthday = Date.new(birthday_year.to_i, birthday_month.to_i, birthday_date.to_i)
      rescue
        @profile.birthday = nil
      end
      
      @profile.province_id = params[:location_province]
      @profile.city_id = params[:location_city]
      
      @profile.hometown_province_id = params[:hometown_province]
      @profile.hometown_city_id = params[:hometown_city]

      @profile.qmd = params[:qmd] && params[:qmd].strip
      
      if @profile.save
        flash.now[:message] = "已成功保存"
      else
        flash.now[:error_msg] = "操作失败, 再试一次吧"
      end
    
    end
  end
  
  # ! login required !
  def contact
    @profile ||= ContactProfile.new(:account_id => session[:account_id])
    @email = session[:email]
    
    if request.post?
      # ! unlimited required !
        
      @profile.msn = params[:msn] && params[:msn].strip
      @profile.gtalk = params[:gtalk] && params[:gtalk].strip
      @profile.qq = params[:qq] && params[:qq].strip
      @profile.skype = params[:skype] && params[:skype].strip
      @profile.mobile = params[:mobile] && params[:mobile].strip
      @profile.phone = params[:phone] && params[:phone].strip
      @profile.address = params[:address] && params[:address].strip
      @profile.website = params[:website] && params[:website].strip
      
      if @profile.save
        flash.now[:message] = "已成功保存"
      else
        flash.now[:error_msg] = "操作失败, 再试一次吧"
      end
    
    end
  end
  
  # ! login required !
  def hobby
    @profile ||= HobbyProfile.new(:account_id => session[:account_id])
    
    if request.post?
      # ! unlimited required !
        
      @profile.intro = params[:intro] && params[:intro].strip
      @profile.interest = params[:interest] && params[:interest].strip
      @profile.music = params[:music] && params[:music].strip
      @profile.movie = params[:movie] && params[:movie].strip
      @profile.cartoon = params[:cartoon] && params[:cartoon].strip
      @profile.game = params[:game] && params[:game].strip
      @profile.sport = params[:sport] && params[:sport].strip
      @profile.book = params[:book] && params[:book].strip
      @profile.words = params[:words] && params[:words].strip
      @profile.food = params[:food] && params[:food].strip
      @profile.idol = params[:idol] && params[:idol].strip
      @profile.car = params[:car] && params[:car].strip
      @profile.place = params[:place] && params[:place].strip
      
      if @profile.save
        flash.now[:message] = "已成功保存"
      else
        flash.now[:error_msg] = "操作失败, 再试一次吧"
      end
    
    end
  end
  
  # ! login required !
  def educations
    @education_levels = Education.find(:all)
  end
  
  # ! login required !
  # ! unlimited required !
  def educations_add
    return jump_to("/errors/forbidden") unless session[:account_id].to_s == params[:id]
    
    @edu_profile = EducationProfile.new(:account_id => session[:account_id])
    
    @edu_profile.edu_name = params[:edu_name] && params[:edu_name].strip
    @edu_profile.education_id = params[:education_id]
    @edu_profile.enter_year = params[:enter_year]
    @edu_profile.major = params[:major] && params[:major].strip
    
    if @edu_profile.save
      @edu_profile.add_to_cache
      @saved = true
      @edu_profile_entry_id = "edu_profile_#{@edu_profile.id}"
      flash.now[:info_msg] = %Q!已成功保存!
    else
      @saved = false
      flash.now[:error_msg] = %Q!操作失败, 再试一次吧
                      <br />
                      #{ApplicationController.helpers.list_model_validate_errors(@edu_profile)}!
    end
  end
  
  # ! login required !
  # ! unlimited required !
  def educations_del
    edu_profile_id = params[:edu_profile_id]
    edu_profile = EducationProfile.find(edu_profile_id, :select => "id, account_id")
    
    return jump_to("/errors/forbidden") unless edu_profile.account_id == session[:account_id]
    
    EducationProfile.delete(edu_profile_id)
    @edu_profile_entry_id = "edu_profile_#{edu_profile_id}"
  end
  
  def auto_complete_for_edu_name
    partial_edu_name = params[:edu_name].strip
    @names = EducationProfile.get_by_partial_edu_name(partial_edu_name)
    
    render(:layout => false, :template => "profiles/auto_complete_for_name.html.erb")
  end
  
  # ! login required !
  def jobs
    @profession_kinds = Profession.find(:all)
  end
  
  # ! login required !
  # ! unlimited required !
  def jobs_add
    return jump_to("/errors/forbidden") unless session[:account_id].to_s == params[:id]
    
    @job_profile = JobProfile.new(:account_id => session[:account_id])
    
    @job_profile.job_name = params[:job_name] && params[:job_name].strip
    
    @job_profile.profession_id = params[:profession_id]
    
    @job_profile.enter_year = params[:enter_year]
    @job_profile.enter_month = params[:enter_month]
    
    @job_profile.dept = params[:dept] && params[:dept].strip
    @job_profile.position_title = params[:position_title] && params[:position_title].strip
    @job_profile.description = params[:description] && params[:description].strip
    
    if @job_profile.save
      @job_profile.add_to_cache
      @saved = true
      @job_profile_entry_id = "job_profile_#{@job_profile.id}"
      flash.now[:info_msg] = %Q!已成功保存!
    else
      @saved = false
      flash.now[:error_msg] = %Q!操作失败, 再试一次吧
                      <br />
                      #{ApplicationController.helpers.list_model_validate_errors(@job_profile)}!
    end
  end
  
  # ! login required !
  # ! unlimited required !
  def jobs_del
    job_profile_id = params[:job_profile_id]
    job_profile = JobProfile.find(job_profile_id, :select => "id, account_id")
    
    return jump_to("/errors/forbidden") unless job_profile.account_id == session[:account_id]
    
    JobProfile.delete(job_profile_id)
    @job_profile_entry_id = "job_profile_#{job_profile_id}"
  end
  
  def auto_complete_for_job_name
    partial_job_name = params[:job_name].strip
    @names = JobProfile.get_by_partial_job_name(partial_job_name)
    
    render(:layout => false, :template => "profiles/auto_complete_for_name.html.erb")
  end
  
  # ! login required !
  def pic
    @profile ||= PicProfile.new(:account_id => session[:account_id])
    
    if request.post?
      # ! unlimited required !
      
      old_photo_id = @profile.photo_id
      @profile.photo_id = params[:photo_id]
      
      # validate the photo
      if @profile.photo_id && @profile.photo_id != old_photo_id
        photo = @profile.photo
        if photo && photo.account_id == @profile.account_id
          @profile.pic_url = photo.image.url(:thumb_48)
          if @profile.save
            Account.update_account_nick_pic_cache(session[:account_id], :pic => @profile.pic_url)
            flash.now[:message] = "已成功保存"
          else
            flash.now[:error_msg] = "操作失败, 再试一次吧"
          end
        else
          jump_to("/errors/forbidden")
        end
      end
    end
    
  end

  def photo_selector_for_pic_profile
    albums = Album.get_all_names_by_account_id(session[:account_id])
    render :partial => "albums/photo_selector", :locals => {:albums => albums, :photo_list_template => "/profiles/album_photo_list_for_face"}
  end
  
  
  private
  
  def check_login_for_profile
    check_login {
      if session[:account_id].to_s == params[:id]
        multiple = action_name[-1, 1] == "s"
        profile_name, method_name = multiple ? [action_name[0...-1], :get_all_by_account] : [action_name, :get_by_account]
        
        order = case profile_name
          when "education"
            "education_id DESC, enter_year DESC"
          when "job"
            "enter_year DESC, enter_month DESC"
          else
            nil
        end
        
        @profile = eval("#{profile_name.capitalize}Profile").send(method_name, session[:account_id], :order => order)
      else
        jump_to("/errors/forbidden")
      end
    }
  end
  
  def check_limited_for_profile
    check_limited if request.post?
  end
  
end