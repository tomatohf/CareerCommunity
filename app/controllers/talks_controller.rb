class TalksController < ApplicationController
  
  Comment_Page_Size = 100
  Talk_Page_Size = 15
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
                                        :question_destroy, :create_comment, :delete_comment,
                                        :select_job_item, :add_job_item, :del_job_item,
                                        :add_job_process, :del_job_process,
                                        :job_tags, :add_job_tag, :del_job_tag, :auto_complete_for_job_tags,
                                        :destroy, :unpublished]
  before_filter :check_limited, :only => [:create, :update, :add_reporter, :del_reporter,
                                          :add_talker, :del_talker, :talker_create, :talker_update,
                                          :talker_destroy, :publish, :cancel_publish,
                                          :add_question_category, :del_question_category,
                                          :question_category_update, :add_question, :question_update,
                                          :answer_create, :answer_update, :answer_destroy, :question_destroy,
                                          :create_comment, :delete_comment, :add_job_item, :del_job_item,
                                          :add_job_process, :del_job_process,
                                          :add_job_tag, :del_job_tag, :auto_complete_for_job_tags,
                                          :destroy]
  
  before_filter :check_editor, :only => [:new, :create, :edit, :update, :manage, :add_reporter, :del_reporter,
                                          :add_talker, :del_talker, :talker_index, :talker_new, :talker_create,
                                          :talker, :talker_edit, :talker_update, :talker_destroy,
                                          :publish, :cancel_publish,
                                          :add_question_category, :del_question_category,
                                          :question_category_edit, :question_category_update, :add_question,
                                          :question_edit, :question_update, :answer_new, :answer_create,
                                          :answer_edit, :answer_update, :answer, :answer_destroy,
                                          :question_destroy, :delete_comment, :select_job_item,
                                          :add_job_item, :del_job_item, :add_job_process, :del_job_process,
                                          :job_tags, :add_job_tag, :del_job_tag, :auto_complete_for_job_tags,
                                          :destroy, :unpublished]
                                          
  before_filter :check_talk_publish, :only => [:show]
  
  skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_job_tags]
  
  
  
  ACKP_talks_feed = :ac_talks_feed
  
  caches_action :feed,
    :cache_path => Proc.new { |controller|
      ACKP_talks_feed.to_s
    },
    :if => Proc.new { |controller|
      controller.request.format.atom?
    }
  
  
  
  def index
    
    @page = params[:page]
    @page = 1 unless @page =~ /\d+/
    
    # @new_comments are cached in view
    
    respond_to do |format|
      format.html {
        @talks = Talk.get_talk_index_talks(@page)
      }
      
      format.json {
        render :layout => false
      }
    end
    
  end
  
  def feed
    respond_to do |format|
      format.html { jump_to("/talks") }
      
      format.atom {
        @talks = Talk.published.find(
          :all,
          :limit => Talk_Page_Size,
          :order => "publish_at DESC"
        )
        
        render :layout => false
      }
    end
  end
  
  def show
    @edit = is_info_editor?
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @talk_comments = @talk.comments.paginate(
      :page => page,
      :per_page => Comment_Page_Size,
      :total_entries => TalkComment.get_count(@talk.id),
      :order => "updated_at ASC"
    )
  end
  
  def create_comment
    comment = TalkComment.new(:account_id => session[:account_id])
    
    content = params[:talk_comment]
    talk_id = params[:id]
    
    comment_saved = false
    if talk_id && content
      comment.content = content.strip
      comment.talk_id = talk_id
      comment_saved = comment.save
    end
    
    total_count = TalkComment.get_count(comment.talk_id)
    last_page = total_count > 0 ? (total_count.to_f/Comment_Page_Size).ceil : 1
    
    jump_to("/talks/#{comment.talk_id}/comment/#{last_page}#{"#comment_#{comment.id}" if comment_saved}")
  end
  
  def delete_comment
    @talk_comment = TalkComment.find(params[:id])
    
    @talk_comment.destroy
    
    jump_to("/talks/#{@talk_comment.talk_id}")
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
      :summary => params[:talk_summary],
      :question_prefix => params[:talk_question_prefix],
      :answer_prefix => params[:talk_answer_prefix]
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
      :summary => params[:talk_summary],
      :question_prefix => params[:talk_question_prefix],
      :answer_prefix => params[:talk_answer_prefix]
    }
    @talk.update_info(talk_info)
    
    if @talk.save
      flash.now[:message] = "已成功保存"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end

    render :action => "edit"
  end
  
  def destroy
    talk = Talk.get_talk(params[:id])
    
    talk.destroy
    
    jump_to("/talks")
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
    
    @companies = Company.get_talk_companies(@talk.id)
    @job_positions = JobPosition.get_talk_job_positions(@talk.id)
    @industries = Industry.get_talk_industries(@talk.id)
    @job_processes = JobProcess.get_talk_job_processes(@talk.id)
    
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
    
    @answer.answer = params[:answer_answer]# && params[:answer_answer].strip
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
    
    @answer.answer = params[:answer_answer]# && params[:answer_answer].strip
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
    answer = TalkAnswer.get_answer(params[:id])
    
    answer.destroy
    
    jump_to("/talks/#{answer.talk_id}/manage")
  end
  
  def select_job_item
    @item_type = params[:type]
    @query = params[:query] && params[:query].strip
    
    @talk = Talk.get_talk(params[:id])
    
    @item_label = case @item_type
      when "company"
        "公司"
      when "job_position"
        "职位"
      when "industry"
        "行业"
      else
        nil
    end
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    
    if @query && @query != ""
      @items = @item_type.camelize.constantize.system.search(
        @query,
        :page => page,
        :per_page => JobItemsController::Item_Page_Size,
        :match_mode => JobItemsController::Search_Match_Mode,
        :order => JobItemsController::Search_Sort_Order,
        :field_weights => JobItemsController::Search_Field_Weights
      ).compact
    else
      @items = @item_type.camelize.constantize.system.find(
        :all,
        :limit => JobItemsController::Item_Page_Size,
        :order => "created_at DESC"
      )
    end
    
  end
  
  def add_job_item
    talk = Talk.get_talk(params[:id])
    item_type = params[:item_type]
    item_id = params[:item_id]
    
    item = item_type.camelize.constantize.send("get_#{item_type}", item_id)
    
    talk_items = talk.send(item_type.pluralize)
    
    talk_items << item unless talk_items.exists?(item)
    
    jump_to("/talks/#{talk.id}/manage")
  end
  
  def del_job_item
    talk = Talk.get_talk(params[:id])
    item_type = params[:item_type]
    item_id = params[:item_id]
    
    item = item_type.camelize.constantize.send("get_#{item_type}", item_id)
    
    talk.send(item_type.pluralize).delete(item)
    
    jump_to("/talks/#{talk.id}/manage")
  end
  
  def add_job_process
    talk = Talk.get_talk(params[:id])
    job_process_id = params[:job_process_id]
    
    job_process = JobProcess.get_process(job_process_id)
    talk_job_processes = talk.job_processes
    talk_job_processes << job_process unless talk_job_processes.exists?(job_process)
    
    jump_to("/talks/#{talk.id}/manage")
  end
  
  def del_job_process
    talk = Talk.get_talk(params[:id])
    job_process_id = params[:job_process_id]
    
    job_process = JobProcess.get_process(job_process_id)
    
    talk.job_processes.delete(job_process)
    
    jump_to("/talks/#{talk.id}/manage")
  end
  
  def job_tags
    @question = TalkQuestion.get_question(params[:id])
    @job_tags = JobTag.get_talk_question_tags(@question.id)
  end
  
  def auto_complete_for_job_tags
    partial_tag_names = params[:tag_names] && params[:tag_names].strip

    @names = JobTag.find(
      :all,
      :limit => 20,
      :conditions => ["name like ?", "%#{partial_tag_names}%"]
    ).collect do |tag|
      tag.name
    end
    
    render(:layout => false, :template => "/profiles/auto_complete_for_name.html.erb")
  end
  
  def add_job_tag
    question = TalkQuestion.get_question(params[:id])
    
    tag_names = params[:tag_names] && params[:tag_names].strip
    
    if tag_names && tag_names != ""
      tag_names.split(",").each do |tag_name|
        tag_name = tag_name && tag_name.strip
        
        if tag_name && tag_name != ""
          tag = JobTag.get_tag(tag_name)
          
          question_job_tags = question.job_tags
          question_job_tags << tag unless question_job_tags.exists?(tag)
        end
      end
    end
    
    jump_to("/talks/#{question.id}/job_tags")
  end
  
  def del_job_tag
    question = TalkQuestion.get_question(params[:id])
    job_tag_id = params[:job_tag_id]
    
    job_tag = JobTag.find(job_tag_id)
    
    question.job_tags.delete(job_tag)
    
    jump_to("/talks/#{question.id}/job_tags")
  end
  
  def unpublished
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @talks = Talk.unpublished.paginate(
      :page => page,
      :per_page => Talk_Page_Size,
      :order => "publish_at DESC"
    )
    
  end
  
  
  private
  
  def is_info_editor?
    ApplicationController.helpers.info_editor?(session[:account_id])
  end
  
  def check_editor
    jump_to("/errors/forbidden") unless is_info_editor?
  end
  
  def check_talk_publish
    @talk = Talk.get_talk(params[:id])
    
    jump_to("/errors/forbidden") unless @talk.published || is_info_editor?
  end
  
end

