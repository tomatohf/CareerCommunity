class PhotosController < ApplicationController
  
  Comment_Page_Size = 100
  
  layout "community"
  before_filter :check_login, :only => [:show_edit, :edit, :update, :create_comment, :delete_comment]
  before_filter :check_limited, :only => [:update, :create_comment, :delete_comment]
  before_filter :check_photo_access, :only => [:edit, :update]
  before_filter :check_show_edit_for_photo, :only => [:show_edit]
  
  before_filter :check_comment_owner, :only => [:delete_comment]
  
  def index
    jump_to("/albums")
  end
  
  def show
    @photo ||= Photo.find(params[:id])
    
    @album = @photo.album
    @owner_nick_pic = Account.get_nick_and_pic(@album.account_id) unless @edit

    album_photos = @album.get_photos
    @album_photos_count = album_photos.size
    
    photo_index = 0
    album_photos.each_index do |i|
      if album_photos[i].id == @photo.id
        photo_index = i
        break
      end
    end
    
    @photo_position = photo_index + 1
    
    @next_photo = album_photos[photo_index + 1 < @album_photos_count ? photo_index + 1 : 0]
    @pre_photo = album_photos[photo_index - 1 < 0 ? @album_photos_count - 1 : photo_index - 1]
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @photo_comments = @photo.comments.paginate(
      :page => page,
      :per_page => Comment_Page_Size,
      :total_entries => PhotoComment.get_count(@photo.id),
      :include => [:account => [:profile_pic]],
      :order => "created_at ASC"
    )
  end
  
  def show_edit
    @edit = true
    show
    render :action => "show"
  end
  
  def edit
    
  end
  
  def update
    @photo.title = params[:photo_title]
    
    if @photo.save
      flash.now[:message] = "已成功保存"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render :action => "edit"
  end
  
  def create_comment
    photo_comment = PhotoComment.new(:account_id => session[:account_id])
    
    content = params[:photo_comment]
    photo_id = params[:id]
    
    comment_saved = false
    if photo_id && content
      photo_comment.content = content.strip
      photo_comment.photo_id = photo_id
      comment_saved = photo_comment.save
    end
    
    total_count = PhotoComment.get_count(photo_comment.photo_id)
    last_page = total_count > 0 ? (total_count.to_f/Comment_Page_Size).ceil : 1
    
    jump_to("/photos#{"/show_edit" if params[:e] == "true"}/#{photo_id}/comment/#{last_page}#{"#comment_#{photo_comment.id}" if comment_saved}")
  end
  
  def delete_comment
    @photo_comment.destroy
    
    jump_to("/photos#{"/show_edit" if params[:e] == "true"}/#{@photo_comment.photo_id}")
  end
  
  
  
  private
  
  def check_photo_access
    no_photo_access unless check_photo_owner
  end
  
  def check_photo_owner
    @photo = Photo.find(params[:id])
    @photo.account_id == session[:account_id]
  end
  
  def no_photo_access
    jump_to("/errors/forbidden")
  end
  
  def check_show_edit_for_photo
    jump_to("/photos/#{params[:id]}") unless check_photo_owner
  end
  
  def check_comment_owner
    @photo_comment = PhotoComment.find(params[:id])
    jump_to("/errors/forbidden") unless session[:account_id] == (@photo_comment.photo && @photo_comment.photo.account_id)
  end
  
end