class AccountAction < ActiveRecord::Base
  
  include CareerCommunity::AccountBelongings

  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"

  # ---

  validates_presence_of :account_id, :action_type
  
  
  # define account action types
  
  Action_Types = {
    "add_space_comment" => "添加留言",
    "add_friend" => "添加朋友",
    "join_group" => "加入圈子",
    "join_activity" => "参加活动"
  }
  
  Action_Types.keys.each do |t|
    define_method(t) {
      t.to_s
    }
    
    define_method("#{t}_type") {
      type_class = t.to_s.split("_").collect{|str| str.capitalize }.join("")
      eval("Types::#{type_class}").instance
    }
  end
  
  
  def self.create_new(a_id, type_id, data)
    aa = AccountAction.new
    aa.action_type = aa.send(type_id)
    aa.account_id = a_id
    aa.raw_data = aa.get_type_obj(type_id).build_raw_data(data)
    aa.save
  end
  
  def get_type_obj(type_id)
    self.send("#{type_id}_type")
  end
  
  def action_text(operator)
    type_obj = get_type_obj(self.action_type)
    type_obj.action_text(type_obj.parse_raw_data(self.raw_data), %Q!["#{operator[0]}", "#{operator[1]}", #{operator[2]}]!)
  end
  
  
  module Types
    
    class Base
      include Singleton # use .instance() to return the single instance object
      
      def build_raw_data(data)
        data.kind_of?(String) ? data : data.inspect
      end
      
      def parse_raw_data(data)
        eval(data)
      end
      
    end
    
    class AddSpaceComment < Base
      def action_text(data, operator)
        owner_id = data[:owner_id]
        comment_id = data[:comment_id]
        comment_content = data[:comment_content]
        
        owner_nick_pic = Account.get_nick_and_pic(owner_id)
        owner_nick = owner_nick_pic[0]
        owner_pic_url = owner_nick_pic[1]
        
        %Q!
          render(:partial => "/spaces/actions/add_space_comment", :locals => {
            :operator => #{operator},
            :owner_id => #{owner_id},
            :comment_id => #{comment_id},
            :comment_content => "#{comment_content}",
            :owner_nick => "#{owner_nick}",
            :owner_pic_url => "#{owner_pic_url}"
          })
        !
      end
    end
    
    class AddFriend < Base
      def action_text(data, operator)
        friend_id = data[:friend_id]
        friend_nick_pic = Account.get_nick_and_pic(friend_id)
        friend_nick = friend_nick_pic[0]
        friend_pic_url = friend_nick_pic[1]
        
        %Q!
          render(:partial => "/spaces/actions/add_friend", :locals => {
            :operator => #{operator},
            :friend_id => #{friend_id},
            :friend_nick => "#{friend_nick}",
            :friend_pic_url => "#{friend_pic_url}"
          })
        !
      end
    end
    
    class JoinGroup < Base
      def action_text(data, operator)
        group_id = data[:group_id]
        group, group_image = Group.get_group_with_image(group_id)
        
        %Q!
          render(:partial => "/spaces/actions/join_group", :locals => {
            :operator => #{operator},
            :group_id => #{group_id},
            :group_name => "#{group.name}",
            :group_image => "#{group_image}"
          })
        !
      end
    end
    
    class JoinActivity < Base
      def action_text(data, operator)
        activity_id = data[:activity_id]
        activity, activity_image = Activity.get_activity_with_image(activity_id)
        
        %Q!
          render(:partial => "/spaces/actions/join_activity", :locals => {
            :operator => #{operator},
            :activity_id => #{activity_id},
            :activity_title => "#{activity.get_title}",
            :activity_image => "#{activity_image}"
          })
        !
      end
    end
    
  end

end
