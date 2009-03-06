class VotesController < ApplicationController
  
  Topic_List_Size = 6
  
  Comment_Page_Size = 100
  
  Vote_Option_Limit = 20
  
  Created_Topic_List_Size = 10
  
  
  layout "community"
  before_filter :check_current_account, :only => [:list_group_index]
  before_filter :check_login, :only => [:new, :new_in_group, :vote_groups, :create,
                                        :edit_image, :update_image,
                                        :create_comment, :delete_comment,
                                        #:vote_to_option, :clear_vote_record,
                                        :edit, :update, :destroy,
                                        :edit_option, :create_new_option, :add_new_option,
                                        :delete_others_option, :invite, :invite_member,
                                        :invite_contact, :select_contact, :send_contact_invitations]
  before_filter :check_limited, :only => [:create, :update_image, :create_comment, :delete_comment,
                                          #:vote_to_option, :clear_vote_record,
                                          :update, :destroy,
                                          :create_new_option, :delete_others_option, :invite_member,
                                          :send_contact_invitations]
  
  before_filter :check_vote_groups_account, :only => [:vote_groups]
  
  before_filter :check_vote_topic_owner, :only => [:edit_image, :update_image, :edit, :update,
                                                  :destroy, :edit_option, :delete_others_option]
  
  before_filter :check_comment_owner, :only => [:delete_comment]
  
  before_filter :check_vote_view_access, :only => [:show, :preview_topic, :refresh_vote_result]
  before_filter :protect_vote_view_access, :only => [:create_comment, :invite, :invite_member,
                                                      :invite_contact, :select_contact,
                                                      :send_contact_invitations]
  
  
  
  def index
    jump_to("/votes/latest")
  end
  
  def list_group_index
    jump_to("/groups/all_vote/#{session[:account_id]}")
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
    @vote_topic.allow_anonymous = (params[:vote_topic_allow_anonymous] == "true")
    
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
      photo = vote_image.photo_id && Photo.get_photo(vote_image.photo_id)
      if photo && photo.account_id == session[:account_id]
        if vote_image.save
          VoteTopic.update_vote_topic_with_image_cache(@vote_topic_id, :vote_img => photo.image.url(:thumb_48))
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
    # @vote_topic_id = params[:id]
    # @vote_topic, @vote_image = VoteTopic.get_vote_topic_with_image(@vote_topic_id)
    
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
    
    # @created_vote_topics value is set in view ...
  end
  
  def vote_to_option
    option_ids = params[:option_ids] || []
    option_ids.uniq!
    
    if option_ids.size > 0
      has_login = has_login?
      
      vote_topic_id = params[:id]
      vote_topic, vote_image = VoteTopic.get_vote_topic_with_image(vote_topic_id)
      
      if has_login || vote_topic.allow_anonymous
      
        group_id = vote_topic.group_id || 0
        group, group_image = Group.get_group_with_image(group_id) if group_id > 0
        
        pass_group_check = (!group) || (has_login && GroupMember.is_group_member(group.id, session[:account_id]))
      
        if pass_group_check
          request_remote_ip = request.remote_ip
          
          if has_login
        		records = VoteRecord.get_voted_records(vote_topic.id, session[:account_id])
        	else
        		records = VoteRecord.get_voted_records_by_ip(vote_topic.id, request_remote_ip)
        	end
        
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
                  :account_id => has_login ? session[:account_id] : 0,
                  :vote_topic_id => vote_topic_id,
                  :vote_option_id => option_id,
                  :voter_ip => request_remote_ip
                )
                vote_record_saved = vote_record.save
              
                has_record_saved ||= vote_record_saved
              end
            end
          
            # record account action
            AccountAction.create_new(session[:account_id], "join_vote_topic", {
              :vote_topic_id => vote_topic_id,
              :voter_ip => request_remote_ip
            }) if has_login && has_record_saved
          
          end
        
        end
        
      end
    
    end
    
    jump_to("/votes/#{vote_topic_id}")
    
  end
  
  def clear_vote_record
    vote_topic_id = params[:id]
    
    vote_topic, vote_image = VoteTopic.get_vote_topic_with_image(vote_topic_id)
    
    
    if has_login?
      records = VoteRecord.find(
        :all,
        :conditions => [
          "vote_topic_id = ? and account_id = ?",
          vote_topic.id, session[:account_id]
        ]
      )
    else
      records = VoteRecord.find(
        :all,
        :conditions => [
          "vote_topic_id = ? and account_id = ? and voter_ip = ?",
          vote_topic.id, 0, request.remote_ip
        ]
      )
    end
    
    records.each { |record| record.destroy } if vote_topic.allow_clear_record
    
    jump_to("/votes/#{vote_topic.id}")
  end
  
  def edit
    
  end
  
  def update
    @vote_topic.category_id = params[:vote_topic_category_id]
    @vote_topic.multiple = (params[:vote_topic_multiple] == "true")
    @vote_topic.allow_add_option = (params[:vote_topic_allow_add_option] == "true")
    @vote_topic.allow_clear_record = (params[:vote_topic_allow_clear_record] == "true")
    @vote_topic.allow_anonymous = (params[:vote_topic_allow_anonymous] == "true")
    
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
    
    group_id = vote_topic.group_id || 0
    group, group_image = Group.get_group_with_image(group_id) if group_id > 0
    not_group_member = group && (!GroupMember.is_group_member(group.id, session[:account_id]))
    
    return jump_to("/votes/#{@vote_topic_id}") if not_group_member
    
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
    
    group_id = @vote_topic.group_id || 0
    group, group_image = Group.get_group_with_image(group_id) if group_id > 0
    not_group_member = group && (!GroupMember.is_group_member(group.id, session[:account_id]))
    
    return jump_to("/votes/#{@vote_topic_id}") if not_group_member
    
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
  
  def invite
    @vote_topic_id = params[:id]
    @vote_topic, @vote_image = VoteTopic.get_vote_topic_with_image(@vote_topic_id)
    
    @friends = Friend.get_all_by_account(
      session[:account_id],
      :include => [:friend => [:profile_pic]],
      :order => "created_at DESC"
    )
  end
  
  def invite_member
    @vote_topic_id = params[:id]
    
    invited_account_id = params[:invited_account_id] || []
    invitation_words = (params[:invitation_words] && params[:invitation_words].strip) || ""
    invitation_way = params[:invitation_way]
    
    if invitation_words.size > 100
      flash[:error_msg] = "邀请的话 超过长度限制"
    elsif invited_account_id.size <= 0
      flash[:error_msg] = "还没有选择想邀请的朋友"
    else
      if invitation_way == "email"
        VoteTopic.add_vote_invitation(
          {
            :vote_topic_id => @vote_topic_id,
            :invitor_account_id => session[:account_id],
            :invited_account_ids => invited_account_id,
            :invitation_words => invitation_words
          }
        )
      else
        # send sys message to invited account
        SysMessage.transaction do
          invited_account_id.each do |account_id|
            SysMessage.create_new(account_id, "invite_join_vote", {
              :inviter_id => session[:account_id],
              :vote_topic_id => @vote_topic_id,
              :invitation_words => invitation_words
            })
          end
        end
      end
      
      flash[:message] = "已成功发出邀请"
      
    end
    
    jump_to("/votes/invite/#{@vote_topic_id}")
  end
  
  def invite_contact
    @vote_topic_id = params[:id]
    @vote_topic, @vote_image = VoteTopic.get_vote_topic_with_image(@vote_topic_id)
  end
  
  def select_contact
    @vote_topic_id = params[:id]
    
    @contacts = session[:vote_invite_contacts] || []
    
    return jump_to("/votes/invite_contact/#{@vote_topic_id}") unless @contacts.size > 0
    
    @vote_topic, @vote_image = VoteTopic.get_vote_topic_with_image(@vote_topic_id)
    
    @type = session[:vote_invite_contacts_type]
  end
  
  def send_contact_invitations
    @vote_topic_id = params[:id]
    
    type = params[:type]
    invitation_words = params[:invitation_words] && params[:invitation_words].strip
    
    if type == "email"
      emails = params[:emails].split(",").collect { |email|
        addr = email && email.strip
        (addr != "") ? addr : nil
      }.compact
    else
      emails = params[:emails] || []
    
      unless emails.size > 0
        flash[:error_msg] = "还没有选择要邀请谁"
        return jump_to("/votes/select_contact/#{@vote_topic_id}")
      end
    end
    
    VoteTopic.add_vote_contact_invitation(
      {
        :vote_topic_id => @vote_topic_id,
        :invitor_account_id => session[:account_id],
        :invited_emails => emails,
        :invitation_words => invitation_words
      }
    ) if emails.size > 0
    
    flash[:message] = "已成功发出邀请"
    jump_to("/votes/invite_contact/#{@vote_topic_id}")
    
  end
  
  
  #==========
  
  def preview_topic
    # vote_topic_id = params[:id]
    chart_type = params[:chart_type]
    # vote_topic, vote_image = VoteTopic.get_vote_topic_with_image(vote_topic_id)

    render(:partial => "topic_preview", :locals => {:vote_topic => @vote_topic, :chart_type => chart_type})
  end
  
  def refresh_vote_result
    # topic_id = params[:id]
    chart_type = params[:chart_type]
    graph = build_graph(@vote_topic_id, chart_type, :get_count_by_option)
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
  
  def check_vote_view_access
    @vote_topic_id = params[:id]
    @vote_topic, @vote_image = VoteTopic.get_vote_topic_with_image(@vote_topic_id)
    
    group_id = @vote_topic.group_id
    if group_id && group_id > 0
      @group, @group_image = Group.get_group_with_image(group_id)
      
      need_join_to_view_vote = @group.get_setting[:need_join_to_view_vote]
      @can_not_view = need_join_to_view_vote && (!GroupMember.is_group_member(@group.id, session[:account_id]))
      
      if @can_not_view
        if action_name == "show"
          render :layout => true, :inline => %Q!
            <% vote_topic_title = h(@vote_topic.title)%>

            <% community_page_title(vote_topic_title) %>

            <div class="float_r vote_container_r">

            	<div class="community_block align_c">
          			<a href="/groups/<%= @group.id %>">
          				<img src="<%= face_img_src(@group_image) %>" border="0" /></a>
          		</div>
          		
          		<div class="community_block align_c form_info_s">
        				圈子 <a href="/groups/<%= @group.id %>"><%= h(@group.name) %></a> 的圈内投票
          		</div>

            </div>

            <div class="vote_container_l">
            	<h2>
            		<%= vote_topic_title %>
            	</h2>
            	
            	<p class="warning_msg">
          			根据其所在圈子的设置, 只有圈子成员可以查看投票的具体内容
          		</p>

          		<p>
          			<% form_tag "/groups/#{@group.id}/join", :method => :post do %>
          				<input type="submit" value="我要加入圈子" class="button" />
          			<% end %>
          		</p>

            </div>
          !
        else
          render :layout => false, :inline => %Q!
            <p class="warning_msg">
        			根据圈子
        			<a href="/groups/<%= @group.id %>">
        				<%= h(@group.name) %></a>
        			的设置, 只有圈子成员可以查看圈内投票
        			<a href="/votes/<%= @vote_topic.id %>">
        				<%= h(@vote_topic.title) %></a>
        			的具体内容
        		</p>

        		<p>
        			<% form_tag "/groups/#{@group.id}/join", :method => :post do %>
        				<input type="submit" value="我要加入圈子" class="button" />
        			<% end %>
        		</p>
          !
        end
      end
    end
  end
  
  def protect_vote_view_access
    vote_topic_id = params[:id]
    vote_topic = VoteTopic.get_vote_topic_with_image(vote_topic_id)[0]
    
    group_id = vote_topic.group_id
    if group_id && group_id > 0
      group = Group.get_group_with_image(group_id)[0]
      
      need_join_to_view_vote = group.get_setting[:need_join_to_view_vote]
      can_not_view = need_join_to_view_vote && (!GroupMember.is_group_member(group.id, session[:account_id]))
      
      jump_to("/errors/forbidden") if can_not_view
    end
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
  
  