class LinkedPhotosController < ApplicationController
  
  layout "community"
  
  before_filter :prepare_linked_photo_type
  
  before_filter :check_login, :only => [:select, :photo_selector_for_linked_photo, :create_link, :destroy_link]
  before_filter :check_limited, :only => [:create_link, :destroy_link]
  
  before_filter :check_create_link_access, :only => [:select, :create_link]
  before_filter :check_destroy_link_access, :only => [:destroy_link]
  
  
  
  def select
    # done in before filter
    # @type_id = params[:id] && params[:id].strip
    # @type_handler = get_type_handler(@linked_photo_type)

    @type_name, @type_image = @type_handler.get_type_with_image(@type_id)
    @type_label = @type_handler.get_type_label
  end
  
  def photo_selector_for_linked_photo
    albums = Album.get_all_names_by_account_id(session[:account_id])
    render :partial => "albums/photo_selector", :locals => {:albums => albums, :photo_list_template => "/linked_photos/photo_list_for_select"}
  end
  
  def create_link
    # done in before filter
    # @type_id = params[:type_id] && params[:type_id].strip
    # @type_handler = get_type_handler(@linked_photo_type)
    
    photo_ids = params[:photo_ids] || []
    account_id = session[:account_id]
    
    valid_photo_ids = Photo.find(
      :all,
      :select => "id",
      :conditions => ["account_id = ? and id in (?)", account_id, photo_ids]
    ).collect {|photo| photo.id}
    
    existing_photo_ids = @type_handler.get_link_class.find(
      :all,
      :conditions => ["#{@type_handler.get_type_id} = ? and #{@type_handler.get_photo_id} in (?)", @type_id, valid_photo_ids]
    ).collect {|link| link.send(@type_handler.get_photo_id)}
    
    need_create_photo_ids = valid_photo_ids - existing_photo_ids
    
    @type_handler.get_link_class.transaction do
      need_create_photo_ids.each do |photo_id|
        @type_handler.get_link_class.create(
          @type_handler.get_type_id.to_sym => @type_id,
          @type_handler.get_photo_id.to_sym => photo_id,
          :account_id => account_id
        )
      end
    end
    
    jump_to("/#{@linked_photo_type.pluralize}/photo/#{@type_id}")
  end
  
  def destroy_link
    linked_photo_id = @linked_photo.id
    
    @linked_photo.destroy
    
    request.xhr? ? (@linked_photo_id = "linked_photo_#{linked_photo_id}") : jump_to("/#{@linked_photo_type.pluralize}/photo/#{@type_id}")
  end
  
  
  private
  
  def prepare_linked_photo_type
    @linked_photo_type = params[:linked_photo_type]
  end
  
  def get_type_handler(linked_photo_type)
    type_class = linked_photo_type.downcase.capitalize
    eval("Types::#{type_class}").instance
  end
  
  def check_create_link_access
    @type_id = params[:id] && params[:id].strip
    @type_handler = get_type_handler(@linked_photo_type)
    
    account_id = session[:account_id]
    
    jump_to("/errors/forbidden") unless @type_handler.check_create_link_access(@type_id, account_id)
  end
  
  def check_destroy_link_access
    linked_photo_id = params[:id] && params[:id].strip
    @type_handler = get_type_handler(@linked_photo_type)
    
    @linked_photo = @type_handler.get_link_class.find(linked_photo_id)
    @type_id = @linked_photo.send(@type_handler.get_type_id)
    
    account_id = session[:account_id]
    
    jump_to("/errors/forbidden") unless (@linked_photo.account_id == account_id || @type_handler.check_destroy_link_access(@type_id, account_id))
  end
  
  
  
  module Types
    
    class Base
      include Singleton # use .instance() to return the single instance object
      
      def initialize
        @type = self.class.to_s.demodulize.downcase
      end
      
      def get_link_class
        eval("#{@type.capitalize}Photo")
      end
      
      def get_linked_photo_comment_class
        PhotoComment
      end
      
      def get_type_id
        "#{@type}_id"
      end
      
      def get_photo_id
        "photo_id"
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
      
      def check_create_link_access(type_id, account_id)
        ActivityMember.is_activity_member(type_id, account_id)
      end

      def check_destroy_link_access(type_id, account_id)
        ActivityMember.is_activity_admin(type_id, account_id)
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
      
      def check_create_link_access(type_id, account_id)
        GroupMember.is_group_member(type_id, account_id)
      end

      def check_destroy_link_access(type_id, account_id)
        GroupMember.is_group_admin(type_id, account_id)
      end
    end
    
  end
  
end
