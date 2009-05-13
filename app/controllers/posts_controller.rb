class PostsController < ApplicationController
  
  Comment_Page_Size = 100
  
  Same_Author_Post_Num = 10
  
  layout "community"
  
  before_filter :prepare_post_type
  
  before_filter :check_login, :only => [:compose, :create, :create_comment, :delete_comment, :destroy,
                                        :top, :untop, :edit, :update,
                                        :new_attachment, :create_attachment, :delete_attachment,
                                        :attachment]
  before_filter :check_limited, :only => [:create, :create_comment, :delete_comment, :destroy,
                                          :top, :untop, :update, :create_attachment, :delete_attachment]
  
  before_filter :check_compose_access, :only => [:compose]
  before_filter :check_create_access, :only => [:create]
  before_filter :check_update_access, :only => [:edit, :update, :new_attachment, :create_attachment, :delete_attachment]
  before_filter :check_create_comment_access, :only => [:create_comment]
  before_filter :check_delete_comment_access, :only => [:delete_comment]
  before_filter :check_destroy_access, :only => [:destroy]
  before_filter :check_top_access, :only => [:top, :untop, :good, :ungood]
  before_filter :check_attachment_access, :only => [:attachment]
  
  
  
  def compose
    # done in before filter
    # @type_id ||= params[:id] && params[:id].strip
    # @type_handler ||= get_type_handler(@post_type)

    @post = @type_handler.get_post_class.new
    
    @type_name, @type_image, @display_image = @type_handler.get_type_with_image(@type_id)
    @type_label = @type_handler.get_type_label
  end
  
  def create
    # done in before filter
    # @type_id = params[:type_id] && params[:type_id].strip
    # @type_handler = get_type_handler(@post_type)
    
    @post = @type_handler.get_post_class.new(
      :account_id => session[:account_id],
      :responded_at => DateTime.now,
      @type_handler.get_type_id.to_sym => @type_id
    )
    
    @post.title = params[:title] && params[:title].strip
    @post.content = params[:content] && params[:content].strip
    
    if @post.save
      uploaded_file = params[:attachment_file]
      if uploaded_file && uploaded_file != ""
        post_attachment = @type_handler.get_post_attachment_class.new(
          :account_id => session[:account_id],
          :desc => params[:attachment_file_desc]
        )
        post_attachment.send("#{@type_handler.get_type_post_id}=", @post.id)
        post_attachment.attachment = uploaded_file
        post_attachment.save
      end
      
      # record account action
      AccountAction.create_new(session[:account_id], "add_#{@post_type}_post", {
        :post_id => @post.id,
        :post_title => @post.title,
        @type_handler.get_type_id.to_sym => @type_id
      })
      
      jump_to("/#{@post_type}/posts/#{@post.id}")
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
      
      @type_name, @type_image, @display_image = @type_handler.get_type_with_image(@type_id)
      @type_label = @type_handler.get_type_label
    
      render :action => "compose"
    end
  end
  
  def edit
    @type_id = @post.send(@type_handler.get_type_id)
    @type_name, @type_image, @display_image = @type_handler.get_type_with_image(@type_id)
    @type_label = @type_handler.get_type_label
  end
  
  def update
    @post.title = params[:title] && params[:title].strip
    @post.content = params[:content] && params[:content].strip
    
    # @post.responded_at = DateTime.now
    
    if @post.save
      flash.now[:message] = "已成功保存"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    @type_id = @post.send(@type_handler.get_type_id)
    @type_name, @type_image, @display_image = @type_handler.get_type_with_image(@type_id)
    @type_label = @type_handler.get_type_label
  
    render :action => "edit"
  end
  
  def show
    @post_id = params[:id] && params[:id].strip
    type_handler = get_type_handler(@post_type)
    
    @post = type_handler.get_post_class.get_post(@post_id)
    
    @type_id = @post.send(type_handler.get_type_id)
    
    @poster_nick_pic = Account.get_nick_and_pic(@post.account_id)
    
    @type_name, @type_image, @display_image = type_handler.get_type_with_image(@type_id)
    @type_label = type_handler.get_type_label
    
    @can_view = type_handler.check_view_access(@type_id, session[:account_id])
    
    if @can_view
      page = params[:page]
      page = 1 unless page =~ /\d+/
      @comments = @post.comments.paginate(
        :page => page,
        :per_page => Comment_Page_Size,
        :total_entries => type_handler.get_post_comment_class.get_count(@post_id),
        :include => [:account => [:profile_pic]],
        :order => "created_at ASC"
      )
    
      @attachments = @post.attachments
    
      @other_posts = type_handler.get_post_class.find(
        :all,
        :limit => Same_Author_Post_Num,
        :select => "id, created_at, #{type_handler.get_type_id}, account_id, title, responded_at",
        :conditions => ["account_id = ? and #{type_handler.get_type_id} = ?", @post.account_id, @type_id],
        :order => "responded_at DESC, created_at DESC"
      )
    
      # should NOT cache the access check
      @access = type_handler.get_access(session[:account_id], @post.account_id, @type_id)
      @access << :can_add_comment
    end

  end
  
  def create_comment
    # done in before filter
    # @type_handler = get_type_handler(@post_type)
    
    comment = @type_handler.get_post_comment_class.new(:account_id => session[:account_id])
    
    content = params[:post_comment]
    post_id = params[:id]
    
    comment_saved = false
    if post_id && content
      comment.content = content.rstrip
      comment.send("#{@type_handler.get_type_post_id}=", post_id)
      if comment.save
        comment_saved = true
        
        @post.responded_at = comment.created_at
        @post.save
      end
    end
    
    
    if comment_saved
      AccountAction.create_new(session[:account_id], "add_#{@post_type}_post_comment", {
        @type_handler.get_type_post_id.to_sym => comment.send(@type_handler.get_type_post_id),
        :comment_id => comment.id,
        :comment_content => comment.content
      })
    end
    
    
    total_count = @type_handler.get_post_comment_class.get_count(comment.send("#{@type_handler.get_type_post_id}"))
    last_page = total_count > 0 ? (total_count.to_f/Comment_Page_Size).ceil : 1
    
    jump_to("/#{@post_type}/posts/#{post_id}/comment/#{last_page}#{"#comment_#{comment.id}" if comment_saved}")
  end
  
  def delete_comment
    @post_comment.destroy
    
    jump_to("/#{@post_type}/posts/#{@post_id}")
  end
  
  def destroy
    @post.destroy
    
    jump_to("/#{@post_type.pluralize}/#{@type_id}")
  end
  
  def top
    unless @post.top
      @post.top = true
      @post.save
    end
    
    jump_to("/#{@post_type}/posts/#{@post.id}")
  end
  
  def untop
    if @post.top
      @post.top = false
      @post.save
    end
    
    jump_to("/#{@post_type}/posts/#{@post.id}")
  end
  
  def good
    unless @post.good
      @post.good = true
      @post.save
    end
    
    jump_to("/#{@post_type}/posts/#{@post.id}")
  end
  
  def ungood
    if @post.good
      @post.good = false
      @post.save
    end
    
    jump_to("/#{@post_type}/posts/#{@post.id}")
  end
  
  def new_attachment
    @type_label = @type_handler.get_type_label
  end
  
  def create_attachment
    uploaded_file = params[:attachment_file]

    post_attachment = @type_handler.get_post_attachment_class.new(
      :account_id => session[:account_id],
      :desc => params[:attachment_file_desc]
    )
    post_attachment.send("#{@type_handler.get_type_post_id}=", @post.id)
    post_attachment.attachment = uploaded_file
    
    if post_attachment.save
      flash.now[:message] = "已成功上传"
      
      return jump_to("/#{@post_type}/posts/#{@post.id}")
    else
      @post_attachment = post_attachment
      
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    @type_label = @type_handler.get_type_label
    
    render :action => "new_attachment"
  end
  
  def delete_attachment
    attachment_id = params[:delete_attachment_id]
    
    attachment = @type_handler.get_post_attachment_class.find(attachment_id)
    
    attachment.destroy
    
    jump_to("/#{@post_type}/posts/#{@post.id}")
  end
  
  def attachment
    
    if ENV["RAILS_ENV"] == "production"
      # invoke the x-sendfile of lighttpd to download file
      response.headers["Content-Type"] = @attachment.attachment_content_type
      response.headers["Content-Disposition"] = %Q!attachment; filename="#{@attachment.attachment_file_name}"!
      response.headers["Content-Length"] = @attachment.attachment_file_size
      response.headers["X-LIGHTTPD-send-file"] = @attachment.attachment.path
      # response.headers["X-sendfile"] = @attachment.attachment.path
      render :nothing => true
    else
      send_file(
        @attachment.attachment.path,
        :type => @attachment.attachment_content_type,
        :disposition => %Q!attachment; filename="#{@attachment.attachment_file_name}"!
      )
    end
  end
  
  
  
  private
  
  def prepare_post_type
    @post_type = params[:post_type]
  end
  
  def get_type_handler(post_type)
    type_class = post_type.downcase.capitalize
    eval("Types::#{type_class}").instance
  end
  
  def check_compose_access
    @type_id = params[:id] && params[:id].strip
    @type_handler = get_type_handler(@post_type)
    
    account_id = session[:account_id]
    
    jump_to("/errors/forbidden") unless @type_handler.check_compose_access(@type_id, account_id)
  end
  
  def check_create_access
    @type_id = params[:type_id] && params[:type_id].strip
    @type_handler = get_type_handler(@post_type)
    
    account_id = session[:account_id]
    
    jump_to("/errors/forbidden") unless @type_handler.check_create_access(@type_id, account_id)
  end
  
  def check_update_access
    @type_handler = get_type_handler(@post_type)
    
    @post = @type_handler.get_post_class.get_post(params[:id])
    
    jump_to("/errors/forbidden") unless @post.account_id == session[:account_id]
  end
  
  def check_create_comment_access
    @type_handler = get_type_handler(@post_type)
    
    @post = @type_handler.get_post_class.get_post(params[:id])
    type_id = @post.send(@type_handler.get_type_id)
    
    account_id = session[:account_id]
    
    jump_to("/errors/forbidden") unless @type_handler.check_create_comment_access(type_id, account_id)
  end
  
  def check_delete_comment_access
    @type_handler = get_type_handler(@post_type)
    
    @post_comment = @type_handler.get_post_comment_class.find(params[:id])
    @post_id = @post_comment.send("#{@type_handler.get_type_post_id}")
    
    @post = @type_handler.get_post_class.get_post(@post_id)
    type_id = @post.send(@type_handler.get_type_id)
    
    account_id = session[:account_id]
    
    jump_to("/errors/forbidden") unless @type_handler.check_delete_comment_access(type_id, account_id)
  end
  
  def check_destroy_access
    @type_handler = get_type_handler(@post_type)
    @post = @type_handler.get_post_class.get_post(params[:id])
    
    @type_id = @post.send(@type_handler.get_type_id)
    
    account_id = session[:account_id]
    
    jump_to("/errors/forbidden") unless (@post.account_id == account_id || @type_handler.check_destroy_access(@type_id, account_id))
  end
  
  def check_top_access
    @type_handler = get_type_handler(@post_type)
    @post = @type_handler.get_post_class.get_post(params[:id])
    
    type_id = @post.send(@type_handler.get_type_id)
    
    account_id = session[:account_id]
    
    jump_to("/errors/forbidden") unless @type_handler.check_top_access(type_id, account_id)
  end
  
  def check_attachment_access
    @type_handler = get_type_handler(@post_type)
    
    @attachment_id = params[:id]
    @attachment = @type_handler.get_post_attachment_class.find(@attachment_id)
    
    post_id = @attachment.send(@type_handler.get_type_post_id)
    post = @type_handler.get_post_class.get_post(post_id)
    type_id = post.send(@type_handler.get_type_id)
    account_id = session[:account_id]
    
    jump_to("/errors/unauthorized") unless @type_handler.check_attachment_access(type_id, account_id)
  end
  
  
  
  module Types
    
    class Base
      include Singleton # use .instance() to return the single instance object
      
      def initialize
        @type = self.class.to_s.demodulize.downcase
      end
      
      def get_post_class
        eval("#{@type.capitalize}Post")
      end
      
      def get_post_comment_class
        eval("#{@type.capitalize}PostComment")
      end
      
      def get_post_attachment_class
        eval("#{@type.capitalize}PostAttachment")
      end
      
      def get_type_id
        "#{@type}_id"
      end
      
      def get_type_post_id
        "#{@type}_post_id"
      end
      
    end
    
    class Group < Base
      def get_type_with_image(type_id)
        group, group_image = ::Group.get_group_with_image(type_id)
        [group.name, group_image, true]
      end
      
      def get_type_label
        "圈子"
      end
      
      def check_compose_access(type_id, account_id)
        get_group_self_check_compose_access_result(type_id, account_id) || GroupMember.is_group_member(type_id, account_id)
      end
      
      def check_create_access(type_id, account_id)
        check_compose_access(type_id, account_id)
      end
      
      def check_destroy_access(type_id, account_id)
        GroupMember.is_group_admin(type_id, account_id)
      end
      
      def check_create_comment_access(type_id, account_id)
        check_view_access(type_id, account_id)
      end
      
      def check_delete_comment_access(type_id, account_id)
        check_destroy_access(type_id, account_id)
      end
      
      def check_top_access(type_id, account_id)
        check_destroy_access(type_id, account_id)
      end
      
      def check_view_access(type_id, account_id)
        group = ::Group.get_group_with_image(type_id)[0]
        need_join_to_view_post = group.get_setting[:need_join_to_view_post]
        
        !(need_join_to_view_post && (!GroupMember.is_group_member(type_id, account_id)))
      end
      
      def check_attachment_access(type_id, account_id)
        check_view_access(type_id, account_id)
      end
      
      def get_access(current_account_id, poster_id, type_id)
        access = []
        if current_account_id
          is_member = GroupMember.is_group_member(type_id, current_account_id)
          if is_member
            access << :can_compose
            access << :admin if GroupMember.is_group_admin(type_id, current_account_id)
          end
          access << :author if (poster_id == current_account_id)
        end
        
        # to append access for check_compose_access
        access << :can_compose if (!access.include?(:can_compose)) && get_group_self_check_compose_access_result(type_id, current_account_id)
        
        access
      end
      
      def get_group_self_check_compose_access_result(group_id, account_id)
        group = ::Group.get_group_with_image(group_id)[0]
        custom_key = group.custom_key
        custom_group = custom_key && ::Group::Custom_Groups[custom_key]
        
        compose_access = false
        if custom_group && (custom_group != "")
          custom_group = "CustomGroups::#{custom_group.camelize}Controller".constantize
          compose_access = custom_group.check_compose_access(group_id, account_id) if custom_group.respond_to?(:check_compose_access)
        end
        
        compose_access
      end
    end
    
    
    class Activity < Base
      def get_type_with_image(type_id)
        activity, activity_image = ::Activity.get_activity_with_image(type_id)
        [activity.get_title, activity_image, true]
      end
      
      def get_type_label
        "活动"
      end
      
      def check_compose_access(type_id, account_id)
        activity = ::Activity.get_activity_with_image(type_id)[0]
        
        need_join_to_add_post = activity.get_setting[:need_join_to_add_post]
        
        if need_join_to_add_post
          ActivityMember.is_activity_member(type_id, account_id)
        else

          group_id = activity.in_group
          if group_id && group_id > 0
            group = ::Group.get_group_with_image(group_id)[0]

            need_join_to_view_activity = group.get_setting[:need_join_to_view_activity]
            need_join_group_to_view = activity.get_setting[:need_join_group_to_view]

            !((need_join_to_view_activity || need_join_group_to_view) && (!GroupMember.is_group_member(group.id, account_id)))
          else
            true
          end
          
        end
      end
      
      def check_create_access(type_id, account_id)
        check_compose_access(type_id, account_id)
      end
      
      def check_destroy_access(type_id, account_id)
        ActivityMember.is_activity_admin(type_id, account_id)
      end
      
      def check_create_comment_access(type_id, account_id)
        check_view_access(type_id, account_id)
      end
      
      def check_delete_comment_access(type_id, account_id)
        check_destroy_access(type_id, account_id)
      end
      
      def check_top_access(type_id, account_id)
        check_destroy_access(type_id, account_id)
      end
      
      def check_view_access(type_id, account_id)
        activity = ::Activity.get_activity_with_image(type_id)[0]
        
        need_join_to_view_post = activity.get_setting[:need_join_to_view_post]
        
        if need_join_to_view_post
          ActivityMember.is_activity_member(type_id, account_id)
        else

          group_id = activity.in_group
          if group_id && group_id > 0
            group = ::Group.get_group_with_image(group_id)[0]

            need_join_to_view_activity = group.get_setting[:need_join_to_view_activity]
            need_join_group_to_view = activity.get_setting[:need_join_group_to_view]

            !((need_join_to_view_activity || need_join_group_to_view) && (!GroupMember.is_group_member(group.id, account_id)))
          else
            true
          end
          
        end
      end
      
      def check_attachment_access(type_id, account_id)
        check_view_access(type_id, account_id)
      end
      
      def get_access(current_account_id, poster_id, type_id)
        access = []
        
        activity = ::Activity.get_activity_with_image(type_id)[0]
        
        need_join_to_add_post = activity.get_setting[:need_join_to_add_post]
        
        access << :can_compose unless need_join_to_add_post && (!ActivityMember.is_activity_member(type_id, current_account_id))
        
        if current_account_id
          access << :admin if ActivityMember.is_activity_admin(type_id, current_account_id)
          access << :author if (poster_id == current_account_id)
        end
        access
      end
    end
    
    
    class Goal < Base
      def get_type_with_image(type_id)
        goal = ::Goal.get_goal(type_id)
        [goal.name, nil, false]
      end
      
      def get_type_label
        "目标"
      end
      
      def check_compose_access(type_id, account_id)
        true
      end
      
      def check_create_access(type_id, account_id)
        check_compose_access(type_id, account_id)
      end
      
      def check_destroy_access(type_id, account_id)
        ApplicationController.helpers.general_admin?(account_id)
      end
      
      def check_create_comment_access(type_id, account_id)
        check_view_access(type_id, account_id)
      end
      
      def check_delete_comment_access(type_id, account_id)
        check_destroy_access(type_id, account_id)
      end
      
      def check_top_access(type_id, account_id)
        check_destroy_access(type_id, account_id)
      end
      
      def check_view_access(type_id, account_id)
        true
      end
      
      def check_attachment_access(type_id, account_id)
        check_view_access(type_id, account_id)
      end
      
      def get_access(current_account_id, poster_id, type_id)
        access = []
        
        access << :can_compose
        
        if current_account_id
          access << :admin if ApplicationController.helpers.general_admin?(current_account_id)
          access << :author if (poster_id == current_account_id)
        end
        access
      end
    end
    
  end
  
end
