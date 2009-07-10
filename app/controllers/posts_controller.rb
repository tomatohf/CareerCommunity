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
  before_filter :check_update_access, :only => [:edit, :update]
  before_filter :check_create_comment_access, :only => [:create_comment]
  before_filter :check_delete_comment_access, :only => [:delete_comment]
  before_filter :check_create_attachment_access, :only => [:new_attachment, :create_attachment]
  before_filter :check_delete_attachment_access, :only => [:delete_attachment]
  before_filter :check_destroy_access, :only => [:destroy]
  before_filter :check_top_access, :only => [:top, :untop, :good, :ungood]
  before_filter :check_attachment_access, :only => [:attachment]
  
  skip_after_filter OutputCompressionFilter, :only => [:attachment]
  
  
  
  def compose
    # done in before filter
    # @type_id ||= params[:id] && params[:id].strip
    # @type_handler ||= get_type_handler(@post_type)

    @post = @type_handler.get_post_class.new
    
    @type_name, @type_image, @display_image = @type_handler.get_type_with_image(@type_id)
    @type_label = @type_handler.get_type_label
    
    @categories = @type_handler.get_post_category_class.get_categories(@type_id) if @post.respond_to?(:category_id, false)
  end
  
  def create
    # done in before filter
    # @type_id = params[:type_id] && params[:type_id].strip
    # @type_handler = get_type_handler(@post_type)
    
    @post = @type_handler.get_post_class.new(
      :account_id => session[:account_id],
      :responded_at => DateTime.now,
      :responded_by => session[:account_id],
      @type_handler.get_type_id.to_sym => @type_id
    )
    
    @post.title = params[:title] && params[:title].strip
    @post.content = params[:content] && params[:content].strip
    
    @post.category_id = params[:post_category] if @post.respond_to?(:category_id, false)
    
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
    @poster_points = PointProfile.get_account_points(@post.account_id)
    
    @is_vip = false
    @is_brain_trust = false
    @is_kind_hearted = false
    RoleProfile.get_account_roles(@post.account_id).each do |role|
      role_type_id = role[1]
      
      @is_vip ||= (role_type_id == RoleProfile.ids.customer_role_id)
      @is_brain_trust ||= (role_type_id == RoleProfile.ids.industry_expert_role_id) || (role_type_id == RoleProfile.ids.trainer_role_id)
      @is_kind_hearted ||= (role_type_id == RoleProfile.ids.kind_hearted_role_id)
    end
    
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
        :order => "created_at ASC"
      )
    
      @attachments = @post.attachments
    
      @other_posts = type_handler.get_post_class.find(
        :all,
        :limit => Same_Author_Post_Num,
        :select => "id, created_at, account_id, title, responded_at",
        :conditions => ["account_id = ?", @post.account_id],
        :order => "responded_at DESC"
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
        @post.responded_by = session[:account_id]
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
    
    # it's better to check if it's the last comment being deleted
    # if so, need to update the post's responded_at and responded_by values
    
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
    
    file_name = @attachment.attachment_file_name
    file_name = URI.encode(file_name) if (request.env["HTTP_USER_AGENT"] || "") =~ /MSIE/i
    
    if ENV["RAILS_ENV"] == "production"
      # invoke the x-sendfile of lighttpd to download file
      response.headers["Content-Type"] = @attachment.attachment_content_type
      response.headers["Content-Disposition"] = %Q!attachment; filename=#{file_name}!
      response.headers["Content-Length"] = @attachment.attachment_file_size
      response.headers["X-LIGHTTPD-send-file"] = @attachment.attachment.path
      # response.headers["X-sendfile"] = @attachment.attachment.path
      render :nothing => true
    else
      send_file(
        @attachment.attachment.path,
        :type => @attachment.attachment_content_type,
        :disposition => %Q!attachment; filename=#{file_name}!
      )
    end
  end
  
  
  
  private
  
  def prepare_post_type
    @post_type = params[:post_type]
  end
  
  def get_type_handler(post_type)
    eval("Types::#{post_type.camelize}").instance
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
  
  def check_create_attachment_access
    @type_handler = get_type_handler(@post_type)
    @post = @type_handler.get_post_class.get_post(params[:id])
    
    type_id = @post.send(@type_handler.get_type_id)
    
    account_id = session[:account_id]
    
    jump_to("/errors/forbidden") unless @type_handler.check_create_attachment_access(type_id, account_id, @post.account_id)
  end
  
  def check_delete_attachment_access
    @type_handler = get_type_handler(@post_type)
    @post = @type_handler.get_post_class.get_post(params[:id])
    
    type_id = @post.send(@type_handler.get_type_id)
    
    account_id = session[:account_id]
    
    jump_to("/errors/forbidden") unless @type_handler.check_delete_attachment_access(type_id, account_id, @post.account_id)
  end
  
  def check_destroy_access
    @type_handler = get_type_handler(@post_type)
    @post = @type_handler.get_post_class.get_post(params[:id])
    
    @type_id = @post.send(@type_handler.get_type_id)
    
    account_id = session[:account_id]
    
    jump_to("/errors/forbidden") unless @type_handler.check_destroy_access(@type_id, account_id, @post.account_id)
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
        "#{@type.camelize}Post".constantize
      end
      
      def get_post_comment_class
        "#{@type.camelize}PostComment".constantize
      end
      
      def get_post_category_class
        "#{@type.camelize}PostCategory".constantize
      end
      
      def get_post_attachment_class
        "#{@type.camelize}PostAttachment".constantize
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
      
      def check_destroy_access(type_id, account_id, poster_id)
        can_del_post(type_id, GroupMember.is_group_admin(type_id, account_id), (account_id == poster_id))
      end
      
      def check_create_comment_access(type_id, account_id)
        check_view_access(type_id, account_id)
      end
      
      def check_delete_comment_access(type_id, account_id)
        GroupMember.is_group_admin(type_id, account_id)
      end
      
      def check_top_access(type_id, account_id)
        GroupMember.is_group_admin(type_id, account_id)
      end
      
      def check_view_access(type_id, account_id)
        group = ::Group.get_group_with_image(type_id)[0]
        need_join_to_view_post = group.get_setting[:need_join_to_view_post]
        
        !(need_join_to_view_post && (!GroupMember.is_group_member(type_id, account_id)))
      end
      
      def check_attachment_access(type_id, account_id)
        check_view_access(type_id, account_id)
      end
      
      def check_create_attachment_access(type_id, account_id, poster_id)
        can_add_attachment(type_id, GroupMember.is_group_admin(type_id, account_id), (account_id == poster_id))
      end
      
      def check_delete_attachment_access(type_id, account_id, poster_id)
        can_del_attachment(type_id, GroupMember.is_group_admin(type_id, account_id), (account_id == poster_id))
      end
      
      def get_access(current_account_id, poster_id, type_id)
        access = []
        if current_account_id
          is_member = GroupMember.is_group_member(type_id, current_account_id)
          is_admin = is_member && GroupMember.is_group_admin(type_id, current_account_id)
          is_author = (poster_id == current_account_id)
          
          # to grant access ...
          access << :can_compose if is_member
          
          access << :can_top if is_admin
          access << :can_good if is_admin
          access << :can_del_comment if is_admin
          
          access << :can_edit if is_author
          access << :can_del if can_del_post(type_id, is_admin, is_author)
          access << :can_add_attachment if can_add_attachment(type_id, is_admin, is_author)
          access << :can_del_attachment if can_del_attachment(type_id, is_admin, is_author)
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
      
      
      private
      
      def can_del_post(type_id, is_admin, is_author)
        return is_admin if is_resume_group(type_id)
        
        is_admin || is_author
      end
      
      def can_del_attachment(type_id, is_admin, is_author)
        return is_admin if is_resume_group(type_id)
        
        is_author || is_admin
      end
      
      def can_add_attachment(type_id, is_admin, is_author)
        is_author || (is_resume_group(type_id) && is_admin)
      end
      
      def is_resume_group(type_id)
        type_id == 3
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
      
      def check_destroy_access(type_id, account_id, poster_id)
        (account_id == poster_id) || ActivityMember.is_activity_admin(type_id, account_id)
      end
      
      def check_create_comment_access(type_id, account_id)
        check_view_access(type_id, account_id)
      end
      
      def check_delete_comment_access(type_id, account_id)
        ActivityMember.is_activity_admin(type_id, account_id)
      end
      
      def check_top_access(type_id, account_id)
        ActivityMember.is_activity_admin(type_id, account_id)
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
      
      def check_create_attachment_access(type_id, account_id, poster_id)
        account_id == poster_id
      end
      
      def check_delete_attachment_access(type_id, account_id, poster_id)
        (account_id == poster_id) || ActivityMember.is_activity_admin(type_id, account_id)
      end
      
      def get_access(current_account_id, poster_id, type_id)
        access = []
        if current_account_id
          activity = ::Activity.get_activity_with_image(type_id)[0]
        
          need_join_to_add_post = activity.get_setting[:need_join_to_add_post]
        
          is_member = ActivityMember.is_activity_member(type_id, current_account_id)
          access << :can_compose unless need_join_to_add_post && (!is_member)
        
        
          is_admin = is_member && ActivityMember.is_activity_admin(type_id, current_account_id)
          is_author = (poster_id == current_account_id)
          
          access << :can_top if is_admin
          access << :can_good if is_admin
          access << :can_del_comment if is_admin
          
          access << :can_edit if is_author
          access << :can_del if (is_admin || is_author)
          access << :can_add_attachment if is_author
          access << :can_del_attachment if (is_author || is_admin)
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
      
      def check_destroy_access(type_id, account_id, poster_id)
        (account_id == poster_id) || ApplicationController.helpers.general_admin?(account_id)
      end
      
      def check_create_comment_access(type_id, account_id)
        check_view_access(type_id, account_id)
      end
      
      def check_delete_comment_access(type_id, account_id)
        ApplicationController.helpers.general_admin?(account_id)
      end
      
      def check_top_access(type_id, account_id)
        ApplicationController.helpers.general_admin?(account_id)
      end
      
      def check_view_access(type_id, account_id)
        true
      end
      
      def check_attachment_access(type_id, account_id)
        check_view_access(type_id, account_id)
      end
      
      def check_create_attachment_access(type_id, account_id, poster_id)
        account_id == poster_id
      end
      
      def check_delete_attachment_access(type_id, account_id, poster_id)
        (account_id == poster_id) || ApplicationController.helpers.general_admin?(account_id)
      end
      
      def get_access(current_account_id, poster_id, type_id)
        access = []
        
        access << :can_compose
        
        if current_account_id
          is_admin = ApplicationController.helpers.general_admin?(current_account_id)
          is_author = (poster_id == current_account_id)
          
          access << :can_top if is_admin
          access << :can_good if is_admin
          access << :can_del_comment if is_admin
          
          access << :can_edit if is_author
          access << :can_del if (is_admin || is_author)
          access << :can_add_attachment if is_author
          access << :can_del_attachment if (is_author || is_admin)
        end
        access
      end
    end
    
    
    class Company < Goal
      def get_type_with_image(type_id)
        company = ::Company.get_company(type_id)
        [company.name, nil, false]
      end
      
      def get_type_label
        "公司讨论区"
      end
    end
    
  end
  
end
