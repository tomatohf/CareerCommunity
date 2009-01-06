class PhotosController < ApplicationController
  
  Comment_Page_Size = 100
  
  layout "community"
  before_filter :check_login, :only => [:edit, :update, :create_comment, :delete_comment,
                                        :destroy, :move_to_other_album, :update_photo_title]
  before_filter :check_limited, :only => [:update, :create_comment, :delete_comment, :destroy,
                                          :move_to_other_album, :update_photo_title]
  before_filter :check_photo_access, :only => [:edit, :update, :destroy, :move_to_other_album, :update_photo_title]
  
  before_filter :check_comment_owner, :only => [:delete_comment]
  
  def index
    jump_to("/albums")
  end
  
  def show
    @photo ||= Photo.find(params[:id])
    
    @edit = (@photo.account_id == session[:account_id])
    
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
    
    
    @albums = Album.get_all_names_by_account_id(@album.account_id) if @edit
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
  
  def update_photo_title
    @photo.title = params[:photo_title]
    
    @photo.save
    
    jump_to("/photos/#{@photo.id}#photo_title_section")
  end
  
  def destroy
    album_id = @photo.album_id
    photo_id = @photo.id
    
    @photo.destroy
    
    request.xhr? ? (@album_photo_id = "album_photo_#{photo_id}") : jump_to("/albums/#{album_id}")
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
    
    jump_to("/photos/#{photo_id}/comment/#{last_page}#{"#comment_#{photo_comment.id}" if comment_saved}")
  end
  
  def delete_comment
    @photo_comment.destroy
    
    jump_to("/photos/#{@photo_comment.photo_id}")
  end
  
  def move_to_other_album
    album_id = params[:album] && params[:album].strip
    
    old_album_id = @photo.album_id

    # whether need to move
    unless old_album_id.to_s == album_id
      
      # check if own the album
      @owned_album_ids = Album.get_all_names_by_account_id(@photo.account_id).collect { |album| album[0].to_s }
      if @owned_album_ids.include?(album_id)
        @photo.album_id = album_id
        @photo.save
      end
      
    end
    
    jump_to("/photos/#{@photo.id}")    
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
  
  def check_comment_owner
    @photo_comment = PhotoComment.find(params[:id])
    jump_to("/errors/forbidden") unless session[:account_id] == (@photo_comment.photo && @photo_comment.photo.account_id)
  end
  
end