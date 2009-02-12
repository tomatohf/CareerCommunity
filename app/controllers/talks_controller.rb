class TalksController < ApplicationController
  
  Comment_Page_Size = 100
  Talk_Page_Size = 10
  Talker_Page_Size = 20
  
  New_Comment_Size = 30
  
  
  layout "community"
  before_filter :check_login, :only => [:new, :create, :edit, :update, :manage, :add_reporter, :del_reporter,
                                        :add_talker, :del_talker, :talker_index, :talker_new, :talker_create,
                                        :talker, :talker_edit, :talker_update, :talker_destroy]
  before_filter :check_limited, :only => [:create, :update, :add_reporter, :del_reporter,
                                          :add_talker, :del_talker, :talker_create, :talker_update,
                                          :talker_destroy]
  
  before_filter :check_editor, :only => [:new, :create, :edit, :update, :manage, :add_reporter, :del_reporter,
                                          :add_talker, :del_talker, :talker_index, :talker_new, :talker_create,
                                          :talker, :talker_edit, :talker_update, :talker_destroy]
  
  
  
  def index
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @talks = Talk.published.paginate(
      :page => page,
      :per_page => Talk_Page_Size,
      :order => "created_at DESC"
    )
    
    @new_comments = TalkComment.find(
      :all,
      :limit => New_Comment_Size,
      :include => [:account => [:profile_pic]],
      :order => "updated_at DESC"
    )
    
  end
  
  
  
  # editor actions
  
  def new
    @talk = Talk.new
  end
  
  def create
    @talk = Talk.new(:creator_id => session[:account_id], :updater_id => session[:account_id])
    
    @talk.title = params[:talk_title] && params[:talk_title].strip
    @talk.sn = params[:talk_sn] && params[:talk_sn].strip
    @talk.place = params[:talk_place] && params[:talk_place].strip
    
    ba = params[:talk_begin_at]
    @talk.begin_at = Time.local(ba[:year], ba[:month], ba[:day], ba[:hour], ba[:minute]) rescue nil
    
    ea = params[:talk_end_at]
    @talk.end_at = Time.local(ea[:year], ea[:month], ea[:day], ea[:hour], ea[:minute]) rescue nil
    
    talk_info = {
      :desc => params[:talk_desc],
      :summary => params[:talk_summary]
    }
    @talk.fill_info(talk_info)
    
    if @talk.save
      jump_to("/talks/#{@talk.id}/manage")
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
      render :action => "new"
    end
  end
  
  def edit
    @talk = Talk.get_talk(params[:id])
  end
  
  def update
    @talk = Talk.get_talk(params[:id])
    @talk.updater_id = session[:account_id]
    
    @talk.title = params[:talk_title] && params[:talk_title].strip
    @talk.sn = params[:talk_sn] && params[:talk_sn].strip
    @talk.place = params[:talk_place] && params[:talk_place].strip
    
    ba = params[:talk_begin_at]
    @talk.begin_at = Time.local(ba[:year], ba[:month], ba[:day], ba[:hour], ba[:minute]) rescue nil
    
    ea = params[:talk_end_at]
    @talk.end_at = Time.local(ea[:year], ea[:month], ea[:day], ea[:hour], ea[:minute]) rescue nil
    
    talk_info = {
      :desc => params[:talk_desc],
      :summary => params[:talk_summary]
    }
    @talk.update_info(talk_info)
    
    if @talk.save
      flash.now[:message] = "已成功保存"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end

    render :action => "edit"
  end
  
  def manage
    @talk = Talk.get_talk(params[:id])
    
    @reporters = TalkReporter.get_talk_reporters(@talk.id)
  end
  
  def add_reporter
    talk_id = params[:id]
    reporter_name = params[:reporter_name] && params[:reporter_name].strip
    
    talk_reporter = TalkReporter.new(
      :talk_id => talk_id,
      :name => reporter_name
    )
    
    talk_reporter.save
    
    jump_to("/talks/#{talk_id}/manage")
  end
  
  def del_reporter
    talk_id = params[:id]
    reporter_id = params[:reporter_id] && params[:reporter_id].strip
    
    talk_reporter = TalkReporter.find(reporter_id)
    
    talk_reporter.destroy if talk_reporter.talk_id.to_s == talk_id
    
    jump_to("/talks/#{talk_id}/manage")
  end
  
  def add_talker
    
  end
  
  def del_talker
    
  end
  
  def talker_index
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @talkers = Talker.paginate(
      :page => page,
      :per_page => Talker_Page_Size,
      :order => "created_at DESC"
    )
  end
  
  def talker_new
    @talker = Talker.new
  end
  
  def talker_create
    @talker = Talker.new()
    
    @talker.real_name = params[:talker_real_name] && params[:talker_real_name].strip
    @talker.gender = case params[:talker_gender]
      when "true"
        true
      when "false"
        false
      else
        nil
    end
    @talker.age = params[:talker_age] && params[:talker_age].strip
    @talker.nick = params[:talker_nick] && params[:talker_nick].strip
    
    @talker.company = params[:talker_company] && params[:talker_company].strip
    @talker.position = params[:talker_position] && params[:talker_position].strip
    
    @talker.email = params[:talker_email] && params[:talker_email].strip
    @talker.mobile = params[:talker_mobile] && params[:talker_mobile].strip
    @talker.phone = params[:talker_phone] && params[:talker_phone].strip
    
    @talker.msn = params[:talker_msn] && params[:talker_msn].strip
    @talker.gtalk = params[:talker_gtalk] && params[:talker_gtalk].strip
    @talker.qq = params[:talker_qq] && params[:talker_qq].strip
    @talker.skype = params[:talker_skype] && params[:talker_skype].strip
    
    @talker.experience = params[:talker_experience] && params[:talker_experience].strip
    
    @talker.other = params[:talker_other] && params[:talker_other].strip
    
    if @talker.save
      jump_to("/talks/talker_index")
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
      render :action => "talker_new"
    end
  end
  
  def talker
    @talker = Talker.get_talker(params[:id])
  end
  
  def talker_edit
    @talker = Talker.get_talker(params[:id])
  end
  
  def talker_update
    @talker = Talker.get_talker(params[:id])
    
    @talker.real_name = params[:talker_real_name] && params[:talker_real_name].strip
    @talker.gender = case params[:talker_gender]
      when "true"
        true
      when "false"
        false
      else
        nil
    end
    @talker.age = params[:talker_age] && params[:talker_age].strip
    @talker.nick = params[:talker_nick] && params[:talker_nick].strip
    
    @talker.company = params[:talker_company] && params[:talker_company].strip
    @talker.position = params[:talker_position] && params[:talker_position].strip
    
    @talker.email = params[:talker_email] && params[:talker_email].strip
    @talker.mobile = params[:talker_mobile] && params[:talker_mobile].strip
    @talker.phone = params[:talker_phone] && params[:talker_phone].strip
    
    @talker.msn = params[:talker_msn] && params[:talker_msn].strip
    @talker.gtalk = params[:talker_gtalk] && params[:talker_gtalk].strip
    @talker.qq = params[:talker_qq] && params[:talker_qq].strip
    @talker.skype = params[:talker_skype] && params[:talker_skype].strip
    
    @talker.experience = params[:talker_experience] && params[:talker_experience].strip
    
    @talker.other = params[:talker_other] && params[:talker_other].strip
    
    if @talker.save
      flash.now[:message] = "已成功保存"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end

    render :action => "talker_edit"
  end
  
  def talker_destroy
    @talker = Talker.get_talker(params[:id])
    
    @talker.destroy
    
    jump_to("/talks/talker_index")
  end
  
  
  private
  
  def check_editor
    jump_to("/errors/forbidden") unless ApplicationController.helpers.talk_editor?(session[:account_id])
  end
  
  
end

