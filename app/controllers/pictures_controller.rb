class PicturesController < ApplicationController
  
  layout "community"
  
  before_filter :prepare_picture_type
  
  before_filter :check_login, :only => [:upload]
  before_filter :check_limited, :only => []
  
  before_filter :check_create_access, :only => [:upload]
  
  
  
  def upload
    @type_name, @type_image = @type_handler.get_type_with_image(@type_id)
    @type_label = @type_handler.get_type_label
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
      
    end
    
  end
  
end

