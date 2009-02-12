class TalksController < ApplicationController
  
  Comment_Page_Size = 100
  Talk_Page_Size = 10
  
  New_Comment_Size = 30
  
  
  layout "community"
  before_filter :check_login, :only => [:new, :create, :edit, :update, :manage, :add_reporter, :del_reporter,
                                        :add_talker, :del_talker, :talker_index, :talker_new, :talker_create,
                                        :talker_edit, :talker_update, :talker_destroy]
  before_filter :check_limited, :only => [:create, :update, :add_reporter, :del_reporter,
                                          :add_talker, :del_talker, :talker_create, :talker_update,
                                          :talker_destroy]
  
  before_filter :check_editor, :only => [:new, :create, :edit, :update, :manage, :add_reporter, :del_reporter,
                                          :add_talker, :del_talker, :talker_index, :talker_new, :talker_create,
                                          :talker_edit, :talker_update, :talker_destroy]
  
  
  
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
    
  end
  
  def talker_new
    
  end
  
  def talker_create
    
  end
  
  def talker_edit
    
  end
  
  def talker_update
    
  end
  
  def talker_destroy
    
  end
  
  
  private
  
  def check_editor
    jump_to("/errors/forbidden") unless ApplicationController.helpers.talk_editor?(session[:account_id])
  end
  
  
end

