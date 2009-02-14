class TalksController < ApplicationController
  
  Comment_Page_Size = 100
  Talk_Page_Size = 10
  Talker_Page_Size = 20
  
  New_Comment_Size = 30
  
  
  layout "community"
  before_filter :check_login, :only => [:new, :create, :edit, :update, :manage, :add_reporter, :del_reporter,
                                        :add_talker, :del_talker, :talker_index, :talker_new, :talker_create,
                                        :talker, :talker_edit, :talker_update, :talker_destroy,
                                        :publish, :cancel_publish,
                                        :add_question_category, :del_question_category,
                                        :question_category_edit, :question_category_update, :add_question,
                                        :question_edit, :question_update, :answer_new, :answer_create,
                                        :answer_edit, :answer_update, :answer, :answer_destroy,
                                        :question_destroy]
  before_filter :check_limited, :only => [:create, :update, :add_reporter, :del_reporter,
                                          :add_talker, :del_talker, :talker_create, :talker_update,
                                          :talker_destroy, :publish, :cancel_publish,
                                          :add_question_category, :del_question_category,
                                          :question_category_update, :add_question, :question_update,
                                          :answer_create, :answer_update, :answer_destroy, :question_destroy]
  
  before_filter :check_editor, :only => [:new, :create, :edit, :update, :manage, :add_reporter, :del_reporter,
                                          :add_talker, :del_talker, :talker_index, :talker_new, :talker_create,
                                          :talker, :talker_edit, :talker_update, :talker_destroy,
                                          :publish, :cancel_publish,
                                          :add_question_category, :del_question_category,
                                          :question_category_edit, :question_category_update, :add_question,
                                          :question_edit, :question_update, :answer_new, :answer_create,
                                          :answer_edit, :answer_update, :answer, :answer_destroy,
                                          :question_destroy]
  
  
  
  def index
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @talks = Talk.published.paginate(
      :page => page,
      :per_page => Talk_Page_Size,
      :order => "publish_at DESC"
    )
    
    @new_comments = TalkComment.find(
      :all,
      :limit => New_Comment_Size,
      :include => [:account => [:profile_pic]],
      :order => "updated_at DESC"
    )
    
  end
  
  def show
    
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
  
  def publish
    talk = Talk.get_talk(params[:id])
    talk.updater_id = session[:account_id]
    
    talk.published = true
    talk.publish_at = DateTime.now
    
    talk.save
    
    jump_to("/talks/#{talk.id}/manage")
  end
  
  def cancel_publish
    talk = Talk.get_talk(params[:id])
    talk.updater_id = session[:account_id]
    
    talk.published = false
    
    talk.save
    
    jump_to("/talks/#{talk.id}/manage")
  end
  
  def manage
    @talk = Talk.get_talk(params[:id])
    @talk_info = @talk.get_info
    
    @reporters = TalkReporter.get_talk_reporters(@talk.id)
    @talkers = TalkTalker.get_talk_talkers(@talk.id)
    
    @question_categories = TalkQuestionCategory.get_talk_question_categories(@talk.id)
    
    @questions = TalkQuestion.get_talk_questions(@talk.id)
    
    @talkers_mapping = {}
    @talkers.each do |talker|
      @talkers_mapping[talker[1].id] = talker[1]
    end
    
    @question_categories_mapping = {}
    @question_categories.each do |category|
      @question_categories_mapping[category.id] = category
    end
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
    talk_id = params[:id]
    talker_id = params[:talker_id]
    
    talk_talker = TalkTalker.new(
      :talk_id => talk_id,
      :talker_id => talker_id
    )
    
    talk_talker.save
    
    jump_to("/talks/#{talk_id}/manage")
  end
  
  def del_talker
    talk_id = params[:id]
    talk_talker_id = params[:talk_talker_id]
    
    talk_talker = TalkTalker.find(talk_talker_id)
    
    talk_talker.destroy if talk_talker.talk_id.to_s == talk_id
    
    jump_to("/talks/#{talk_id}/manage")
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
  
  def add_question_category
    talk_id = params[:id]
    category_name = params[:category_name] && params[:category_name].strip
    category_desc = params[:category_desc] && params[:category_desc].strip
    
    question_category = TalkQuestionCategory.new(
      :talk_id => talk_id,
      :creator_id => session[:account_id],
      :updater_id => session[:account_id],
      :name => category_name,
      :desc => category_desc
    )
    
    question_category.save
    
    jump_to("/talks/#{talk_id}/manage")
  end
  
  def del_question_category
    talk_id = params[:id]
    question_category_id = params[:question_category_id]
    
    question_category = TalkQuestionCategory.find(question_category_id)
    
    question_category.destroy if question_category.talk_id.to_s == talk_id
    
    jump_to("/talks/#{talk_id}/manage")
  end
  
  def question_category_edit
    @question_category = TalkQuestionCategory.find(params[:id])
  end
  
  def question_category_update
    @question_category = TalkQuestionCategory.find(params[:id])
    @question_category.updater_id = session[:account_id]
    
    @question_category.name = params[:category_name] && params[:category_name].strip
    @question_category.desc = params[:category_desc] && params[:category_desc].strip
    
    if @question_category.save
      flash.now[:message] = "已成功保存"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end

    render :action => "question_category_edit"
  end
  
  def add_question
    talk_id = params[:id]
    question_question = params[:question_question] && params[:question_question].strip
    question_category = params[:question_category] && params[:question_category].strip
    question_summary = params[:question_summary] && params[:question_summary].strip
    
    question = TalkQuestion.new(
      :talk_id => talk_id,
      :creator_id => session[:account_id],
      :updater_id => session[:account_id],
      :question => question_question,
      :category_id => question_category,
      :summary => question_summary
    )
    
    question.save
    
    jump_to("/talks/#{talk_id}/manage")
  end
  
  def question_edit
    @question = TalkQuestion.get_question(params[:id])
  end
  
  def question_update
    @question = TalkQuestion.get_question(params[:id])
    @question.updater_id = session[:account_id]
    
    @question.question = params[:question_question] && params[:question_question].strip
    @question.category_id = params[:question_category] && params[:question_category].strip
    @question.summary = params[:question_summary] && params[:question_summary].strip
    
    if @question.save
      flash.now[:message] = "已成功保存"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end

    render :action => "question_edit"
  end
  
  def question_destroy
    @question = TalkQuestion.get_question(params[:id])
    
    @question.destroy
    
    jump_to("/talks/#{@question.talk_id}/manage")
  end
  
  def answer_new
    @question = TalkQuestion.get_question(params[:id])
    @answer = TalkAnswer.new
  end
  
  def answer_create
    @question = TalkQuestion.get_question(params[:id])
    @answer = TalkAnswer.new(
      :creator_id => session[:account_id],
      :updater_id => session[:account_id],
      :talk_id => @question.talk_id,
      :question_id => @question.id
    )
    
    @answer.talker_id = params[:answer_talker]
    
    @answer.answer = params[:answer_answer] && params[:answer_answer].strip
    @answer.summary = params[:answer_summary] && params[:answer_summary].strip
    
    if @answer.save
      jump_to("/talks/#{@question.talk_id}/manage")
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
      render :action => "answer_new"
    end
  end
  
  def answer_edit
    @answer = TalkAnswer.get_answer(params[:id])
    @question = TalkQuestion.get_question(@answer.question_id)
  end
  
  def answer_update
    @answer = TalkAnswer.get_answer(params[:id])
    @question = TalkQuestion.get_question(@answer.question_id)
    
    @answer.updater_id = session[:account_id]
    
    @answer.talker_id = params[:answer_talker]
    
    @answer.answer = params[:answer_answer] && params[:answer_answer].strip
    @answer.summary = params[:answer_summary] && params[:answer_summary].strip
    
    if @answer.save
      flash.now[:message] = "已成功保存"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end

    render :action => "answer_edit"
  end
  
  def answer
    @answer = TalkAnswer.get_answer(params[:id])
    @question = TalkQuestion.get_question(@answer.question_id)
  end
  
  def answer_destroy
    @answer = TalkAnswer.get_answer(params[:id])
    
    @answer.destroy
    
    jump_to("/talks/#{@answer.talk_id}/manage")
  end
  
  
  private
  
  def check_editor
    jump_to("/errors/forbidden") unless ApplicationController.helpers.talk_editor?(session[:account_id])
  end
  
  
end

