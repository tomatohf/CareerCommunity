class VotesController < ApplicationController
  
  Topic_List_Size = 5
  
  layout "community"
  before_filter :check_login, :only => [:new, :new_in_group, :vote_groups, :create,
                                        :edit_image, :update_image]
  before_filter :check_limited, :only => [:create, :update_image]
  
  before_filter :check_vote_groups_account, :only => [:vote_groups]
  
  before_filter :check_vote_topic_owner, :only => [:edit_image, :update_image]
  
  
  
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
      :include => [:image],
      :order => "created_at DESC"
    )
    
    render :action => "topic_list"
  end
  
  def hotest
    @page_title = "最热投票话题"
    
    latest
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
      :include => [:image],
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
    @vote_topic.allow_add_option = (params[:vote_topic_allow_add_option] == "true")
    @vote_topic.multiple = (params[:vote_topic_multiple] == "true")
    
    # collect vote options
    @option_titles = {}
    @option_colors = {}
    1.upto(20) { |i|
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
          :color => @option_colors[option[0]]
        )
        vote_option.save
      end
      
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
  
  def show
    
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
  
end  
  
  