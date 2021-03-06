# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  # 
  # protect_from_forgery :secret => '6de6e02443a6e9d99a232d1b668dd8d6'
  # 
  # From Rails 2.3
  # The :digest and :secret options to protect_from_forgery are deprecated 
  # and have no effect.
  protect_from_forgery
  
  filter_parameter_logging "password"
  
  # enable output GZip compression
  after_filter OutputCompressionFilter if Rails.env.production?
  
  rescue_from(ActionController::InvalidAuthenticityToken) { |e|
    save_original_address
    jump_to("/accounts/login_form")
  }
  
  
    
  private
  
#  before_filter :configure_charsets
#  def configure_charsets
#    headers["Content-Type"] = "text/html; charset=utf-8"
#  end
  
  before_filter :do_auto_login
  def do_auto_login
    if has_login?
      set_login_cookies(session[:nick]) if session[:nick] != cookies[:n]
      return 
    end
    remove_login_cookies
      
    return if cookies[:s].nil? || cookies[:s] == "" || cookies[:a].nil? || cookies[:a] == ""
    
    session_id = cookies[:s]
    account_id = cookies[:a].to_i
    autologin = Autologin.find_record(session_id, account_id)
    
    if autologin && autologin.expire_time > Time.now
      do_login(account_id)

      # extend the expire time
      expire_time = 30.days.from_now
      cookies[:s] = { :value => session_id, :expires => expire_time }
      cookies[:a] = { :value => account_id.to_s, :expires => expire_time }
      autologin.expire_time = expire_time
      autologin.save
    else
      remove_autologin_cookies
      # Autologin.delete_by_account(account_id)
      autologin.destroy if autologin
    end
  end
  
  
  # before_filter :determine_lang
  # NOTE: method determine_lang MUST be called after method do_auto_login
  # The determine order is
  # 1. the parameter value in request
  # 2. the value setted by user in session
  # 3. the browser expected value in request
#  def determine_lang
#    I18n.load if ENV['RAILS_ENV'] == "development"
#    
#    params[:lang] = nil if params[:lang] == ""
#    session[:lang] = nil if session[:lang] == ""
#    lang = params[:lang] || session[:lang] || request.env["HTTP_ACCEPT_LANGUAGE"].to_s.scan(/\w*\-\w*/).first
#    I18n.set_lang lang
#  end


  # before_filter :check_ie6, :except => [:ie6_warning, :confirm_using_ie6]
  def check_ie6
    unless session[:confirmed_using_ie6] == "true"
      user_agent = request.env["HTTP_USER_AGENT"] || ""
      if user_agent =~ /IE\s6/
        # using MSIE 6
        save_original_address
        jump_to("/index/ie6_warning")
      end
    end
  end
  
  
  
  def do_login(account)
    a = account.kind_of?(Account) ? account : Account.find_enabled(account)
    
    return do_logout unless a
      
    session[:account_id] = a.id
    session[:email] = a.email
    #session[:nick] = CGI.escapeHTML(a.get_nick)
    session[:nick] = a.get_nick
    session[:checked] = a.checked
    session[:limited] = a.limited?
    
    set_login_cookies(session[:nick])
  end
  
  def update_session_nick(nick)
    #session[:nick] = CGI.escapeHTML(nick)
    session[:nick] = nick
    set_login_cookies(session[:nick])
  end
  
  def has_login?
    session[:account_id] && session[:account_id] > 0 && session[:email]
  end
  
  def do_logout
    remove_autologin_cookies
    Autologin.delete_by_account(session[:account_id])
    
    remove_login_cookies
    
    reset_session
  end
  
  def set_login_cookies(nick)
    cookies[:n] = nick.to_s
  end
  
  def remove_login_cookies
    cookies[:n] = nil
    cookies.delete :n
  end
  
  def remove_autologin_cookies
    cookies[:s] = nil
    cookies[:a] = nil
    cookies.delete :s
    cookies.delete :a
  end
  
  def redirect_to_original_address
    original_url = session[:original_url]
    original_method = session[:original_method]
    original_params = session[:original_params]
    session[:original_params] = nil
    session[:original_method] = nil
    session[:original_url] = nil
    
    if original_method != :get && original_params
      original_params[:authenticity_token] = form_authenticity_token
      redirect_non_get(original_params)
    else
      jump_to(original_url || { :controller => "community" })
    end
  end
  
  def save_original_address
    session[:original_url] = request.request_uri
    session[:original_method] = request.method
    session[:original_params] = request.parameters.reject {|key, value| !value.kind_of?(String) }
  end
  
  def save_previous_address
    referer = request.referer
    
    if referer && referer != ""
      hwp = request.host_with_port
      previous_path = referer.include?(hwp) ? referer.split(hwp)[1] : referer
    
      filter_out_regexp = /login|register|accounts\/new|accounts\/send_password/i
      session[:original_url] = previous_path unless (previous_path =~ filter_out_regexp) ||
        (ActionController::Routing::Routes.recognize_path(previous_path, :method => :get) rescue nil).nil?
    end
  end
  
  def redirect_non_get(redirect_post_params)
    controller_name = redirect_post_params[:controller]
    controller = "#{controller_name.camelize}Controller".constantize
    
    # Throw out existing params and merge the stored ones
    # to simulate the original request
    request.parameters.reject! { true }
    request.parameters.merge!(redirect_post_params)
    
    # controller.process(request, response)
    # Now could invoke the public API - Controller.call(request.env)
    controller.call(request.env)
    
    if response.redirected_to
      @performed_redirect = true
    else
      @performed_render = true
    end
  end
  
  def jump_to(url)
    if request.xhr?
      render :update do |page|
        page.redirect_to url
      end
    else
      redirect_to(url)
    end
  end
  
  def check_login
    if has_login?
      @account_checked = session[:checked]
      @account_limited = session[:limited]
      
      yield if block_given?
    else
      save_original_address
      jump_to("/accounts/login_form")
    end
  end
  
  def check_current_account
    unless has_login?
      save_original_address
      jump_to("/accounts/login_form")
    end
  end
  
  def check_employee
    @employee = Intranet::Employee.find_by(:account_id, params[:employee_id].to_i)
    return jump_to("/errors/forbidden") unless @employee
    
    unless session[:account_id] == @employee[:account_id]
      if e = Intranet::Employee.find_by(:account_id, session[:account_id])
        @manager = e[:manager]
      end
      
      jump_to("/errors/unauthorized") unless @manager
    end
  end
  
  def is_limited?(account_or_limited)
    account_or_limited.kind_of?(Account) ? account_or_limited.limited? : account_or_limited
  end
  
  def check_limited(limited = nil)
    jump_to("/errors/limited") if limited || @account_limited || is_limited?(@account)
  end

  def is_img_code_correct?
    c = session[:img_code] == params[:img_code]
    flash.now[:error_msg] = %Q{
                                  请输入正确的验证码
                            } unless c
    c
  end
  
  def performed_render_or_redirect
    @performed_render || @performed_redirect
  end
  
end
