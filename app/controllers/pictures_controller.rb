class PicturesController < ApplicationController
  
  Comment_Page_Size = 100
  
  layout "community"
  
  before_filter :prepare_picture_type
  
  before_filter :check_login, :only => [:upload, :upload_simple, :create_picture_simple]
  before_filter :check_limited, :only => [:create_picture_simple]
  
  before_filter :check_create_access, :only => [:upload, :upload_simple, :create_picture_simple]
  before_filter :check_update_access, :only => [:update]
  before_filter :check_destroy_access, :only => [:destroy]
  before_filter :check_top_access, :only => [:top, :untop, :good, :ungood]
  
  
  
  def upload
    @type_name, @type_image = @type_handler.get_type_with_image(@type_id)
    @type_label = @type_handler.get_type_label
  end
  
  def upload_simple
    @type_name, @type_image = @type_handler.get_type_with_image(@type_id)
    @type_label = @type_handler.get_type_label
  end
  
  def create_picture
    if has_login?
      @type_id = params[:id] && params[:id].strip
      @type_handler = get_type_handler(@picture_type)

      if @type_handler.check_create_access(@type_id, session[:account_id])
        unless is_limited?(session[:limited])
          picture = @type_handler.get_picture_class.new(
            :swfupload_file => params[:Filedata],
            :account_id => session[:account_id],
            :responded_at => DateTime.now,
            @type_handler.get_type_id.to_sym => @type_id
          )
          
          if picture.save
            render(
              :text => %Q!
                <a target="_blank" href="/#{@picture_type}/pictures/#{picture.id}" title="点击查看照片">
                  <img src="#{picture.image.url(:thumb_80)}" border="0" /></a>
              !
            )
          else
            render :text => "error", :layour => false, :status => 500
          end
        else
          render :text => "帐号处于未激活状态, 不能进行更新操作", :layout => false
        end
      else
        render :text => "无权进行上传操作, 请 <a href='/albums'>返回</a>", :layout => false
      end
    else
      render :text => "请先 <a href='/accounts/logon'>登录</a>", :layout => false
    end
  end
  
  def create_picture_simple
    image_count = params[:image_count].to_i || 3
    1.upto(image_count) { |i|
      uploaded_file = params["image_file#{i}".to_sym]
      if uploaded_file && uploaded_file != ""
        picture = @type_handler.get_picture_class.new(
          :account_id => session[:account_id],
          :responded_at => DateTime.now,
          @type_handler.get_type_id.to_sym => @type_id
        )
        
        picture.title = params["image_title#{i}".to_sym]
        picture.image = uploaded_file
        if picture.save
          flash.now[:message] = "" unless flash.now[:message]
          flash.now[:message] += "#{i} 号图片已成功保存 <br />"
        else
          flash.now[:error_msg] = "" unless flash.now[:error_msg]
          flash.now[:error_msg] += "#{i} 号图片上传失败 <br /> #{ApplicationController.helpers.list_model_validate_errors(picture)} <br />"
        end
      end
    }
    
    upload_simple
      
    render(:action => "upload_simple")
  end
  
  def image
    picture_id = params[:id]
    picture_style = params[:style]
    
    type_handler = get_type_handler(@picture_type)
    
    picture = type_handler.get_picture_class.get_picture(picture_id)
    
    if ENV["RAILS_ENV"] == "production"
      # invoke the x-sendfile of lighttpd to download file
      response.headers["Content-Type"] = picture.image_content_type
      response.headers["Content-Disposition"] = %Q!inline; filename="#{picture.image_file_name}"!
      response.headers["Content-Length"] = picture.image_file_size
      response.headers["X-LIGHTTPD-send-file"] = picture.image.path(picture_style)
      render :nothing => true
    else
      send_file(
        picture.image.path(picture_style),
        :type => picture.image_content_type,
        :disposition => %Q!inline; filename="#{picture.image_file_name}"!
      )
    end
  end
  
  def show
    @picture_id = params[:id]
    
    type_handler = get_type_handler(@picture_type)
    
    @picture = type_handler.get_picture_class.get_picture(@picture_id)
    
    @uploader_nick_pic = Account.get_nick_and_pic(@picture.account_id)
    
    @type_id = @picture.send(type_handler.get_type_id)
    @type_name, @type_image = type_handler.get_type_with_image(@type_id)
    @type_label = type_handler.get_type_label
    
    @can_view = true
    
    if @can_view
      page = params[:page]
      page = 1 unless page =~ /\d+/
      @comments = @picture.comments.paginate(
        :page => page,
        :per_page => Comment_Page_Size,
        :total_entries => type_handler.get_picture_comment_class.get_count(@picture_id),
        :include => [:account => [:profile_pic]],
        :order => "created_at ASC"
      )
      
      @access = type_handler.get_access(session[:account_id], @picture.account_id, @type_id)
    end
  end
  
  def update
    @picture.title = params[:picture_title] && params[:picture_title].strip
    
    @picture.save
    
    jump_to("/#{@picture_type}/pictures/#{@picture.id}#picture_title_section")
  end
  
  def destroy
    @picture.destroy
    
    jump_to("/#{@picture_type.pluralize}/#{@type_id}")
  end
  
  def top
    unless @picture.top
      @picture.top = true
      @picture.save
    end
    
    jump_to("/#{@picture_type}/pictures/#{@picture.id}")
  end
  
  def untop
    if @picture.top
      @picture.top = false
      @picture.save
    end
    
    jump_to("/#{@picture_type}/pictures/#{@picture.id}")
  end
  
  def good
    unless @picture.good
      @picture.good = true
      @picture.save
    end
    
    jump_to("/#{@picture_type}/pictures/#{@picture.id}")
  end
  
  def ungood
    if @picture.good
      @picture.good = false
      @picture.save
    end
    
    jump_to("/#{@picture_type}/pictures/#{@picture.id}")
  end
  
  
  
  private
  
  def prepare_picture_type
    @picture_type = params[:picture_type]
  end

  def get_type_handler(picture_type)
    type_class = picture_type.downcase.capitalize
    eval("Types::#{type_class}").instance
  end
  
  def check_create_access
    @type_id = params[:id] && params[:id].strip
    @type_handler = get_type_handler(@picture_type)
    
    account_id = session[:account_id]
    
    jump_to("/errors/forbidden") unless @type_handler.check_create_access(@type_id, account_id)
  end
  
  def check_update_access
    @type_handler = get_type_handler(@picture_type)
    
    @type_id = params[:id]
    @picture = @type_handler.get_picture_class.get_picture(@type_id)
    
    jump_to("/errors/forbidden") unless @picture.account_id == session[:account_id]
  end
  
  def check_destroy_access
    @type_handler = get_type_handler(@picture_type)
    @picture = @type_handler.get_picture_class.get_picture(params[:id])
    
    @type_id = @picture.send(@type_handler.get_type_id)
    
    account_id = session[:account_id]
    
    jump_to("/errors/forbidden") unless (@picture.account_id == account_id || @type_handler.check_destroy_access(@type_id, account_id))
  end
  
  def check_top_access
    @type_handler = get_type_handler(@picture_type)
    @picture = @type_handler.get_picture_class.get_picture(params[:id])
    
    type_id = @picture.send(@type_handler.get_type_id)
    
    account_id = session[:account_id]
    
    jump_to("/errors/forbidden") unless @type_handler.check_top_access(type_id, account_id)
  end
  
  
  
  module Types
    
    class Base
      include Singleton # use .instance() to return the single instance object
      
      def initialize
        @type = self.class.to_s.demodulize.downcase
      end
      
      def get_picture_class
        eval("#{@type.capitalize}Picture")
      end
      
      def get_picture_comment_class
        eval("#{@type.capitalize}PictureComment")
      end
      
      def get_type_id
        "#{@type}_id"
      end
      
      def get_type_picture_id
        "#{@type}_picture_id"
      end
      
    end
    
    class Group < Base
      
      def get_type_with_image(type_id)
        group, group_image = ::Group.get_group_with_image(type_id)
        [group.name, group_image]
      end
      
      def get_type_label
        "圈子"
      end
      
      def check_create_access(group_id, account_id)
        GroupMember.is_group_member(group_id, account_id)
      end
      
      def check_destroy_access(group_id, account_id)
        GroupMember.is_group_admin(group_id, account_id)
      end
      
      def check_top_access(group_id, account_id)
        check_destroy_access(group_id, account_id)
      end
      
      def get_access(current_account_id, uploader_id, group_id)
        access = []
        
        if current_account_id
          is_member = GroupMember.is_group_member(group_id, current_account_id)
          if is_member
            access << :can_upload
            access << :admin if GroupMember.is_group_admin(group_id, current_account_id)
          end
          access << :author if (uploader_id == current_account_id)
        end
        
        access
      end
      
    end
    
    
    class Activity < Base
      
      def get_type_with_image(type_id)
        activity, activity_image = ::Activity.get_activity_with_image(type_id)
        [activity.get_title, activity_image]
      end
      
      def get_type_label
        "活动"
      end
      
      def check_create_access(activity_id, account_id)
        ActivityMember.is_activity_member(activity_id, account_id)
      end
      
      def check_destroy_access(activity_id, account_id)
        ActivityMember.is_activity_admin(activity_id, account_id)
      end
      
      def check_top_access(activity_id, account_id)
        check_destroy_access(activity_id, account_id)
      end
      
      def get_access(current_account_id, uploader_id, activity_id)
        access = []
        
        if current_account_id
          member = ActivityMember.get_activity_member(activity_id, current_account_id)
          if member
            access << :can_upload
            access << :admin if member.admin
          end
          access << :author if (uploader_id == current_account_id)
        end
        
        access
      end
      
    end
    
  end
  
end


