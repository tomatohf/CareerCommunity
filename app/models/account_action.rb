class AccountAction < ActiveRecord::Base
  
  include CareerCommunity::AccountBelongings

  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"

  # ---

  validates_presence_of :account_id, :action_type
  
  
  # define account action types
  
  Action_Types = {
    "add_space_comment" => "添加留言",
    "add_blog" => "发表博客",
    "add_friend" => "添加朋友",
    "join_group" => "加入圈子",
    "join_activity" => "参加活动",
    "create_vote_topic" => "发起投票",
    "join_vote_topic" => "参与投票",
    "add_bookmark" => "添加推荐/收藏"
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
  
  def action_text(operator, save_space = false)
    type_obj = get_type_obj(self.action_type)
    type_obj.action_text(type_obj.parse_raw_data(self.raw_data), %Q!["#{operator[0]}", "#{operator[1]}", #{operator[2]}]!, save_space)
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
      def action_text(data, operator, save_space)
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
            :comment_content => #{comment_content.inspect},
            :owner_nick => #{owner_nick.inspect},
            :owner_pic_url => #{owner_pic_url.inspect},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
    end
    
    class AddFriend < Base
      def action_text(data, operator, save_space)
        friend_id = data[:friend_id]
        friend_nick_pic = Account.get_nick_and_pic(friend_id)
        friend_nick = friend_nick_pic[0]
        friend_pic_url = friend_nick_pic[1]
        
        %Q!
          render(:partial => "/spaces/actions/add_friend", :locals => {
            :operator => #{operator},
            :friend_id => #{friend_id},
            :friend_nick => #{friend_nick.inspect},
            :friend_pic_url => #{friend_pic_url.inspect},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
    end
    
    class JoinGroup < Base
      def action_text(data, operator, save_space)
        group_id = data[:group_id]
        group, group_image = Group.get_group_with_image(group_id)
        
        %Q!
          render(:partial => "/spaces/actions/join_group", :locals => {
            :operator => #{operator},
            :group_id => #{group_id},
            :group_name => #{group.name.inspect},
            :group_image => #{group_image.inspect},
            :creator_id => #{group.creator_id},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
    end
    
    class JoinActivity < Base
      def action_text(data, operator, save_space)
        activity_id = data[:activity_id]
        
        begin
          activity, activity_image = Activity.get_activity_with_image(activity_id)
          
          activity_title = activity.get_title
          activity_creator_id = activity.creator_id
        rescue
          activity_title ||= ""
          
          # the creator_id will be -1 if the activity does not exist
          activity_creator_id ||= -1
          
        end
        
        activity_deleted = activity.nil?
        
        %Q!
          render(:partial => "/spaces/actions/join_activity", :locals => {
            :operator => #{operator},
            :activity_id => #{activity_id},
            :activity_title => #{activity_title.inspect},
            :activity_image => #{activity_image.inspect},
            :creator_id => #{activity_creator_id},
            :activity_deleted => #{activity_deleted},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
    end
    
    class CreateVoteTopic < Base
      def action_text(data, operator, save_space)
        vote_topic_id = data[:vote_topic_id]
        
        begin
          vote_topic, vote_image = VoteTopic.get_vote_topic_with_image(vote_topic_id)
          
          vote_topic_title = vote_topic.title
        rescue
          vote_topic_title ||= ""
        end
        
        vote_topic_deleted = vote_topic.nil?
        
        %Q!
          render(:partial => "/spaces/actions/create_vote_topic", :locals => {
            :operator => #{operator},
            :vote_topic_id => #{vote_topic_id},
            :vote_topic_title => #{vote_topic_title.inspect},
            :vote_image => #{vote_image.inspect},
            :vote_topic_deleted => #{vote_topic_deleted},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
    end
    
    class JoinVoteTopic < Base
      def action_text(data, operator, save_space)
        vote_topic_id = data[:vote_topic_id]
        
        begin
          vote_topic, vote_image = VoteTopic.get_vote_topic_with_image(vote_topic_id)
          
          vote_topic_title = vote_topic.title
        rescue
          vote_topic_title ||= ""
        end
        
        vote_topic_deleted = vote_topic.nil?
        
        %Q!
          render(:partial => "/spaces/actions/join_vote_topic", :locals => {
            :operator => #{operator},
            :vote_topic_id => #{vote_topic_id},
            :vote_topic_title => #{vote_topic_title.inspect},
            :vote_image => #{vote_image.inspect},
            :vote_topic_deleted => #{vote_topic_deleted},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
    end
    
    class AddBlog < Base
      def action_text(data, operator, save_space)
        blog_id = data[:blog_id]
        blog_title = data[:blog_title]
        
        %Q!
          render(:partial => "/spaces/actions/add_blog", :locals => {
            :operator => #{operator},
            :blog_id => #{blog_id},
            :blog_title => #{blog_title.inspect},
          
            :save_space => #{save_space.inspect}
          })
        !
      end
    end
    
    class AddBookmark < Base
      def action_text(data, operator, save_space)
        bookmark_class_name = data[:bookmark_class_name]
        bookmark_id = data[:bookmark_id]
        bookmark_title = data[:bookmark_title]
        bookmark_url = data[:bookmark_url]
        bookmark_desc = data[:bookmark_desc]
        
        %Q!
          render(:partial => "/spaces/actions/add_bookmark", :locals => {
            :operator => #{operator},
            :bookmark_class_name => #{bookmark_class_name.inspect},
            :bookmark_id => #{bookmark_id},
            :bookmark_title => #{bookmark_title.inspect},
            :bookmark_url => #{bookmark_url.inspect},
            :bookmark_desc => #{bookmark_desc.inspect},
          
            :save_space => #{save_space.inspect}
          })
        !
      end
    end
    
  end

end
