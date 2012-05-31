class CoachController < ApplicationController

  before_filter :disable
  def disable
    jump_to("/")
  end
  
  
  def index
    
  end
  
  def trainers
    
  end
  
  def consultant
    
  end

  def pharmaceutical

  end
  
  
  def stp
    @content = "stp_index"
    
    render :action => "stp", :layout => "uncategoried"
  end
  
  def stp_pic
    @content = "stp_pic"
    
    render :action => "stp", :layout => "uncategoried"
  end
  
  
  # ---
  
  def course_apply
    if has_login?
      existing_application = ServiceApplication.find(
        :last,
        :conditions => ["account_id = ?", session[:account_id]]
      )
      
      if existing_application
        @real_name = existing_application.real_name
        @school = existing_application.school
        @major = existing_application.major
        @grade = existing_application.grade

        @mobile = existing_application.mobile
        @email = existing_application.email
      end
    end
    
    @sid = params[:sid] && params[:sid].strip
    
    render :layout => !@sid
  end
  
  def apply
    return jump_to("/coach/course_apply") unless request.post?
    
    @real_name = params[:real_name] && params[:real_name].strip
    @school = params[:school] && params[:school].strip
    @major = params[:major] && params[:major].strip
    @grade = params[:grade] && params[:grade].strip
    
    @mobile = params[:mobile] && params[:mobile].strip
    @email = params[:email] && params[:email].strip
    
    @sid = params[:sid]
    
    @application = ServiceApplication.new(
      :service_id => @sid,
      :account_id => has_login? ? session[:account_id] : 0,
      
      :real_name => @real_name,
      :school => @school,
      :major => @major,
      :grade => @grade,
      
      :mobile => @mobile,
      :email => @email,
      
      :requester_ip => request.remote_ip
    )
    
    full = (params[:f] == "true")
    
    if @application.save
      if full
        render :inline => %Q@
          <p class="info_msg">
            提交成功! 我们将尽快与你联系!
          </p>
        @, :layout => true
      else
        render :inline => %Q@
          <script type="text/javascript">
            parent.parent.GB_hide();
          </script>
        @, :layout => false
      end
    else
      render :action => "course_apply", :layout => full
    end
  end
  
  
  # ----------
  
  before_filter :check_general_admin, :only => [:course_applications, :update_course_application_closed]
  
  def course_applications
    conditions = []
    
    conditions = ["closed = ?", params[:closed_filter] == "closed"] if params[:closed_filter]
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @applications = ServiceApplication.paginate(
      :page => page,
      :per_page => 20,
      :conditions => conditions,
      :order => %Q!#{conditions.size > 0 ? "created_at" : "id"} DESC!
    )
    
    render :layout => false
  end
  
  def update_course_application_closed
    jump_to("/coach/course_applications") unless request.post?
    
    application = ServiceApplication.find(params[:id])
    application.closed = (params[:closed] == "true")
    
    render :layout => false, :text => application.save.to_s
    
  end
  
  
  private
  
  def check_general_admin
    return jump_to("/coach") unless has_login? && ApplicationController.helpers.general_admin?(session[:account_id])
  end
  
end
