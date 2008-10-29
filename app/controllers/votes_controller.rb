class VotesController < ApplicationController
  
  Topic_List_Size = 6
  
  Comment_Page_Size = 100
  
  Vote_Option_Limit = 20
  
  Created_Topic_List_Size = 10
  
  layout "community"
  before_filter :check_login, :only => [:new, :new_in_group, :vote_groups, :create,
                                        :edit_image, :update_image,
                                        :create_comment, :delete_comment, :vote_to_option,
                                        :clear_vote_record, :edit, :update, :destroy,
                                        :edit_option, :create_new_option, :add_new_option,
                                        :delete_others_option]
  before_filter :check_limited, :only => [:create, :update_image, :create_comment, :delete_comment,
                                          :vote_to_option, :clear_vote_record, :update, :destroy,
                                          :create_new_option, :delete_others_option]
  
  before_filter :check_vote_groups_account, :only => [:vote_groups]
  
  before_filter :check_vote_topic_owner, :only => [:edit_image, :update_image, :edit, :update,
                                                  :destroy, :edit_option, :delete_others_option]
  
  before_filter :check_comment_owner, :only => [:delete_comment]
  
  
  
  def index
    jump_to("/votes/latest")
  end
  
  def latest
    @page_title = "最新投票话题"
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @vote_topics = VoteTopic.paginate(
      :page => page,
      :per_page => Topic_List_Size,
      :include => [:image, :account],
      :order => "created_at DESC"
    )
    
    render :action => "topic_list"
  end
  
  def hotest
    @page_title = "最热投票话题"
    
    latest
  end
  
  def list
    @account_id = params[:id]
    
    @edit = session[:account_id].to_s == @account_id
    
    @account_nick_pic = Account.get_nick_and_pic(@account_id) unless @edit
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @vote_topics = VoteTopic.paginate(
      :page => page,
      :per_page => Topic_List_Size,
      :conditions => ["account_id = ?", @account_id],
      :include => [:image, :account],
      :order => "created_at DESC"
    )
  end
  
  def category
    category_id = params[:id]
    
    category_name = VoteCategory.get_category(category_id)
    
    @page_title = "投票话题: #{category_name}"
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @vote_topics = VoteTopic.paginate(
      :page => page,
      :per_page => Topic_List_Size,
      :conditions => ["category_id = ?", category_id],
      :include => [:image, :account],
      :order => "created_at DESC"
    )
    
    render :action => "topic_list"
  end
  
  
  def new
    @vote_topic = VoteTopic.new
    
    @option_titles = {}
    @option_colors = {}
  end
  
  def new_in_group
    @group_with_image = Group.get_group_with_image(params[:group_id])
    new
    render(:action => "new")
  end
  
  def vote_groups
    @account_id = params[:id]
    
    @group_members = GroupMember.agreed.find(
      :all,
      :conditions => ["account_id = ?", @account_id],
      :include => [:group => [:image]],
      :order => "join_at DESC"
    )
  end
  
  def create
    @vote_topic = VoteTopic.new(:account_id => session[:account_id])
    
    @vote_topic.group_id = params[:group_id] || 0
    # check group member
    if @vote_topic.group_id && @vote_topic.group_id > 0
      return jump_to("/errors/forbidden") unless GroupMember.is_group_member(@vote_topic.group_id, session[:account_id])
      
      @group_with_image = Group.get_group_with_image(@vote_topic.group_id)
    end
    
    
    @vote_topic.title = params[:vote_topic_title] && params[:vote_topic_title].strip
    @vote_topic.desc = params[:vote_topic_desc] && params[:vote_topic_desc].strip
    
    @vote_topic.category_id = params[:vote_topic_category_id]
    @vote_topic.multiple = (params[:vote_topic_multiple] == "true")
    @vote_topic.allow_add_option = (params[:vote_topic_allow_add_option] == "true")
    @vote_topic.allow_clear_record = (params[:vote_topic_allow_clear_record] == "true")
    
    # collect vote options
    @option_titles = {}
    @option_colors = {}
    1.upto(Vote_Option_Limit) { |i|
      @option_titles["vote_option_#{i}".to_sym] = params["vote_option_#{i}".to_sym]
      @option_colors["vote_option_#{i}_color_field".to_sym] = params["vote_option_#{i}_color_field".to_sym]
    }
    
    filled_options = @option_titles.select { |k, v|
      v && (v.strip != "")
    }
    
    unless filled_options.size > 0
      flash.now[:error_msg] = "还没有指定任何选项"
      return render(:action => "new")
    end
    

    if @vote_topic.save
      # save vote options
      filled_options.each do |option|
        vote_option = VoteOption.new(
          :account_id => session[:account_id],
          :vote_topic_id => @vote_topic.id,
          :title => option[1],
          :color => @option_colors["#{option[0]}_color_field".to_sym]
        )
        vote_option.save
      end
      
      # record account action
      AccountAction.create_new(session[:account_id], "create_vote_topic", {
        :vote_topic_id => @vote_topic.id
      })
      
      return render(:action => "edit_image")
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render(:action => "new")
  end
  
  def edit_image
    
  end
  
  def update_image
    vote_image = VoteImage.get_by_vote_topic(@vote_topic_id) || VoteImage.new(:vote_topic_id => @vote_topic_id)
    
    old_photo_id = vote_image.photo_id
    vote_image.photo_id = params[:photo_id]
    
    # validate the photo
    if vote_image.photo_id && vote_image.photo_id != old_photo_id
      photo = vote_image.photo
      if photo && photo.account_id == session[:account_id]
        vote_image.pic_url = photo.image.url(:thumb_48)
        if vote_image.save
          VoteTopic.update_vote_topic_with_image_cache(@vote_topic_id, :vote_img => vote_image.pic_url)
          flash.now[:message] = "已成功保存"
        else
          flash.now[:error_msg] = "操作失败, 再试一次吧"
        end
      else
        jump_to("/errors/forbidden")
      end
    end
  end
  
  def photo_selector_for_vote_image
    albums = Album.get_all_names_by_account_id(session[:account_id])
    render :partial => "albums/photo_selector", :locals => {:albums => albums, :photo_list_template => "/profiles/album_photo_list_for_face"}
  end
  
  def create_comment
    vote_comment = VoteComment.new(:account_id => session[:account_id])
    
    content = params[:vote_comment]
    vote_topic_id = params[:id]
    
    comment_saved = false
    if vote_topic_id && content
      vote_comment.content = content.strip
      vote_comment.vote_topic_id = vote_topic_id
      comment_saved = vote_comment.save
    end
    
    total_count = VoteComment.get_count(vote_comment.vote_topic_id)
    last_page = total_count > 0 ? (total_count.to_f/Comment_Page_Size).ceil : 1
    
    jump_to("/votes/#{vote_topic_id}/comment/#{last_page}#{"#comment_#{vote_comment.id}" if comment_saved}")
  end
  
  def delete_comment
    @vote_comment.destroy
    
    jump_to("/votes/#{@vote_comment.vote_topic_id}")
  end
  
  def show
    @vote_topic_id = params[:id]
    @vote_topic, @vote_image = VoteTopic.get_vote_topic_with_image(@vote_topic_id)
    
    @chart_type = params[:chart_type]
    
    @account_id = @vote_topic.account_id
    @account_nick_pic = Account.get_nick_and_pic(@account_id)
    
    @voter_count = VoteRecord.get_voter_count(@vote_topic_id)
    
    @edit = (@account_id == session[:account_id])
    
    group_id = @vote_topic.group_id || 0
    @group, @group_image = Group.get_group_with_image(group_id) if group_id > 0
    
    @page = params[:page]
    @page = 1 unless @page =~ /\d+/
    @vote_comments = @vote_topic.comments.paginate(
      :page => @page,
      :per_page => Comment_Page_Size,
      :total_entries => VoteComment.get_count(@vote_topic.id),
      :include => [:account => [:profile_pic]],
      :order => "created_at ASC"
    )
    
    @voted_records = {}
    related_account_ids = []
    @vote_comments.each { |vc|
      comment_account_id = vc.account_id
      related_account_ids << comment_account_id
      @voted_records[comment_account_id] = []
    }
    related_records = VoteRecord.find(:all, :conditions => ["vote_topic_id = ? and account_id in (?)", @vote_topic_id, related_account_ids])
    related_records.each { |rr|
      @voted_records[rr.account_id] << rr
    }
    
    @created_vote_topics = VoteTopic.find(
      :all,
      :limit => Created_Topic_List_Size,
      :conditions => ["account_id = ?", @vote_topic.account_id],
      :order => "created_at DESC"
    )
  end
  
  def vote_to_option
    option_ids = params[:option_ids] || []
    
    if option_ids.size > 0
      vote_topic_id = params[:id]
      vote_topic, vote_image = VoteTopic.get_vote_topic_with_image(vote_topic_id)
    
      group_id = vote_topic.group_id || 0
      group, group_image = Group.get_group_with_image(group_id) if group_id > 0
      not_group_member = group && (!GroupMember.is_group_member(group.id, session[:account_id]))
      
      unless not_group_member
        
        records = VoteRecord.get_voted_records(vote_topic_id, session[:account_id])
        unless records.size > 0
          
          to_be_saved_ids = []
          if vote_topic.multiple
            to_be_saved_ids = option_ids
          else
            to_be_saved_ids << option_ids[0]
          end
          
          vote_option_ids = VoteOption.get_vote_topic_options(vote_topic_id).collect { |o| o[0].to_s }
          
          has_record_saved = false
          to_be_saved_ids.each do |option_id|
            if vote_option_ids.include?(option_id)
              vote_record = VoteRecord.new(
                :account_id => session[:account_id],
                :vote_topic_id => vote_topic_id,
                :vote_option_id => option_id,
                :voter_ip => request.remote_ip
              )
              vote_record_saved = vote_record.save
              
              has_record_saved ||= vote_record_saved
            end
          end
          
          # record account action
          AccountAction.create_new(session[:account_id], "join_vote_topic", {
            :vote_topic_id => vote_topic_id,
            :voter_ip => request.remote_ip
          }) if has_record_saved
          
        end
        
      end
    
    end
    
    jump_to("/votes/#{vote_topic_id}")
    
  end
  
  def clear_vote_record
    vote_topic_id = params[:id]
    
    vote_topic, vote_image = VoteTopic.get_vote_topic_with_image(vote_topic_id)
    
    VoteRecord.find(
      :all,
      :conditions => ["vote_topic_id = ? and account_id = ?", vote_topic_id, session[:account_id]]
    ).each { |record| record.destroy } if vote_topic.allow_clear_record
    
    jump_to("/votes/#{vote_topic_id}")
  end
  
  def edit
    
  end
  
  def update
    @vote_topic.category_id = params[:vote_topic_category_id]
    @vote_topic.multiple = (params[:vote_topic_multiple] == "true")
    @vote_topic.allow_add_option = (params[:vote_topic_allow_add_option] == "true")
    @vote_topic.allow_clear_record = (params[:vote_topic_allow_clear_record] == "true")
    
    if @vote_topic.save
      VoteTopic.update_vote_topic_with_image_cache(@vote_topic_id, :vote_topic => @vote_topic)
      flash.now[:message] = "投票设置已成功修改"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render(:action => "edit")
  end
  
  def destroy
    @vote_topic.destroy
    
    jump_to("/votes")
  end
  
  def edit_option
    @options = VoteOption.get_vote_topic_options(@vote_topic_id)
    @option_number_limit = Vote_Option_Limit
    @owner_id = @vote_topic.account_id
  end
  
  def create_new_option
    vote_topic_id = params[:id]
    vote_topic, vote_image = VoteTopic.get_vote_topic_with_image(vote_topic_id)
    
    if (vote_topic.account_id == session[:account_id]) || vote_topic.allow_add_option
      # valid to add new option
      
      new_vote_option = params[:new_vote_option] && params[:new_vote_option].strip
      new_vote_option_color = params[:new_vote_option_color_field]
      
      if new_vote_option && new_vote_option != ""
        if VoteOption.get_vote_topic_options(vote_topic_id).size < Vote_Option_Limit
          vote_option = VoteOption.new(
            :account_id => session[:account_id],
            :vote_topic_id => vote_topic_id,
            :title => new_vote_option,
            :color => new_vote_option_color
          )
          vote_option.save
        end
      end
    end
    
    jump_to("/votes/#{vote_topic_id}")
  end
  
  def add_new_option
    @vote_topic_id = params[:id]
    @vote_topic, @vote_image = VoteTopic.get_vote_topic_with_image(@vote_topic_id)
    
    if @vote_topic.allow_add_option
      @option_number_limit = Vote_Option_Limit
      @options_size = VoteOption.get_vote_topic_options(@vote_topic_id).size
    else
      jump_to("/votes/#{@vote_topic_id}")
    end
  end
  
  def delete_others_option
    option_id = params[:option_id]
    
    options = VoteOption.get_vote_topic_options(@vote_topic_id)
    
    to_be_deleted_options = options.select { |o| o[0].to_s == option_id }
    
    if to_be_deleted_options.size > 0
      to_be_deleted_option = to_be_deleted_options[0]
      VoteOption.destroy(to_be_deleted_option[0]) if to_be_deleted_option[3] != @vote_topic.account_id
    end
    
    jump_to("/votes/#{@vote_topic_id}/edit_option")
  end
  
  
  #==========
  
  def preview_topic
    vote_topic_id = params[:id]
    chart_type = params[:chart_type]
    vote_topic, vote_image = VoteTopic.get_vote_topic_with_image(vote_topic_id)

    render(:partial => "topic_preview", :locals => {:vote_topic => vote_topic, :chart_type => chart_type})
  end
  
  def refresh_vote_result
    topic_id = params[:id]
    chart_type = params[:chart_type]
    graph = build_graph(topic_id, chart_type, :get_count_by_option)
    render(:xml => graph.to_xml)
  end
  
  
  
  private
  
  def check_vote_groups_account
    jump_to("/votes/vote_groups/#{session[:account_id]}") unless session[:account_id].to_s == params[:id]
  end
  
  def check_vote_topic_owner
    @vote_topic_id = params[:id]
    @vote_topic, @vote_image = VoteTopic.get_vote_topic_with_image(@vote_topic_id)
    
    jump_to("/errors/forbidden") unless @vote_topic.account_id == session[:account_id]
  end
  
  def check_comment_owner
    @vote_comment = VoteComment.find(params[:id])
    jump_to("/errors/forbidden") unless session[:account_id] == (@vote_comment.vote_topic && @vote_comment.vote_topic.account_id)
  end
  
  
  #==========
  
  def get_graph(chart_type, chart_id = "vote_result")
    chart_title = "投票结果"
    case chart_type
      when "bar_h"
        graph = Ziya::Charts::Bar.new(nil, chart_title, chart_id)
      when "pie"
        graph = Ziya::Charts::Pie.new(nil, chart_title, chart_id)
      when "pie_3d"
        graph = Ziya::Charts::Pie3D.new(nil, chart_title, chart_id)
      when "line"
        graph = Ziya::Charts::Line.new(nil, chart_title, chart_id + "_line")
      else
        graph = Ziya::Charts::Bar.new(nil, chart_title, chart_id)
    end
    graph
  end
  
  # build graph for "refresh_vote_result" and "refresh_cross_analysis_result", which are divided by options
  def build_graph(topic_id, chart_type, count_function, count_args = [])
    options = VoteOption.get_vote_topic_options(topic_id)
    series = []
    categories = []
    colors = []
    
    options.each_index do |i|
      o = options[i]
    
      count = VoteRecord.send(count_function, o[0], *count_args)
      series << count
      
      # 65.chr = A
      category_text = (i + 65).chr
      category_text = category_text + ":#{count}"
      categories << category_text
      colors << if o[2]
                  o[2]
                else
                  ApplicationController.helpers.get_random_init_color
                end
    end
    
    build_graph_generally(chart_type, categories, series, colors)
  end
  
#  def build_graph_for_refresh_vote_constituent_result(topic_id, chart_type, count_function, use_index)
#    categories, series = VoteRecord.send(count_function, topic_id)
#    colors = []
#    categories_index = []
#    categories.size.times do |i|
#      categories_index << (i+65).chr
#      colors << ApplicationController.helpers.get_random_init_color
#    end
#    build_graph_generally(chart_type, use_index ? categories_index : categories, series, colors)
#  end
  
  def build_graph_generally(chart_type, categories, series, colors)
    graph  = get_graph(chart_type)
    graph.add(:axis_category_text, categories)
    graph.add(:series, "series legend label", series)
    graph.add(:theme, "vote")
    graph.add(:user_data, :colors, colors.join(","))
    graph.add(:user_data, :delay_count, series.size - 1)
    graph
  end
  
end  
  
  