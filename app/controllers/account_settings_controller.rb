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
  
  
  def module_index
    settings = @account_setting.get_setting
    @module_group_index = @account_setting.get_setting_value(:module_group_index, settings)
    @module_activity_index = @account_setting.get_setting_value(:module_activity_index, settings)
  end
  
  def set_module_index
    @module_group_index = params[:module_group_index] && params[:module_group_index].strip
    @module_activity_index = params[:module_activity_index] && params[:module_activity_index].strip
    
    module_index_setting = {
      :module_group_index => AccountSetting.valid_group_index_setting_values.include?(@module_group_index) ? @module_group_index : AccountSetting.default_value(:module_group_index),
      :module_activity_index => AccountSetting.valid_activity_index_setting_values.include?(@module_activity_index) ? @module_activity_index : AccountSetting.default_value(:module_activity_index)
    }
    
    @account_setting.update_setting(module_index_setting)
    
    if @account_setting.save
      flash.now[:message] = "设置已成功修改"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render(:action => "module_index")
  end
  
  
  def account_action
    settings = @account_setting.get_setting
    
    @setting_values = {}
    AccountAction.action_types.each do |key, value|
      @setting_values[key] = @account_setting.get_setting_value("hide_action_#{key}".to_sym, settings)
    end
  end
  
  def set_account_action
    account_action_setting = {}
    @setting_values = {}
    
    AccountAction.action_types.each do |key, value|
      symbol_key = key.to_sym
      setting_value = params[symbol_key] && params[symbol_key].strip
      
      setting_key = "hide_action_#{key}".to_sym
      account_action_setting[setting_key] = AccountSetting.valid_account_action_setting_values.include?(setting_value) ? setting_value : AccountSetting.default_value(setting_key)
      @setting_values[key] = account_action_setting[setting_key]
    end
    
    @account_setting.update_setting(account_action_setting)
    
    if @account_setting.save
      flash.now[:message] = "设置已成功修改"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render(:action => "account_action")
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


