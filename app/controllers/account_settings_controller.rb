class AccountSettingsController < ApplicationController
  
  layout "community"
  before_filter :check_current_account, :only => [:index]
  before_filter :check_login_for_account_settings, :except => [:index]
  before_filter :check_limited, :check_request_type_post, :only => [:set_profile, :set_email]
  
  
  
  def index
    jump_to("/account_settings/profile/#{session[:account_id]}")
  end
  

  def profile
    settings = @account_setting.get_setting
    @profile_basic_visible = @account_setting.get_setting_value(:profile_basic_visible, settings)
    @profile_contact_visible = @account_setting.get_setting_value(:profile_contact_visible, settings)
    @profile_hobby_visible = @account_setting.get_setting_value(:profile_hobby_visible, settings)
    @profile_resume_visible = @account_setting.get_setting_value(:profile_resume_visible, settings)
  end
  
  def set_profile
    @profile_basic_visible = params[:profile_basic_visible] && params[:profile_basic_visible].strip
    @profile_contact_visible = params[:profile_contact_visible] && params[:profile_contact_visible].strip
    @profile_hobby_visible = params[:profile_hobby_visible] && params[:profile_hobby_visible].strip
    @profile_resume_visible = params[:profile_resume_visible] && params[:profile_resume_visible].strip
    
    profile_visible_setting = {
      :profile_basic_visible => AccountSetting.valid_profile_setting_values.include?(@profile_basic_visible) ? @profile_basic_visible : AccountSetting.default_value(:profile_basic_visible),
      :profile_contact_visible => AccountSetting.valid_profile_setting_values.include?(@profile_contact_visible) ? @profile_contact_visible : AccountSetting.default_value(:profile_contact_visible),
      :profile_hobby_visible => AccountSetting.valid_profile_setting_values.include?(@profile_hobby_visible) ? @profile_hobby_visible : AccountSetting.default_value(:profile_hobby_visible),
      :profile_resume_visible => AccountSetting.valid_profile_setting_values.include?(@profile_resume_visible) ? @profile_resume_visible : AccountSetting.default_value(:profile_resume_visible)
    }
    
    @account_setting.update_setting(profile_visible_setting)
    
    if @account_setting.save
      flash.now[:message] = "设置已成功修改"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render(:action => "profile")
  end
  
  def email
    settings = @account_setting.get_setting
    @email_message_notify = @account_setting.get_setting_value(:email_message_notify, settings)
    @email_group_invitation_notify = @account_setting.get_setting_value(:email_group_invitation_notify, settings)
    @email_activity_invitation_notify = @account_setting.get_setting_value(:email_activity_invitation_notify, settings)
  end
  
  def set_email
    @email_message_notify = params[:email_message_notify] && params[:email_message_notify].strip
    @email_group_invitation_notify = params[:email_group_invitation_notify] && params[:email_group_invitation_notify].strip
    @email_activity_invitation_notify = params[:email_activity_invitation_notify] && params[:email_activity_invitation_notify].strip
    @email_vote_invitation_notify = params[:email_vote_invitation_notify] && params[:email_vote_invitation_notify].strip
    
    email_notify_setting = {
      :email_message_notify => AccountSetting.valid_email_setting_values.include?(@email_message_notify) ? @email_message_notify : AccountSetting.default_value(:email_message_notify),
      :email_group_invitation_notify => AccountSetting.valid_email_setting_values.include?(@email_group_invitation_notify) ? @email_group_invitation_notify : AccountSetting.default_value(:email_group_invitation_notify),
      :email_activity_invitation_notify => AccountSetting.valid_email_setting_values.include?(@email_activity_invitation_notify) ? @email_activity_invitation_notify : AccountSetting.default_value(:email_activity_invitation_notify),
      :email_vote_invitation_notify => AccountSetting.valid_email_setting_values.include?(@email_vote_invitation_notify) ? @email_vote_invitation_notify : AccountSetting.default_value(:email_vote_invitation_notify)
    }
    
    @account_setting.update_setting(email_notify_setting)
    
    if @account_setting.save
      flash.now[:message] = "设置已成功修改"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render(:action => "email")
  end
  
  
  private
  
  def check_login_for_account_settings
    @account_id = params[:id]
    
    check_login {
      if session[:account_id].to_s == @account_id
        @account_setting = AccountSetting.find(
          :first, :conditions => ["account_id = ?", session[:account_id]]
        ) || AccountSetting.new(:account_id => session[:account_id])
      else
        jump_to("/errors/forbidden")
      end
    }
  end
  
  def check_request_type_post
    jump_to("/account_settings/#{action_name[4..-1]}/#{session[:account_id]}") unless request.post?
  end
  
end


