class AccountsController < ApplicationController
  
  layout "community"
  before_filter :check_current_account, :only => [:index, :send_register_confirmation]
  before_filter :check_login_for_account, :only => [:register_confirmation, :edit, :update, :update_password,
                                                    :edit_email, :update_email]
  before_filter :check_limited, :only => [:update, :update_password]
  
  
  
  # ! current account needed !
  def index
    jump_to("/accounts/#{session[:account_id]}/edit")
  end
  
  def new
    save_previous_address
    
    @account = Account.new
  end
  
  def create
    email = params[:account_email] && params[:account_email].strip
    password = params[:account_password]
    nick = params[:account_nick]
    
    @account = Account.new
    
    if @account.create_new(email, password, nick)
      do_login(@account)
      send_register_confirmation
    else
      render(:action => "new")
    end
  end
  
  # ! login required !
  def edit
    
  end

  # ! login required !
  # ! unlimited required !
  def update
    nick = params[:account_nick] ? params[:account_nick].strip : ""
    
    @account.nick = nick
    if @account.save
      update_session_nick(@account.get_nick)
      flash.now[:message] = "你的昵称已成功修改"
    else
      flash.now[:error_msg] = "修改昵称失败, 再试一次吧"
    end

    render :action => "edit"
  end
  
  # ! login required !
  # ! unlimited required !
  def update_password
    current_password = params[:current_password]
    correct_password = @account.password
    if current_password == correct_password
      @account.password = params[:account_password]
      flash.now[:message] = "你的密码已成功修改" if @account.save
    else
      flash.now[:error_msg] = "你输入的当前密码不正确, 不能修改密码"
    end
    
    render :action => "edit"
  end
  
  # ! current account needed !
  def send_register_confirmation
    jump_to("/accounts/#{session[:account_id]}/register_confirmation")
  end
  
  # ! login required !
  def register_confirmation
    @account.deliver_register_confirmation unless @account.checked
  end
  
  def confirm_register
    aid = params[:id]
    key = params[:k]
    
    account = Account.find_enabled(aid)
    @checked = account && account.confirm_register(key)
    
    # login from the register confirm email
    do_login(account) if @checked
  end
  
  def delete_register
    aid = params[:id]
    key = params[:k]
    
    account = Account.find_enabled(aid)
    @deleted = account && account.delete_register(key)
    
    # logout once the account has been deleted
    do_logout if @deleted
  end
  
  def logon
    save_previous_address
    
    jump_to("/accounts/login_form")
  end
  
  def login_form
    
  end
  
  def login
    @email = params[:email]
    @password = params[:password]
    account = Account.authenticate(@email, @password)
    if account
      do_login(account)

      if params[:autologin] == "true"
        # set auto-login
        set_autologin(account)
      end

      redirect_to_original_address
    else
      flash.now[:message] = "登录失败, 你的 email 地址 或者 密码 是错误的, 或者帐号当前未被启用"
      render :action => "login_form"
    end
  end
  
  def logout
    save_previous_address
    
    do_logout
    redirect_to_original_address
  end
  
  def forgot_password

  end
  
  def send_password
    @email = params[:email]
    if is_img_code_correct?
      account = Account.get_by_email(@email)
      if account
        if account.checked
          return account.deliver_password_remind
        else
          flash.now[:error_msg] = "你的 email 地址尚未通过验证"
        end
      else
        flash.now[:error_msg] = "请输入你正确的 email 地址"
      end
    end
    render :action => "forgot_password"
  end
  
  
  def edit_email
    
  end
  
  def update_email
    new_email = params[:account_email] && params[:account_email].strip
    
    old_email = @account.email
    
    @account.email = new_email
    # set checked flag to false
    @account.checked = false
    
    if @account.save
      # re-login and clear related cache
      do_login(@account)
      
      send_register_confirmation
    else
      @account.email = old_email
      @account.checked = true
      
      render(:action => "edit_email")
    end
  end
  
  
  def return_original_page
    redirect_to_original_address
  end
  

  
  private
  
  def check_login_for_account
    check_login {
      if session[:account_id].to_s == params[:id]
        @account = Account.find_enabled(session[:account_id])
      else
        jump_to("/errors/forbidden")
      end
    }
  end
  
  def set_autologin(account)
    session_id = request.session_options[:id]
    account_id = account.id
    expire_time = 30.days.from_now
    
    old_cookies_s = cookies[:s]
    old_cookies_a = cookies[:a]
    
    cookies[:s] = { :value => session_id, :expires => expire_time }
    cookies[:a] = { :value => account_id.to_s, :expires => expire_time }
    
    # autologin = Autologin.get_by_account_id(account_id) || Autologin.new
    autologin = Autologin.new
    autologin.session_id = session_id
    autologin.account_id = account_id
    autologin.expire_time = expire_time
    if autologin.save
      # clear old cookies related autologin records
      Autologin.delete_record(old_cookies_s, old_cookies_a) if old_cookies_s && old_cookies_a
    end
    
    # clear expired autologin records
    Autologin.clear_expired_records
  end
  
end
