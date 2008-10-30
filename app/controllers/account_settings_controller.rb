class AccountSettingsController < ApplicationController
  
  layout "community"
  before_filter :check_current_account, :only => [:index]
  before_filter :check_login_for_account_settings, :only => []
  before_filter :check_limited, :only => []
  
  
  
  def index
    jump_to("/account_settings/profile/session[:account_id]")
  end
  
  
  def profile
    
  end
  
  private
  
  def check_login_for_account_settings
    check_login {
      if session[:account_id].to_s == params[:id]
        @setting = AccountSetting.find(
          :first, :conditions => ["account_id = ?", session[:account_id]]
        ) || AccountSetting.new(:account_id => session[:account_id])
      else
        jump_to("/errors/forbidden")
      end
    }
  end
  
end


