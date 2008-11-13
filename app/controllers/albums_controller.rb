class AlbumsController < ApplicationController
  
  layout "community"
  before_filter :check_current_account, :only => [:index]
  before_filter :check_login, :only => [:new, :create,
                                        :edit, :update, :upload, :upload_simple,
                                        :create_photo_simple, :photo_selector,
                                        :fetch_photos, :destroy, :create_photo_from_photo_selector]
  before_filter :check_limited, :only => [:update, :create, :create_photo_simple, :destroy, :create_photo_from_photo_selector]
  before_filter :check_album_access, :only => [:upload, :upload_simple,
                                              :create_photo_simple, :fetch_photos, :destroy, :create_photo_from_photo_selector]
  before_filter :check_album_access_full, :only => [:edit, :update]
    

  
  # ! current account needed !
  def index
    jump_to("/albums/list/#{session[:account_id]}")
  end
  
  def list
    @owner_id = params[:id]
    
    @edit = (session[:account_id].to_s == @owner_id)
    
    @albums = Album.get_all_by_account_id(@owner_id)
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id)
  end
  
  def show
    @album ||= Album.find(params[:id])
    
    @edit = (session[:account_id] == @album.account_id)
    
    @owner_nick_pic = Account.get_nick_and_pic(@album.account_id)
  end
  
  # ! login required !
  def edit
    
  end
  
  # ! login required !
  # ! unlimited required !
  def update
    
    unless request.xhr? || params[:c] == "true"
      o_name = @album.name
      @album.name = params[:album_name]
      @album.description = params[:album_description]
    end
    
    # validate the cover photo
    cover_photo_changed = false
    old_cover_photo_id = @album.cover_photo_id
    @album.cover_photo_id = params[:album_cover_photo_id]
    if @album.cover_photo_id && @album.cover_photo_id != old_cover_photo_id
      photo = @album.cover_photo
      if photo && photo.album_id == @album.id
        @cover_photo = photo
        cover_photo_changed = true
      else
        @album.cover_photo_id = old_cover_photo_id
      end
    end
    
    if @album.save
      @album.set_cover_photo_cache(@cover_photo) if cover_photo_changed
      flash.now[:message] = "已成功保存"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
      @old_name = o_name
    end
      
    render(:action => "edit")
  end
  
  def destroy
    photo_count = Photo.count(:conditions => ["album_id = ?", @album.id])
    if photo_count > 0
      # can NOT delete album
      flash[:error_msg] = "删除相册失败... 相册中还包含 #{photo_count} 张照片, 只能删除不包含照片的空相册"
    else
      @album.destroy
      flash[:message] = "已成功删除相册"
    end
    
    jump_to("/albums/list/#{session[:account_id]}")
  end
  
  # ! login required !
  def new
    @album = Album.new
  end
  
  # ! login required !
  # ! unlimited required !
  def create
    @album = Album.new(:account_id => session[:account_id])
    
    @album.name = params[:album_name]
    @album.description = params[:album_description]
    if @album.save
      return jump_to("/albums/#{@album.id}/upload")
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
      
    render(:action => "new")
  end
  
  # ! login required !
  def upload
    
  end
  
  # ! login required !
  def upload_simple
    
  end
  
  # ! login required !
  def create_photo
    if has_login?
      if check_album_owner(false)
        unless is_limited?(@account_limited)
          photo = Photo.new(:swfupload_file => params[:Filedata], :album_id => @album.id, :account_id => session[:account_id])
          if photo.save
            render(:text => %Q!<a target="_blank" href="/photos/#{photo.id}" title="点击查看照片"><img src="#{photo.image.url(:thumb_80)}" border="0" /></a>!)
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
      render :text => "请先 <a href='/accounts/login_form'>登录</a>", :layout => false
    end
  end
  
  # ! login required !
  # ! unlimited required !
  def create_photo_simple
    image_count = params[:image_count].to_i || 3
    1.upto(image_count) { |i|
      uploaded_file = params["image_file#{i}".to_sym]
      if uploaded_file && uploaded_file != ""
        photo = Photo.new(:album_id => @album.id, :account_id => session[:account_id])
        photo.title = params["image_title#{i}".to_sym]
        photo.image = uploaded_file
        if photo.save
          flash.now[:message] = "" unless flash.now[:message]
          flash.now[:message] += "#{i} 号图片已成功保存 <br />"
        else
          flash.now[:error_msg] = "" unless flash.now[:error_msg]
          flash.now[:error_msg] += "#{i} 号图片上传失败 <br /> #{ApplicationController.helpers.list_model_validate_errors(photo)} <br />"
        end
      end
    }
      
    render(:action => "upload_simple")
  end
  
  def create_photo_from_photo_selector
    photo_saved = false
    
    uploaded_file = params[:image_file]
    if uploaded_file && uploaded_file != ""
      photo = Photo.new(:album_id => @album.id, :account_id => session[:account_id])
      photo.image = uploaded_file
      photo_saved = photo.save
    end
    
    render :text => %Q!
  
      <script language="JavaScript">
        parent.photo_selector.refresh_album_of_uploaded_photo(#{@album.id}, "#{params[:photo_list_template]}")
      </script>
    
    !, :layout => false if photo_saved
  end
  
  def photo_selector
    @photo_list_template = params[:photo_list_template]
    @albums = Album.get_all_names_by_account_id(session[:account_id])
    # @width = params[:width]
    
    if request.xhr?
      @container_id = params[:container_id]
      render :update do |page|
        page.replace_html @container_id, :partial => "photo_selector", :locals => {:albums => @albums, :photo_list_template => @photo_list_template}

        page.hide @container_id
        page.visual_effect :appear, @container_id
      end
    else
      render :partial => "photo_selector", :locals => {:albums => @albums, :photo_list_template => @photo_list_template}
    end
  end
  
  def fetch_photos
    @album = Album.find(params[:id])
    @photos = @album.get_photos
    @photo_list_template = params[:photo_list_template]
    @target_container_id = "photo_selector_container_#{@album.id}"
  end
  
  
  
  private
  
  def check_album_access
    no_album_access unless check_album_owner(false)
  end
  
  def check_album_access_full
    no_album_access unless check_album_owner(true)
  end
  
  def check_album_owner(full = false)
    selected = full ? "*" : "id, name, account_id, cover_photo_id"
    @album = Album.find(params[:id], :select => selected)
    @album.account_id == session[:account_id]
  end
  
  def no_album_access
    jump_to("/errors/forbidden")
  end
  
end